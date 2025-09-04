using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebProjectTest.Common;
using WebServiceClass.Helper.WeChat;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.AppServices
{
    public class ClientServices : IBaseService, IClientServices
    {
        private readonly ISqlHelper _dal;

        public ClientServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<List<ClientModel>>> GetTableListInfo(int store_id)
        {
            var tableList = await _dal.Db.Queryable<sys_restaurant_table>()
                .Includes(a => a.order)
                .Includes(a => a.order.reservation)
                .Where(a => a.store_id == store_id)
                .ToListAsync();

            var result = tableList.Select(a => new ClientModel
            {
                Id = a.table_id,
                Name = a.table_no,
                Status = a.status,
                People = a.order == null ? 0 : (int)(a.order.table_capacity ?? 0),
                Max = a.capacity,
                order = a.order,
                desc = a.desc,
                bookedTime = a.order == null ? "" : (a.order.reservation == null ? "" : a.order.reservation?.reservation_time.ToString("yy-MM-dd HH:mm:ss"))
            }).ToList();
            return Success(result, "获取桌台列表成功");
        }

        public async Task<ApiResponse<List<DishList>>> GetDish(int store_id)
        {
            var res = await _dal.Db.Queryable<sys_dish>()
                  .Includes(a=>a.dish_spec)
                  .Includes(a => a.dish_category).OrderBy(a => a.dish_category.sort_order)
                  .Where(a => a.store_id == store_id || a.store_id == null)
                  .Select(a => new DishList
                  {
                      Id = a.dish_id,
                      Name = a.dish_name,
                      Desc = a.description,
                      DishCategoryType = a.category_id,
                      Price = a.member_price,
                      Spece = a.dish_spec.Count() > 0 ? 1 : 0,
                      Img = a.image_url,
                      dish_spec = a.dish_spec
                  }).ToListAsync();
            return Success(res, "菜品获取成功");
        }

        public async Task<ApiResponse<List<DishCategory>>> GetDishType(int store_id)
        {
            var res = await _dal.Db.Queryable<sys_dish_category>()
                 .Where(a => a.store_id == store_id || a.store_id == null).OrderBy(a => a.sort_order)
                 .Select(a => new DishCategory
                 {
                     Id = a.category_id,
                     Name = a.category_name,
                 }).ToListAsync();
            if (res.Count > 0)
                res.FirstOrDefault().active = true;
            return Success(res, "菜品类型获取成功");
        }

        public async Task<ApiResponse<bool>> SaveOrder(List<Order> order, int store_id, int table_id, int sourceType, int people,int? order_Id)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var table = await _dal.Db.Queryable<sys_restaurant_table>()
                    .Where(a => a.store_id == store_id && a.table_id == table_id)
                    .FirstAsync();
                if (order_Id.HasValue)
                {
                    var orderData = await _dal.Db.Queryable<sys_order>().FirstAsync(a=>a.order_id == order_Id);
                    orderData.total_amount = orderData.total_amount + order.Sum(o => decimal.Parse(o.price) * o.qty);
                    orderData.payable_amount = orderData.payable_amount + order.Sum(o => decimal.Parse(o.price) * o.qty);
                    await _dal.Db.Updateable(orderData).ExecuteCommandAsync();

                    var orderItems = order.Select(o => new sys_order_item
                    {
                        order_id =(int) order_Id,
                        dish_id = o.Id,
                        quantity = o.qty,
                        unit_price = decimal.Parse(o.price),
                        total_price = decimal.Parse(o.price) * o.qty,
                        specification = $"{o.spec},{o.spicy}",
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    foreach (var item in orderItems)
                    {
                        var itemId = await _dal.Db.Insertable(item).ExecuteReturnBigIdentityAsync();
                        if (itemId <= 0)
                        {
                            await _dal.Db.Ado.RollbackTranAsync();
                            return Fail<bool>("下单失败，订单明细保存失败！");
                        }
                        //保存厨房订单
                        var kitchenOrders = order.Select(o => new sys_kitchen_order
                        {
                            item_id = itemId,
                            store_id = store_id,
                            table_no = table?.table_no,
                            dish_name = o.name,
                            quantity = o.qty,
                            kitchen_type = "热菜",
                            status = 1, // 1-待制作
                            create_time = DateTime.Now,
                            overtime_warn = 0, // 超时预警时间
                        }).ToList();
                        await _dal.Db.Insertable(kitchenOrders).ExecuteCommandAsync();
                    }
                }
                else
                {


                    var orderId = await _dal.Db.Insertable(new sys_order
                    {
                        store_id = store_id,
                        table_id = table_id,
                        order_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(1000, 9999),
                        order_type = 1, // 堂食
                        source_type = (byte)sourceType, // 下单方式
                        status = 2,// 已下单
                        discount_amount = 0, // 优惠金额
                        service_fee = 0, // 服务费
                        total_amount = order.Sum(o => decimal.Parse(o.price) * o.qty),
                        payable_amount = order.Sum(o => decimal.Parse(o.price) * o.qty),
                        table_fee = table.min_consumption, // 桌台费
                        start_time = DateTime.Now,
                        is_split = 0, // 是否分单
                        operator_id = 0, // 操作员ID  0默认用户
                        table_capacity = people
                    }).ExecuteReturnBigIdentityAsync();

                    if (orderId <= 0)
                    {
                        return Fail<bool>("下单失败");
                    }
                    //保存订单明细
                    var orderItems = order.Select(o => new sys_order_item
                    {
                        order_id = orderId,
                        dish_id = o.Id,
                        quantity = o.qty,
                        unit_price = decimal.Parse(o.price),
                        total_price = decimal.Parse(o.price) * o.qty,
                        specification = $"{o.spec},{o.spicy}",
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    foreach (var item in orderItems)
                    {
                        var itemId = await _dal.Db.Insertable(item).ExecuteReturnBigIdentityAsync();
                        if (itemId <= 0)
                        {
                            await _dal.Db.Ado.RollbackTranAsync();
                            return Fail<bool>("下单失败，订单明细保存失败！");
                        }
                        var dish = await _dal.Db.Queryable<sys_order_item>().Includes(a=>a.dish,b=>b.dish_kitchen).FirstAsync(a=>a.item_id == itemId);
                        //保存厨房订单
                        var kitchenOrders = order.Select(o => new sys_kitchen_order
                        {
                            item_id = itemId,
                            store_id = store_id,
                            table_no = table?.table_no,
                            dish_name = o.name,
                            quantity = o.qty,
                            kitchen_type = dish.dish.dish_kitchen.kitchen_name,
                            status = 1, // 1-待制作
                            create_time = DateTime.Now,
                            overtime_warn = 0, // 超时预警时间
                            cooking_require = dish.specification
                        }).ToList();
                        await _dal.Db.Insertable(kitchenOrders).ExecuteCommandAsync();
                    }
                    table.order_id = (int)orderId;
                    table.status = 2;
                    await _dal.Db.Updateable(table).ExecuteCommandAsync();
                }
               
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "下单成功");
            }
            catch (Exception)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>("下单失败！");
            }
        }

        public async Task<ApiResponse<List<sys_order>>> GetTableOrder(int store_id, int? table_id, int sourceType)
        {
            var res = await _dal.Db.Queryable<sys_order>().Includes(a => a.table)
                .WhereIF(sourceType == 2,a => a.store_id == store_id && a.table_id == table_id &&( a.status == 1 || a.status == 2))
                .WhereIF(sourceType == 1,a => a.store_id == store_id &&( a.status == 1 || a.status == 2)).OrderByDescending(a=>a.order_id)
                .ToListAsync();
            return Success(res, "获取成功");
        }

        public async Task<ApiResponse<bool>> OrderReminder(int orderId)
        {
            var Orderitem = await _dal.Db.Queryable<sys_order_item>()
                .Where(a => a.order_id == orderId && (a.status == 1 || a.status ==2)).ToListAsync();
            Orderitem.ForEach(a => a.is_rush = 1);
            await _dal.Db.Updateable(Orderitem).ExecuteCommandAsync();
            return Success(true );
        }

        public async Task<ApiResponse<OrderDetailResult>> OrderDetails(int orderId)
        {
            var res = await _dal.Db.Queryable<sys_order_item>()
                .Includes(a => a.dish)
                .Where(a => a.order_id == orderId).ToListAsync();

            var order = await _dal.Db.Queryable<sys_order>().Includes(a => a.table).FirstAsync(a => a.order_id == orderId);
            var result = new OrderDetailResult();
            result.total = order.payable_amount;
            result.tableName = order.table.table_no;
            result.orderId = orderId;
            result.tableId = (int)order.table_id;
            result.storeId = (int)order.store_id;
            result.orderDetails = res.Select(a => new OrderDetail
            {
                Id = a.item_id,
                Name = a.dish.dish_name,
                Spec = $"{a.specification}*{a.quantity}",
                Price = a.total_price,
            }).ToList();
            //判断是否有转桌并桌记录
            var tableChangeTable = await _dal.Db.Queryable<sys_table_transfer>().Where(a => a.order_id == orderId && a.type == 1)
                .OrderBy(a=>a.transfer_id).ToListAsync();
            if (tableChangeTable.Count()> 0)
            {
                result.changeTable =  order.table.table_no;
            }
            //并桌取最后合并订单
            var tableMergedTable = await _dal.Db.Queryable<sys_table_transfer>().Where(a => a.order_id == orderId && a.type == 2)
                .OrderBy(a => a.transfer_id).ToListAsync();
            if (tableMergedTable.Count() > 0)
            {
                result.mergedTable = order.table.table_no;
            }


            return Success(result, "获取订单明细成功");
        }

        public async Task<ApiResponse<bool>> OrderCheckout(int orderId, int? CouponsId, string type,string Code,string url, int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var Msg = "";var coupon = new sys_coupon();
                if(CouponsId.HasValue && CouponsId > 0)
                {
                     coupon = await _dal.Db.Queryable<sys_coupon>().FirstAsync(a => a.coupon_id == CouponsId);
                    if(coupon != null)
                    {
                        if(coupon.status == 0 || coupon.status == 2)
                        {
                            Msg = "优惠券不可用，可能未到使用时间或已过期";
                        }
                        else if(coupon.status == 1)
                        {
                            //更新优惠券状态
                            coupon.used = coupon.used+1;
                            coupon.received = coupon.received+1;
                            if (coupon.total!=null && coupon.used>=coupon.total)
                            {
                                coupon.status = 2;//优惠卷全部使用完
                            }
                            await _dal.Db.Updateable(coupon).ExecuteCommandAsync();
                        }
                    }
                    else
                    {
                        Msg = "优惠券不存在";
                    }
                }
                switch (type)
                {
                    case "wechat": //微信
                        decimal service_fee = (decimal)0.00;
                        var order1 = await _dal.Db.Queryable<sys_order>().Includes(a => a.store).FirstAsync(a => a.order_id == orderId);
                        if (order1.table_fee != 0 && order1.payable_amount < order1.table_fee)
                            service_fee = order1.payable_amount * (decimal)0.1;
                        await _dal.Db.Updateable<sys_order>()
                        .SetColumns(a => new sys_order { status = 3, pay_time = DateTime.Now, close_time = DateTime.Now, paymeth = "微信支付",payable_amount = a.payable_amount - coupon.value+ service_fee,service_fee = service_fee,operator_id = userId})
                        .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                        await _dal.Db.Updateable<sys_restaurant_table>()
                        .SetColumns(a => new sys_restaurant_table { status = 4, order_id = null }).Where(a => a.table_id == order1.table_id).ExecuteCommandAsync();
                        var order = await _dal.Db.Queryable<sys_order>().Includes(a => a.store).FirstAsync(a => a.order_id == orderId);

                        var res = await WeChatPayHelper.CallCustomerUnifiedRechargeApi(url, "餐饮收银", "餐饮收银订单支付", order?.order_no, order.payable_amount, Code, order.store?.store_code, 0);
                        //支付记录
                        await _dal.Db.Insertable(new sys_payment
                        {
                            order_id = orderId,
                            payment_no =  DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(1000, 9999),
                            pay_amount = order.payable_amount,
                            pay_type = 1,
                            status = 2,
                            pay_time = DateTime.Now,
                            coupon_id = coupon?.coupon_id

                        }).ExecuteCommandAsync();
                        Msg = res;
                        break;
                    case "alipay": //支付宝

                        break;
                    default:
                        break;
                }
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "结账成功");   
            }
            catch (Exception)
            {

                throw;
            }
        }

        /// <summary>
        /// 并桌--不更新桌台状态
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> MergeTables(int oldTableId, int newTableId, int orderId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();


                await _dal.Db.Insertable(new sys_table_transfer
                {
                    order_id = orderId,
                    old_table_id = oldTableId,
                    new_table_id = newTableId,
                    transfer_time = DateTime.Now,
                    type = 2
                }).ExecuteCommandAsync();
                var table = await _dal.Db.Queryable<sys_restaurant_table>().FirstAsync(a=>a.table_id == newTableId);
                var order = await _dal.Db.Queryable<sys_order>().Where(a=>a.order_id == orderId || a.order_id == table.order_id).ToListAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a =>new sys_restaurant_table { order_id = table.order_id }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable(new sys_order
                {
                    order_id =(long) table.order_id,
                    total_amount = order.Sum(o =>o.total_amount),
                    payable_amount = order.Sum(o => o.payable_amount),
                }).ExecuteCommandAsync();

                var orderitem = await _dal.Db.Queryable<sys_order_item>().Where(a=>a.order_id==orderId)
                    .Select(a =>new sys_order_item
                    {
                        item_id = 0,
                        order_id =(long) table.order_id,
                    },true).ToListAsync();

                await _dal.Db.Insertable(orderitem).ExecuteCommandAsync();

                await _dal.Db.Updateable<sys_order>().SetColumns(a =>new sys_order { status = 7}).Where(a => a.order_id == orderId).ExecuteCommandAsync();

                await _dal.Db.Ado.CommitTranAsync();

                return Success(true, "转桌成功！");
            }
            catch (Exception e)
            {

                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>($"转桌失败！{e.Message}");
            }
        }

        /// <summary>
        /// 转桌
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> ChangeTables(int oldTableId, int newTableId, int orderId)
        {
            try
            {
               await _dal.Db.Ado.BeginTranAsync();


                await _dal.Db.Insertable(new sys_table_transfer
                {
                    order_id = orderId,
                    old_table_id = oldTableId,
                    new_table_id = newTableId,
                    transfer_time = DateTime.Now,
                    type = 1
                }).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_restaurant_table>()
                    .SetColumns(a=>new sys_restaurant_table { status =1,order_id = null }).Where(a=>a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_restaurant_table>()
                    .SetColumns(a => new sys_restaurant_table { status = 2, order_id = orderId }).Where(a => a.table_id == newTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_order>().SetColumns(a => a.table_id == newTableId).Where(a => a.order_id == orderId).ExecuteCommandAsync();

                await _dal.Db.Ado.CommitTranAsync();

                return Success(true, "转桌成功！");
            }
            catch (Exception e)
            {

               await _dal.Db.Ado.RollbackTranAsync();
               return Fail<bool>($"转桌失败！{e.Message}");
            }
        }

        public async Task<ApiResponse<List<sys_coupon>>> GetCouponListAsync(long? storeId)
        {
            var query = _dal.Db.Queryable<sys_coupon>().Where(x => x.store_id == storeId || x.store_id == 0).Where(a=>a.status==1);

            var list = await query.OrderBy(x => x.coupon_id, OrderByType.Desc)
                                  .ToListAsync();
            return Success(list);
        }
    }
}
