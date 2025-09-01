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
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.OrderServices
{
    public class OrderServices : IBaseService, IOrderServices
    {
        private readonly ISqlHelper _dal;

        public OrderServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
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
                 .Where(x => x.status == 1|| x.status == 2)
                 .WhereIF(tableId.HasValue,x=>x.table_id == tableId)
                 .WhereIF(!string.IsNullOrEmpty(orderno),x=>x.order_no.Contains(orderno))
                 .OrderBy(x => x.created_at, OrderByType.Desc)
                 .ToPageListAsync(page, size, count);
        }

        public Task<List<sys_order>> GetOrderListAsync(int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_order>()
                .WhereIF(orgId != 1, x => x.store_id == orgId)
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
            result.items = res.Select(a => new detail
            {
                orderItemId = (int)a.item_id,
                name = $"{a.dish?.dish_name} ({a.specification})*{a.quantity}",
                price = a.unit_price,
                quantity = a.quantity,
                amount = a.total_price,
                action = a.status == 1 ?"退款":""
            }).ToList();
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
                var table = await _dal.Db.Queryable<sys_restaurant_table>().FirstAsync(a => a.table_id == newTableId);
                var order = await _dal.Db.Queryable<sys_order>().Where(a => a.order_id == orderId || a.order_id == table.order_id).ToListAsync();
                await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a => new sys_restaurant_table { order_id = table.order_id }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
                await _dal.Db.Updateable(new sys_order
                {
                    order_id = (long)table.order_id,
                    total_amount = order.Sum(o => o.total_amount),
                    payable_amount = order.Sum(o => o.payable_amount),
                }).ExecuteCommandAsync();

                var orderitem = await _dal.Db.Queryable<sys_order_item>().Where(a => a.order_id == orderId)
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
                await _dal.Db.Updateable<sys_restaurant_table>()
                    .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.table_id == oldTableId).ExecuteCommandAsync();
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

        /// <summary>
        /// 订单子项退款
        /// </summary>
        /// <param name="orderItemId"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> OrderItemRefund(int orderItemId,int userId)
        {
            await _dal.Db.Updateable<sys_order_item>().SetColumns(a=>new sys_order_item { status = 4,return_audit_id =userId }).Where(a=>a.item_id == orderItemId).ExecuteCommandAsync();
            await _dal.Db.Updateable<sys_kitchen_order>().SetColumns(a => new sys_kitchen_order { status = 5 }).Where(a => a.item_id == orderItemId).ExecuteCommandAsync();
           return Success(true,"退款成功");
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
                var order = await _dal.Db.Queryable<sys_order>().Where(a => a.order_id == orderId).FirstAsync();
                if (order == null)
                {
                    return Fail<bool>("订单不存在");
                }
                await _dal.Db.Ado.BeginTranAsync();
                if (order.status == 1) //待支付状态变为退款
                {
                    await _dal.Db.Updateable<sys_order>()
                    .SetColumns(a => new sys_order { status = 8, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_restaurant_table>()
                        .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_order_item>()
                        .SetColumns(a => new sys_order_item { status = 4, return_audit_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    var itemIds = await _dal.Db.Queryable<sys_order_item>()
                     .Where(a => a.order_id == orderId)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>()
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .In<long>(a => a.item_id,
                        (ISugarQueryable<long>)itemIds)
                        .ExecuteCommandAsync();
                }
                if (order.status == 2) //已下单状态变为取消
                {
                    await _dal.Db.Updateable<sys_order>()
                    .SetColumns(a => new sys_order { status = 4, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_restaurant_table>()
                        .SetColumns(a => new sys_restaurant_table { status = 1, order_id = null }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    await _dal.Db.Updateable<sys_order_item>()
                        .SetColumns(a => new sys_order_item { status = 4, return_audit_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                    var itemIds = await _dal.Db.Queryable<sys_order_item>()
                     .Where(a => a.order_id == orderId)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>()
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .In<long>(a => a.item_id,
                        (ISugarQueryable<long>)itemIds)
                        .ExecuteCommandAsync();
                }
                if (order.status == 6)//预订变为取消
                {
                    await _dal.Db.Updateable<sys_order>()
                    .SetColumns(a => new sys_order { status = 4, operator_id = userId }).Where(a => a.order_id == orderId).ExecuteCommandAsync();
                }
                if (order.status == 3) //已完成状态变为退款
                {
                    await _dal.Db.Updateable<sys_order>()
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
                var order = await _dal.Db.Queryable<sys_order>().FirstAsync(a => a.order_id == orderId);
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
                await _dal.Db.Updateable(order).ExecuteCommandAsync();
                //将订单项状态改为未完成
                await _dal.Db.Updateable<sys_order_item>()
                    .SetColumns(a => new sys_order_item { status = 1, return_audit_id = orderId })
                    .Where(a => a.order_id == orderId).ExecuteCommandAsync();
                //将厨房订单状态改为未完成
                    var itemIds = await _dal.Db.Queryable<sys_order_item>()
                     .Where(a => a.order_id == orderId)
                     .Select(a => a.item_id) // 只选择item_id字段
                     .ToListAsync();
                    await _dal.Db.Updateable<sys_kitchen_order>()
                        .SetColumns(a => new sys_kitchen_order { status = 5 })
                        .In<long>(a => a.item_id,
                        (ISugarQueryable<long>)itemIds)
                        .ExecuteCommandAsync();
                await _dal.Db.Updateable<sys_restaurant_table>()
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
    }
}
