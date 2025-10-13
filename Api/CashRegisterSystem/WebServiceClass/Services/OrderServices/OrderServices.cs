using Microsoft.EntityFrameworkCore.Metadata.Internal;
using ModelClassLibrary.Model.Dto.OrderDto;
using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.OrderIServices;
using WebServiceClass.Helper.WeChat;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.OrderServices
{
    public class OrderServices : IBaseService, IOrderServices
    {
        private readonly ISqlHelper _dal;
        private readonly WeChatPayHelper _weChatPayHelper;

        public OrderServices(ISqlHelper dal, WeChatPayHelper weChatPayHelper)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
            _weChatPayHelper = weChatPayHelper ?? throw new ArgumentNullException();
        }

        public async Task<ApiResponse<bool>> AddOrderAsync(sys_order order)
        {
            try
            {
                await _dal.Db.Insertable(order).ExecuteCommandAsync();
                return Success(true, "添加订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"添加订单失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<bool>> DeleteOrderAsync(List<int> orderIds)
        {
            try
            {
                await _dal.Db.Deleteable<sys_order>().In(orderIds).ExecuteCommandAsync();
                return Success(true, "删除订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"删除订单失败:{ex.Message}");
            }
        }

        public Task<List<sys_order>> GetNotCheckoutOrderListAsync(int? tableId,string? orderno, int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_order>().Includes(x=>x.table)
                 .WhereIF(orgId != 1, x => x.store_id == orgId)
                 .Where(x => x.status == 1|| x.status == 2 || x.status == 5)
                 .WhereIF(tableId.HasValue,x=>x.table_id == tableId)
                 .WhereIF(!string.IsNullOrEmpty(orderno),x=>x.order_no.Contains(orderno))
                 .OrderBy(x => x.created_at, OrderByType.Desc)
                 .ToPageListAsync(page, size, count);
        }

        public Task<List<sys_order>> GetOrderListAsync(int? store_Id, string? OrdderNo, int? tableId, int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_order>().Includes(a =>a.orderitem,b=>b.dish).Includes(a=>a.table).Includes(a=>a.Staff)
                .WhereIF(orgId != 1, x => x.store_id == orgId)
                .WhereIF(store_Id.HasValue, x => x.store_id == store_Id)
                .WhereIF(!string.IsNullOrEmpty(OrdderNo), x => x.order_no.Contains(OrdderNo))
                .WhereIF(tableId.HasValue, x => x.table_id == tableId)
                .OrderBy(x => x.created_at, OrderByType.Desc)
                .ToPageListAsync(page, size, count);
        }

        public async Task<ApiResponse<bool>> UpdateOrderAsync(sys_order order)
        {
            try
            {
                await _dal.Db.Updateable(order).ExecuteCommandAsync();
                return Success(true, "修改订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"修改订单失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<OrderDetailModel>> OrderDetails(int orderId)
        {
            var res = await _dal.Db.Queryable<sys_order_item>()
                .Includes(a => a.dish)
                .Where(a => a.order_id == orderId).ToListAsync();

            var order = await _dal.Db.Queryable<sys_order>().Includes(a => a.table).FirstAsync(a => a.order_id == orderId);
            var result = new OrderDetailModel();
            result.orderId =(int) order.order_id;
            result.tableId = (int) order.table?.table_id;
            result.tableNumber = order.table?.table_no;
            result.desc = order.table?.desc;
            result.totalAmount = order.total_amount;
            result.receivedAmount = order.payable_amount;
            result.zeroAmount =(decimal)0.00;
            result.orderNumber = order.order_no;
            result.createTime = order.start_time;
            result.table_capacity = order.table_capacity;
            result.items = res.GroupBy(x => new { x.dish_id, x.specification })
                        .Select(g => new detail
                        {
                            orderItemId = string.Join(",", g.Select(x => x.item_id)), // 拼接多个 item_id
                            name = !string.IsNullOrEmpty(g.Key.specification)
                                ? $"{g.First().dish?.dish_name} ({g.Key.specification})*{g.Sum(x => x.quantity)}"
                                : $"{g.First().dish?.dish_name} *{g.Sum(x => x.quantity)}",
                            price = g.First().unit_price,
                            quantity = g.Sum(x => x.quantity),
                            amount = g.Sum(x => x.total_price),
                            action = g.All(x => x.status == 4) ? "已退款" : "退款"
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


        /// <summary>
        /// 并桌--不更新桌台状态
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> MergeTables(int oldTableId, int newTableId, int orderId, string? remark)
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
                    type = 2,
                    remark = remark
                }).ExecuteCommandAsync();
                var table = await _dal.Db.Queryable<sys_restaurant_table>().With(SqlWith.UpdLock).FirstAsync(a => a.table_id == newTableId);
                var order = await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).Where(a => a.order_id == orderId || a.order_id == table.order_id).ToListAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a => new sys_restaurant_table { order_id = table.order_id }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable(new sys_order
                {
                    order_id = (long)table.order_id,
                    total_amount = order.Sum(o => o.total_amount),
                    payable_amount = order.Sum(o => o.payable_amount),
                }).ExecuteCommandAsync();

                var orderitem = await _dal.Db.Queryable<sys_order_item>().Where(a => a.order_id == orderId).With(SqlWith.UpdLock)
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
        public async Task<ApiResponse<bool>> ChangeTables(int oldTableId, int newTableId, int orderId, string? remark)
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
                    type = 1,
                    remark = remark
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
        /// 订单子项退款
        /// </summary>
        /// <param name="orderItemId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> OrderItemRefund(string orderItemId,int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var orderItemIds = orderItemId.Split(',');
                await _dal.Db.Updateable<sys_order_item>().With(SqlWith.UpdLock).SetColumns(a => new sys_order_item { status = 4, return_audit_id = userId }).Where(a => orderItemIds.Contains(a.item_id.ToString())).ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_kitchen_order>().With(SqlWith.UpdLock).SetColumns(a => new sys_kitchen_order { status = 5 }).Where(a => orderItemIds.Contains(a.item_id.ToString())).ExecuteCommandAsync();
                var order = await _dal.Db.Queryable<sys_order_item>().Where(a => orderItemIds.Contains(a.item_id.ToString())).ToListAsync();
                await _dal.Db.Updateable<sys_order>().SetColumns(a=>new sys_order { payable_amount =a.payable_amount- order.Sum(a=>a.total_price)})
                    .Where(a => a.order_id == order.FirstOrDefault().order_id).ExecuteCommandAsync();
                if (await _dal.Db.Queryable<sys_order_item>().Where(a => a.order_id == order.FirstOrDefault().order_id && a.status != 4).CountAsync() == 0)
                {
                    await _dal.Db.Updateable<sys_order>().SetColumns(a => new sys_order { status = 8 }).Where(a => a.order_id == order.FirstOrDefault().order_id).ExecuteCommandAsync();
                    var orderid = await _dal.Db.Queryable<sys_order>().FirstAsync(a => a.order_id == order.FirstOrDefault().order_id);
                    await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_restaurant_table { status = 4, order_id = null, lastUseTime = DateTime.Now }).Where(a => a.table_id == orderid.table_id).ExecuteCommandAsync();
                }
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "退款成功");
            }
            catch (Exception)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>( "退款失败");
            }
        }

        /// <summary>
        /// 订单退款
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> OrderRefund(int orderId,int userId)
        {
            try
            {
                var order = await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).Where(a => a.order_id == orderId).FirstAsync();
                if (order == null)
                {
                    return Fail<bool>("订单不存在");
                }
                await _dal.Db.Ado.BeginTranAsync();
                if (order.status == 1) //待支付状态变为退款
                {
                    await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_order { status = 8, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_order_item>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_order_item { status = 4, return_audit_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    var itemIds = await _dal.Db.Queryable<sys_order_item>().With(SqlWith.UpdLock)
                     .Where(a => a.order_id == orderId)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>()
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .Where(a => itemIds.Contains(a.item_id))
                        .ExecuteCommandAsync();
                }
                if (order.status == 2) //已下单状态变为取消
                {
                    await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_order { status = 4, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_order_item>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_order_item { status = 4, return_audit_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    var itemIds = await _dal.Db.Queryable<sys_order_item>().With(SqlWith.UpdLock)
                     .Where(a => a.order_id == orderId)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .Where(a=> itemIds.Contains(a.item_id))
                        .ExecuteCommandAsync();
                }
                if (order.status == 6)//预订变为取消
                {
                    await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_order { status = 4, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                }
                if (order.status == 3) //已完成状态变为退款
                {
                    await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_order { status = 8, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();

                    //原路径退款
                }
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "退款成功");
            }
            catch (Exception)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>("退款失败");
            }
        }

        /// <summary>
        /// 订单重做
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> OrderRedo(int orderId, int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var order = await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).FirstAsync(a => a.order_id == orderId);
                if (order == null)
                {
                    return Fail<bool>("订单不存在");
                }
                if (order.status == 4 || order.status == 4 ) 
                {
                    return Fail<bool>("已完成或已取消的订单不可以重做");
                }
                order.status = 2; //将订单状态改为已下单
                order.operator_id = userId;
                await _dal.Db.Updateable(order).With(SqlWith.UpdLock).ExecuteCommandAsync();
                //将订单项状态改为未完成
                await _dal.Db.Updateable<sys_order_item>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_order_item { status = 1, return_audit_id = orderId })
                    .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                //将厨房订单状态改为未完成
                    var itemIds = await _dal.Db.Queryable<sys_order_item>().With(SqlWith.UpdLock)
                     .Where(a => a.order_id == orderId && a.status ==3)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>().With(SqlWith.UpdLock)
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .Where(a => itemIds.Contains(a.item_id))
                        .ExecuteCommandAsync(); 
                await _dal.Db.Updateable<sys_restaurant_table>().With(SqlWith.UpdLock)
                    .SetColumns(a => new sys_restaurant_table { status = 2, order_id = orderId })
                    .Where(a => a.table_id == order.table_id).ExecuteCommandAsync();
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "订单重做成功");
            }
            catch (Exception ex)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Error<bool>($"订单重做失败:{ex.Message}");
            }
        }

        /// <summary>
        /// 订单结算
        /// </summary>
        /// <param name="orderId"></param>
        /// <param name="CouponsId"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public Task<ApiResponse<bool>> OrderCheckout(int orderId, int? CouponsId, string type, int userId)
        {
            throw new NotImplementedException();
        }

        public async Task<ApiResponse<bool>> ReserveOrderAsync(sys_reservation orderreservation,int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                orderreservation.reservation_no = DateTime.Now.ToString("yyyyMMddHHmmssfff")+new Random().Next(100000, 999999);
                var ReserveId = await _dal.Db.Insertable(orderreservation).ExecuteReturnBigIdentityAsync();
                var table = await _dal.Db.Queryable<sys_restaurant_table>().With(SqlWith.UpdLock)
                        .Where(a => a.table_id == orderreservation.table_id && a.status ==1)
                        .FirstAsync();
                if (table == null)
                {
                    throw new Exception("桌台不可用！");
                }
                var orderId = await _dal.Db.Insertable(new sys_order
                {
                    store_id = orderreservation.store_id,
                    table_id = orderreservation.table_id,
                    order_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") +new Random().Next(100000, 999999),
                    order_type = 1, // 堂食
                    source_type = 3, // 下单方式
                    status = 6,// 已下单
                    discount_amount = 0, // 优惠金额
                    service_fee = 0, // 服务费
                    total_amount = 0,
                    payable_amount = 0,
                    table_fee = table.min_consumption, // 桌台费
                    start_time = DateTime.Now,
                    is_split = 0, // 是否分单
                    operator_id = userId, // 操作员ID  0默认用户
                    table_capacity = orderreservation.reservation_capacity
                }).ExecuteReturnBigIdentityAsync();

                await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a => new sys_restaurant_table { status = 3, order_id = (int)orderId })
                     .Where(a => a.table_id == orderreservation.table_id).ExecuteCommandAsync();

                await _dal.Db.Ado.CommitTranAsync();
                return Success(true);
            }
            catch (Exception)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Success(false);
            }

        }

        public async Task<ApiResponse<bool>> HangOrderAsync(int order,int userId)
        {
            var orderData =await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).FirstAsync(a=>a.order_id ==order);
            if (orderData.member_id.HasValue)
            {
               var member = await _dal.Db.Queryable<sys_member>().With(SqlWith.UpdLock).FirstAsync(a => a.member_id == orderData.member_id && a.status == 1);
                //会员确保剩余金额充足
                if (member != null && member.member_id != 0)
                {

                    if (member.balance <= orderData.payable_amount)
                    {
                        return Fail<bool>("会员剩余金额不足，不可挂单");
                    }
                }
            }
            else
            {
                 return Fail<bool>("非会员不可挂单");
            }

            await _dal.Db.Updateable<sys_order>().With(SqlWith.UpdLock).SetColumns(a =>new sys_order { status = 5,operator_id = userId}).Where(a => a.order_id == order).ExecuteCommandAsync();
            return Success(true);
        }

        public async Task<ApiResponse<bool>> RefundOrderAsync(int order, int userId)
        {
            var orderData =await _dal.Db.Queryable<sys_order>().With(SqlWith.UpdLock).FirstAsync(a=>a.order_id ==order);
            var sys_payment = await _dal.Db.Queryable<sys_payment>().With(SqlWith.UpdLock).FirstAsync(a=>a.order_id ==order && a.status ==2);
            if (orderData == null)
            {
                return Fail<bool>($"原订单{orderData.order_no}不存在");
            }

            if (orderData.status != 3) // 3=已支付状态（根据实际枚举调整）
            {
                return Fail<bool>($"订单状态异常，无法退款");
            }

            // 验证退款金额（不能超过订单实付金额）
            if (sys_payment.pay_amount <= orderData.payable_amount)
            {
                return Fail<bool>($"退款金额不能超过订单实付金额（{orderData.payable_amount}元）");
            }

            // 6. 检查是否已有退款记录（避免重复退款）
            var existingRefund = await _dal.Db.Queryable<sys_payment>()
                .FirstAsync(r => r.order_id == order && (r.status ==4 || r.status == 5));

            if (existingRefund != null)
            {
                return Fail<bool>("当前订单已有处理中的退款，请等待结果");
            }
            bool isSuccess = false;
            //  生成唯一退款单号（格式：REF+时间戳+随机数）
            string refundNo = $"REF{DateTime.Now:yyyyMMddHHmmssfff}{new Random().Next(1000, 9999)}";
            try
            {
                await _dal.Db.Ado.BeginTranAsync();

                // 创建退款记录（初始状态：处理中）
               var paymentId = await _dal.Db.Insertable(new sys_payment
                {
                    order_id = order,
                    payment_no =refundNo,
                    pay_amount = sys_payment.pay_amount,
                    pay_type =(byte)(orderData.paymeth =="微信支付" ? 1:2),
                    status = 4,
                    pay_time = DateTime.Now,
                    remark = "订单退款"

                }).ExecuteReturnBigIdentityAsync();

                // 9. 调用微信退款接口
                var refundResult = _weChatPayHelper.Refund(
                    orderNo: orderData.order_no,
                    refundNo: refundNo,
                    totalAmount: orderData.payable_amount,
                    refundAmount: sys_payment.pay_amount,
                    refundDesc: "客户退款"
                );
                var payment = await _dal.Db.Queryable<sys_payment>().With(SqlWith.UpdLock).FirstAsync(a=>a.payment_id == paymentId);
                // 10. 处理微信退款结果
                if (refundResult.ContainsKey("result_code") && refundResult["result_code"] == "SUCCESS")
                {
                    // 退款成功：更新退款记录和订单状态
                    string refundId = refundResult["refund_id"]; // 微信退款单号
                    payment.status = 5; // 5=退款成功
                    payment.transaction_id = refundId;
                    payment.pay_time = DateTime.Now;
                    payment.response_data = Newtonsoft.Json.JsonConvert.SerializeObject(refundResult);

                    // 更新订单状态（标记为已退款）
                    orderData.status = 8; // 8=已退款
                    orderData.pay_time = DateTime.Now;
                    orderData.operator_id = userId;
                    await _dal.Db.Updateable(orderData).ExecuteCommandAsync();
                    isSuccess = true;
                }
                else
                {
                    // 退款失败：记录错误信息
                    string errCode = refundResult.ContainsKey("err_code") ? refundResult["err_code"] : "未知错误";
                    string errMsg = refundResult.ContainsKey("err_code_des") ? refundResult["err_code_des"] : "退款失败";

                    payment.status = 6; // 3=退款失败
                    payment.fail_reason = $"{errCode}：{errMsg}";
                    payment.response_data = Newtonsoft.Json.JsonConvert.SerializeObject(refundResult);
                }

                // 11. 更新退款记录
                await _dal.Db.Updateable(payment).ExecuteCommandAsync();
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true,"退款成功");
            }
            catch (Exception ex)
            {
                // 异常回滚
                await _dal.Db.Ado.RollbackTranAsync();

                return Fail<bool>($"退款处理异常：{ex.Message.Substring(0, 50)}");
            }

        }
    }
}
