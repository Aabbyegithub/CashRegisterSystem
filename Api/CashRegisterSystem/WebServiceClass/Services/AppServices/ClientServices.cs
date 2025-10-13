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
        private readonly WeChatPayHelper _weChatPayHelper;
        private readonly IAppSettinghelper _AppSetting;

        public ClientServices(ISqlHelper dal, WeChatPayHelper weChatPayHelper, IAppSettinghelper appSetting)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
            _weChatPayHelper = weChatPayHelper;
            _AppSetting = appSetting;
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
                  .Includes(a => a.dish_spec)
                  .Includes(a => a.dish_category).OrderBy(a => a.dish_category.sort_order)
                  .Where(a => a.store_id == store_id || a.store_id == null).Where(a => a.status == 1)
                  .Select(a => new DishList
                  {
                      Id = a.dish_id,
                      Name = a.dish_name,
                      Desc = a.description,
                      DishCategoryType = a.category_id,
                      Price = a.price,
                      memberprice = a.member_price,
                      Spece = a.dish_spec.Count() > 0 ? 1 : 0,
                      Img = a.image_url,
                      dish_spec = a.dish_spec,
                      Type = 0
                  }).ToListAsync();
            //增加套餐
            var meal = await _dal.Db.Queryable<sys_set_meal>().Includes(a => a.item, b => b.meal_item_dish).Where(a => a.store_id == store_id && a.status == 1)
                .Select(a => new DishList
                {
                    Id = a.meal_id,
                    Name = a.meal_name,
                    Desc = a.description,
                    DishCategoryType = a.is_fixed == 1 ? 99 : 100,
                    Price = a.price,
                    memberprice = a.price,
                    Spece = a.is_fixed == 1 ? 0 : 1,
                    Img = a.image_url,
                    meal_item = a.item,
                    Type = 1
                }).ToListAsync();
            var result = res.Concat(meal).ToList();
            return Success(result, "菜品获取成功");
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
            if (await _dal.Db.Queryable<sys_set_meal>().Where(a => a.store_id == store_id && a.status == 1 && a.is_fixed == 0).CountAsync() > 0)
                res.Add(new DishCategory { Id = 99, Name = "固定套餐" });
            if (await _dal.Db.Queryable<sys_set_meal>().Where(a => a.store_id == store_id && a.status == 1 && a.is_fixed == 1).CountAsync() > 0)
                res.Add(new DishCategory { Id = 100, Name = "组合套餐" });
            if (res.Count > 0)
                res.FirstOrDefault().active = true;
            return Success(res, "菜品类型获取成功");
        }

        public async Task<ApiResponse<bool>> SaveOrder(List<Order> order, int store_id, int table_id, int sourceType, int people, int? order_Id, string? memberPhone)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var table = await _dal.Db.Queryable<sys_restaurant_table>()
                    .Where(a => a.table_id == table_id).With(SqlWith.UpdLock)
                    .FirstAsync();

                if (table == null)
                {
                    Fail<bool>("该桌台有未完成的订单！下单失败");
                }
                var member = await _dal.Db.Queryable<sys_member>().FirstAsync(a => a.phone == memberPhone && a.status == 1);
                if ((order_Id.HasValue && order_Id != 0) || table.order_id != null)
                {
                    order_Id = table.order_id;
                    var orderData = await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).FirstAsync(a => a.order_id == order_Id);
                    orderData.total_amount = orderData.total_amount +
                        (orderData.member_id.HasValue ? order.Sum(o => decimal.Parse(o.memberprice) * o.qty) : order.Sum(o => decimal.Parse(o.price) * o.qty));
                    orderData.payable_amount = orderData.payable_amount +
                        (orderData.member_id.HasValue ? order.Sum(o => decimal.Parse(o.memberprice) * o.qty) : order.Sum(o => decimal.Parse(o.price) * o.qty));
                    await _dal.Db.Updateable(orderData).ExecuteCommandAsync();

                    var orderItems = order.Where(o => o.Type == 0).Select(o => new sys_order_item
                    {
                        order_id = (int)order_Id,
                        dish_id = o.Id,
                        quantity = o.qty,
                        unit_price = member == null ? decimal.Parse(o.price) : decimal.Parse(o.memberprice),
                        total_price = member == null ? decimal.Parse(o.price) * o.qty : decimal.Parse(o.memberprice) * o.qty,
                        specification = !string.IsNullOrWhiteSpace(o.spec) ? $"{o.spec},{o.spicy}" : o.spicy,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();

                    //固定套餐
                    var orderMealItems = order.Where(o => o.Type == 1 && o.dishCategoryType == 99).Select(a => a.Id).ToList();
                    var Mealdish = await _dal.Db.Queryable<sys_set_meal_item>()
                        .Includes(a => a.meal_item_dish).Includes(a => a.meal_item_dish_spec).Where(a => orderMealItems.Contains((long)a.meal_id)).ToListAsync();
                    var orderItemsFix1 = Mealdish.Select(o => new sys_order_item
                    {
                        order_id = (int)order_Id,
                        dish_id = o.dish_id,
                        quantity = o.quantity,
                        unit_price = member == null ? o.meal_item_dish.price : o.meal_item_dish.member_price,
                        total_price = member == null ? o.meal_item_dish.price * o.quantity : o.meal_item_dish.member_price * o.quantity,
                        specification = o.meal_item_dish_spec?.spec_name,
                        meal_id = o.meal_id,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    orderItems.AddRange(orderItemsFix1);
                    //组合套餐
                    var orderMealItems2 = order.Where(o => o.Type == 1 && o.dishCategoryType == 100)
                        .Select(o => o.mealoptions)
                        .SelectMany(mealOptions => mealOptions)
                        .SelectMany(item => item.options).Select(a => a.id).ToList();

                    var Mealdish2 = await _dal.Db.Queryable<sys_set_meal_item>()
                    .Includes(a => a.meal_item_dish).Includes(a => a.meal_item_dish_spec).Where(a => orderMealItems2.Contains((long)a.item_id)).ToListAsync();

                    var orderItemsFix2 = Mealdish2.Select(o => new sys_order_item
                    {
                        order_id = (int)order_Id,
                        dish_id = o.dish_id,
                        quantity = o.quantity,
                        unit_price = member == null ? o.meal_item_dish.price : o.meal_item_dish.member_price,
                        total_price = member == null ? o.meal_item_dish.price * o.quantity : o.meal_item_dish.member_price * o.quantity,
                        specification = o.meal_item_dish_spec?.spec_name,
                        meal_id = o.meal_id,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    orderItems.AddRange(orderItemsFix2);
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
                        member_id = member?.member_id,
                        order_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999),
                        order_type = 1, // 堂食
                        source_type = (byte)sourceType, // 下单方式
                        status = 2,// 已下单
                        discount_amount = 0, // 优惠金额
                        service_fee = 0, // 服务费
                        total_amount = member == null ? order.Sum(o => decimal.Parse(o.price) * o.qty) : order.Sum(o => decimal.Parse(o.memberprice) * o.qty),
                        payable_amount = member == null ? order.Sum(o => decimal.Parse(o.price) * o.qty) : order.Sum(o => decimal.Parse(o.memberprice) * o.qty),
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
                    #region  处理正常菜品
                    //保存订单明细
                    var orderItems = order.Where(o => o.Type == 0).Select(o => new sys_order_item
                    {
                        order_id = orderId,
                        dish_id = o.Id,
                        quantity = o.qty,
                        unit_price = member == null ? decimal.Parse(o.price) : decimal.Parse(o.memberprice),
                        total_price = member == null ? decimal.Parse(o.price) * o.qty : decimal.Parse(o.memberprice) * o.qty,
                        specification = !string.IsNullOrWhiteSpace(o.spec) ? $"{o.spec},{o.spicy}" : o.spicy,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();

                    #endregion
                    #region  处理套餐
                    //固定套餐
                    var orderMealItems = order.Where(o => o.Type == 1 && o.dishCategoryType == 99).Select(a => a.Id).ToList();
                    var Mealdish = await _dal.Db.Queryable<sys_set_meal_item>()
                        .Includes(a => a.meal_item_dish).Includes(a => a.meal_item_dish_spec).Where(a => orderMealItems.Contains((long)a.meal_id)).ToListAsync();
                    var orderItemsFix1 = Mealdish.Select(o => new sys_order_item
                    {
                        order_id = orderId,
                        dish_id = o.dish_id,
                        quantity = o.quantity,
                        unit_price = member == null ? o.meal_item_dish.price : o.meal_item_dish.member_price,
                        total_price = member == null ? o.meal_item_dish.price * o.quantity : o.meal_item_dish.member_price * o.quantity,
                        specification = o.meal_item_dish_spec?.spec_name,
                        meal_id = o.meal_id,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    orderItems.AddRange(orderItemsFix1);
                    //组合套餐
                    var orderMealItems2 = order.Where(o => o.Type == 1 && o.dishCategoryType == 100)
                        .Select(o => o.mealoptions)
                        .SelectMany(mealOptions => mealOptions)
                        .SelectMany(item => item.options).Select(a => a.id).ToList();

                    var Mealdish2 = await _dal.Db.Queryable<sys_set_meal_item>()
                    .Includes(a => a.meal_item_dish).Includes(a => a.meal_item_dish_spec).Where(a => orderMealItems2.Contains((long)a.item_id)).ToListAsync();

                    var orderItemsFix2 = Mealdish2.Select(o => new sys_order_item
                    {
                        order_id = orderId,
                        dish_id = o.dish_id,
                        quantity = o.quantity,
                        unit_price = member == null ? o.meal_item_dish.price : o.meal_item_dish.member_price,
                        total_price = member == null ? o.meal_item_dish.price * o.quantity : o.meal_item_dish.member_price * o.quantity,
                        specification = o.meal_item_dish_spec?.spec_name,
                        meal_id = o.meal_id,
                        status = 1, // 状态 1-待制作
                        is_rush = 0,
                    }).ToList();
                    orderItems.AddRange(orderItemsFix2);

                    foreach (var item in orderItems)
                    {
                        var itemId = await _dal.Db.Insertable(item).ExecuteReturnBigIdentityAsync();
                        if (itemId <= 0)
                        {
                            await _dal.Db.Ado.RollbackTranAsync();
                            return Fail<bool>("下单失败，订单明细保存失败！");
                        }
                        var dish = await _dal.Db.Queryable<sys_order_item>().Includes(a => a.dish, b => b.dish_kitchen).FirstAsync(a => a.item_id == itemId);
                        //保存厨房订单
                        var kitchenOrders = new sys_kitchen_order
                        {
                            item_id = itemId,
                            store_id = store_id,
                            table_no = table?.table_no,
                            dish_name = dish.dish.dish_name,
                            quantity = item.quantity,
                            kitchen_type = dish.dish.dish_kitchen.kitchen_name,
                            status = 1, // 1-待制作
                            create_time = DateTime.Now,
                            overtime_warn = 0, // 超时预警时间
                            cooking_require = dish.specification
                        };
                        await _dal.Db.Insertable(kitchenOrders).ExecuteCommandAsync();
                    }



                    #endregion
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
                .WhereIF(sourceType == 2, a => a.store_id == store_id && a.table_id == table_id && (a.status == 1 || a.status == 2))
                .WhereIF(sourceType == 1, a => a.store_id == store_id && (a.status == 1 || a.status == 2)).OrderByDescending(a => a.order_id)
                .ToListAsync();
            return Success(res, "获取成功");
        }

        public async Task<ApiResponse<bool>> OrderReminder(int orderId)
        {
            var Orderitem = await _dal.Db.Queryable<sys_order_item>()
                .Where(a => a.order_id == orderId && (a.status == 1 || a.status == 2)).ToListAsync();
            Orderitem.ForEach(a => a.is_rush = 1);
            await _dal.Db.Updateable(Orderitem).ExecuteCommandAsync();
            return Success(true);
        }

        public async Task<ApiResponse<OrderDetailResult>> OrderDetails(int orderId)
        {
            var res = await _dal.Db.Queryable<sys_order_item>()
                .Includes(a => a.dish)
                .Includes(a => a.meal)
                .Where(a => a.order_id == orderId).ToListAsync();

            var order = await _dal.Db.Queryable<sys_order>().Includes(a => a.table).FirstAsync(a => a.order_id == orderId);
            var result = new OrderDetailResult();
            result.total = order.payable_amount;
            result.tableName = order.table.table_no;
            result.orderId = orderId;
            result.tableId = (int)order.table_id;
            result.storeId = (int)order.store_id;
            result.orderDetails = res
                 .GroupBy(x => new { x.dish_id, x.specification })
                .Select(g => new OrderDetail
                {
                    Id = g.First().item_id,
                    Name = g.First().dish.dish_name,
                    Spec = $"{g.Key.specification}*{g.Sum(x => x.quantity)}({g.First().meal?.meal_name}*{g.First().meal?.price})",
                    Price = g.Sum(x => x.total_price)
                })
                .ToList();
            //判断是否有转桌并桌记录
            var tableChangeTable = await _dal.Db.Queryable<sys_table_transfer>().Where(a => a.order_id == orderId && a.type == 1)
                .OrderBy(a => a.transfer_id).ToListAsync();
            if (tableChangeTable.Count() > 0)
            {
                result.changeTable = order.table.table_no;
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

        public async Task<ApiResponse<Dictionary<string, string>>> OrderCheckout(int orderId, int? CouponsId, string type, string Code, int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();

                var order1 = await _dal.Db.Queryable<sys_order>()
                .With(SqlWith.UpdLock) // 加锁防止并发查询
                .FirstAsync(a => a.order_id == orderId);
                if (order1 == null)
                {
                    await _dal.Db.Ado.RollbackTranAsync();
                    return Error<Dictionary<string, string>>("订单不存在");
                }
                if (order1.status == 3) // 3代表“已支付”
                {
                    await _dal.Db.Ado.RollbackTranAsync();
                    return Error<Dictionary<string, string>>("订单已完成结账，无需重复操作");
                }
                var Msg = "OK"; var coupon = new sys_coupon(); var remark = "";
                if (CouponsId.HasValue && CouponsId > 0)
                {
                    coupon = await _dal.Db.Queryable<sys_coupon>().With(SqlWith.UpdLock).FirstAsync(a => a.coupon_id == CouponsId);
                    if (coupon != null)
                    {
                        if (coupon.status == 0 || coupon.status == 2)
                        {
                            Msg = "优惠券不可用，可能未到使用时间或已过期";
                        }
                        else if (coupon.status == 1)
                        {
                            if (coupon.total != null && coupon.used >= coupon.total)
                            {
                                await _dal.Db.Ado.RollbackTranAsync();
                                return Error<Dictionary<string, string>>("优惠券已被抢完，无法使用");
                            }
                            remark += $"优惠卷-{coupon.value}";
                            //更新优惠券状态
                            coupon.used = coupon.used + 1;
                            coupon.received = coupon.received + 1;
                            if (coupon.total != null && coupon.used >= coupon.total)
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

                decimal service_fee = (decimal)0.00; var member = new sys_member(); string res = ""; decimal promotionValue = (decimal)0.00;

                //查询是否有活动
                var promotion = await _dal.Db.Queryable<sys_promotion>().FirstAsync(a => a.status == 1 && order1.created_at >= a.start_time && order1.created_at <= a.end_time);
                if (promotion != null)
                {
                    if (promotion.type == 1 && order1.total_amount >= promotion.min_consumption)
                    {
                        promotionValue = (decimal)promotion.value; remark += $"活动-{promotion.start_time}-{promotion.end_time}-{promotion.promotion_name}-{promotion.value}";
                    }

                    if (promotion.type == 2 && promotion.min_consumption.HasValue && order1.total_amount >= promotion.min_consumption)
                    {
                        promotionValue = (decimal)(order1.total_amount * (1 - promotion.value / 100));
                        remark += $"活动-{promotion.start_time}-{promotion.end_time}-{promotion.promotion_name}-{promotion.value}折";
                    }
                    if (promotion.type == 2 && !promotion.min_consumption.HasValue)
                    {
                        promotionValue = (decimal)(order1.total_amount * (1 - promotion.value / 100));
                        remark += $"活动-{promotion.start_time}-{promotion.end_time}-{promotion.promotion_name}-{promotion.value}折";
                    }
                }

                if (order1.table_fee != 0 && order1.payable_amount < order1.table_fee)
                    service_fee = order1.payable_amount * (decimal)0.1;
                await _dal.Db.Updateable<sys_order>()
                .SetColumns(a => new sys_order
                {
                    status = 1,
                    pay_time = DateTime.Now,
                    close_time = DateTime.Now,
                    paymeth = GetPaymentMethod(type),
                    discount_amount = (coupon.value + promotionValue),
                    payable_amount = (a.payable_amount - coupon.value + service_fee - promotionValue),
                    service_fee = service_fee,
                    operator_id = userId
                })
                .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                .SetColumns(a => new sys_restaurant_table { status = 4, order_id = null, lastUseTime = DateTime.Now }).Where(a => a.table_id == order1.table_id).ExecuteCommandAsync();
                var order = await _dal.Db.Queryable<sys_order>().Includes(a => a.store).FirstAsync(a => a.order_id == orderId);
                if (order.member_id.HasValue)
                {
                    member = await _dal.Db.Queryable<sys_member>().With(SqlWith.UpdLock).FirstAsync(a => a.member_id == order.member_id && a.status == 1);

                }
                decimal pay = order.payable_amount;
                //查询是否有活动


                //会员优先扣除充值金额
                if (member != null && member.member_id != 0)
                {

                    if (member.balance >= order.payable_amount)
                    {
                        member.balance = member.balance - order.payable_amount;
                        member.total_points = member.total_points + (int)order.payable_amount;
                        pay = 0;
                        remark += $"会员支付-{order.payable_amount}";
                        await _dal.Db.Updateable<sys_order>()
                        .SetColumns(a => new sys_order
                        {
                            discount_amount = a.discount_amount +a.payable_amount,
                            payable_amount =0,
                        })
                        .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    }
                    else
                    {
                        member.balance = 0;
                        pay = order.payable_amount - (decimal)member.balance;
                        member.total_points = member.total_points + (int)member.balance;
                        remark += $"会员支付-{member.balance}";
                        await _dal.Db.Updateable<sys_order>()
                        .SetColumns(a => new sys_order
                        {
                            discount_amount = a.discount_amount + (decimal)member.balance,
                            payable_amount = pay,
                        })
                        .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    }

                }
                byte pay_type = 0;
                switch (type)
                {
                    case "wechat": //微信

                        if (pay != 0)
                        {
                            pay_type = 1;
                            remark += $"微信支付-{pay}";
                            if (userId == 0) ///小程序支付
                            {
                                var openId = await OAuthCallback(Code);
                                decimal amount = 0.01m;
                                //decimal amount = pay;
                                string productDesc = "菜单结账";

                                var jsapiParam = _weChatPayHelper.JsApiPay(order1.order_no, amount, openId, productDesc);
                                if (jsapiParam != null)
                                {
                                    //支付记录
                                    await _dal.Db.Insertable(new sys_payment
                                    {
                                        order_id = orderId,
                                        payment_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999),
                                        pay_amount = pay,
                                        pay_type = pay_type,
                                        status = 1,
                                        pay_time = DateTime.Now,
                                        coupon_id = coupon?.coupon_id,
                                        remark = $"支付方式：{remark}"

                                    }).ExecuteCommandAsync();
                                    await _dal.Db.Ado.CommitTranAsync();
                                   
                                   return Success(jsapiParam,"小程序支付下单成功"); // 将支付参数返回给前端，前端调起微信支付
                                }
                                else
                                {
                                    await _dal.Db.Ado.RollbackTranAsync();
                                    return Error<Dictionary<string, string>>("微信支付下单失败，请重试");
                                }
                            }
                            else    //用户付款码支付
                            {
                                decimal amount = 0.01m; // 支付金额，单位：元

                                bool isSuccess = _weChatPayHelper.CodePay(order1.order_no, amount, Code);
                                if (isSuccess)
                                {
                                    await _dal.Db.Updateable<sys_order>()
                                       .SetColumns(a => new sys_order
                                       {
                                           status = 3, // 3=已支付
                                           pay_time = DateTime.Now,
                                           close_time = DateTime.Now,
                                           paymeth = GetPaymentMethod(type) // 补充支付方式枚举转换
                                       })
                                       .Where(a => a.order_id == orderId)
                                       .ExecuteCommandAsync();
                                    await _dal.Db.Insertable(new sys_payment
                                    {
                                        order_id = orderId,
                                        payment_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999),
                                        pay_amount = pay,
                                        pay_type = pay_type,
                                        status = 2,
                                        pay_time = DateTime.Now,
                                        coupon_id = coupon?.coupon_id,
                                        remark = $"支付方式：{remark}"

                                    }).ExecuteCommandAsync();
                                    await _dal.Db.Ado.CommitTranAsync();

                                    return Success(new Dictionary<string, string>(),"支付成功");
                                }
                                else
                                {
                                    await _dal.Db.Ado.RollbackTranAsync();
                                    return Error<Dictionary<string, string>>("微信刷卡支付失败，请检查付款码或重试");
                                }
                            }
                        }
                        break;
                    case "alipay": //支付宝

                        break;
                    default:
                        break;
                }
                return Success<Dictionary<string, string>>(null,"积分正常结算");
            }
            catch (Exception ex)
            {

                // 回滚事务（必须加，防止事务挂起导致锁未释放）
                await _dal.Db.Ado.RollbackTranAsync();

                // 识别 MySQL 锁等待超时异常（错误码：1205）
                if (ex.InnerException != null && ex.InnerException.Message.Contains("1205"))
                {
                    return Error<Dictionary<string, string>>("当前订单正在处理中，请稍后重试");
                }

                // 其他异常返回通用提示（避免暴露敏感信息）
                return Error<Dictionary<string, string>>($"结账失败，请联系系统管理员{ex.Message}");

            }
        }

        private string GetPaymentMethod(string type)
        {
            return type switch
            {
                "wechat" => "微信支付",
                "alipay" => "支付宝支付",
                "cash" => "现金支付",
                "unionpay" => "银联支付", // 便于扩展新支付方式
                _ => "未知支付方式"
            };
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
                var table = await _dal.Db.Queryable<sys_restaurant_table>().With(SqlWith.UpdLock).FirstAsync(a => a.table_id == newTableId);
                var order = await _dal.Db.Queryable<sys_order>().Where(a => a.order_id == orderId || a.order_id == table.order_id).With(SqlWith.UpdLock).ToListAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a => new sys_restaurant_table { order_id = table.order_id }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable(new sys_order
                {
                    order_id = (long)table.order_id,
                    total_amount = order.Sum(o => o.total_amount),
                    payable_amount = order.Sum(o => o.payable_amount),
                }).ExecuteCommandAsync();

                var orderitem = await _dal.Db.Queryable<sys_order_item>().With(SqlWith.UpdLock).Where(a => a.order_id == orderId)
                    .Select(a => new sys_order_item
                    {
                        item_id = 0,
                        order_id = (long)table.order_id,
                    }, true).ToListAsync();

                await _dal.Db.Insertable(orderitem).ExecuteCommandAsync();

                await _dal.Db.Updateable<sys_order>().SetColumns(a => new sys_order { status = 7 }).Where(a => a.order_id == orderId).ExecuteCommandAsync();

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
                await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_restaurant_table { status = 2, order_id = orderId }).Where(a => a.table_id == newTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock).SetColumns(a => a.table_id == newTableId).Where(a => a.order_id == orderId).ExecuteCommandAsync();

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
        /// 获取优惠卷
        /// </summary>
        /// <param name="storeId"></param>
        /// <returns></returns>
        public async Task<ApiResponse<List<sys_coupon>>> GetCouponListAsync(long? storeId)
        {
            var query = _dal.Db.Queryable<sys_coupon>().Where(x => x.store_id == storeId || x.store_id == 0).Where(a => a.status == 1);

            var list = await query.OrderBy(x => x.coupon_id, OrderByType.Desc)
                                  .ToListAsync();
            return Success(list);
        }

        /// <summary>
        /// 获取用户微信唯一id
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        private async Task<string> OAuthCallback(string code)
        {
            var res = "";
            // 若 code 为空，授权失败
            if (string.IsNullOrEmpty(code))
            {
                return res;
            }

            // 调用微信接口，通过 code 换取 OpenID
            string url = $@"{_AppSetting.Get("WhChat:WhChatOpenIdUrl")}
                         ?appid={_AppSetting.Get("WhChat:appId")}
                         &secret={_AppSetting.Get("WhChat:appSecret")}
                         &code={code}
                         &grant_type=authorization_code";

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync(url);
                var result = await response.Content.ReadAsStringAsync();

                // 解析返回结果
                var jsonResult = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(result);
                if (jsonResult.ContainsKey("errcode"))
                {
                    // 错误处理
                    string errMsg = jsonResult["errmsg"];
                    return res;
                }

                //提取 OpenID（成功时返回）
                res = jsonResult["openid"];
            }
            return res;
        }
    }
}
