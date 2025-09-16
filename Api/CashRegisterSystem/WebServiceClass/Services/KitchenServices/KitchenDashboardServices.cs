using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.KitchenIServices;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.KitchenServices
{
    public class KitchenDashboardServices : KitchenDashboardIServices,IBaseService
    {
        private readonly ISqlHelper _dal;

        public KitchenDashboardServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiResponse<List<sys_kitchen_order>>> GetkitchenListAsync(int? storeId, string? kitchenType, int? status, int orgId)
        {
            var query = _dal.Db.Queryable<sys_kitchen_order>()
                .WhereIF(orgId!=1, x => x.store_id == orgId);

            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);

            if (!string.IsNullOrEmpty(kitchenType))
                query = query.Where(x => x.kitchen_type.Contains(kitchenType));

            if (status > 0)
                query = query.Where(x => x.status == status);

            var list = await query.OrderBy(x => x.create_time, OrderByType.Desc).ToListAsync();
            return Success(list, "获取厨房订单成功");
        }

        public async Task<ApiResponse<Dictionary<int, int>>> GetOrderStatusStatsAsync(int? storeId, string? kitchenType, int orgId)
        {
            var query = _dal.Db.Queryable<sys_kitchen_order>()
                  .WhereIF(orgId!=1, x => x.store_id == orgId);

            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);

            if (!string.IsNullOrEmpty(kitchenType))
                query = query.Where(x => x.kitchen_type.Contains(kitchenType));

            var stats = await query.GroupBy(x => x.status)
                .Select(x => new { Status = x.status, Count = SqlFunc.AggregateCount(x.kitchen_id) })
                .ToListAsync();

            var result = new Dictionary<int, int>();
            foreach (var item in stats)
            {
                result[item.Status] = item.Count;
            }
            return Success(result, "统计成功");
        }

        public async Task<ApiResponse<bool>> UpdateOrderStatusAsync(int kitchenOrderId, int status, int userid)
        {
            try
            {
                var validStatusTransitions = new Dictionary<byte, List<int>>
                {
                    { 0, new List<int> { 2 } },
                    { 2, new List<int> { 3 } },
                    { 3, new List<int> { 4 } }
                };
                await _dal.Db.Ado.BeginTranAsync();
                var result = 0;
                var kitchenOrder = await _dal.Db.Queryable<sys_kitchen_order>()
                    .With(SqlWith.UpdLock) // MySQL：FOR UPDATE 行锁，锁定当前厨房订单
                    .FirstAsync(x => x.kitchen_id == kitchenOrderId);

                if (kitchenOrder == null)
                {
                    await _dal.Db.Ado.RollbackTranAsync();
                    return Fail<bool>("厨房订单不存在，操作失败");
                }

                //// 2. 校验状态流转合法性（仅允许业务规则内的状态更新）
                //if (!validStatusTransitions.TryGetValue(kitchenOrder.status, out var allowedTargetStatuses)
                //    || !allowedTargetStatuses.Contains(status))
                //{
                //    await _dal.Db.Ado.RollbackTranAsync();
                //    return Fail<bool>($"当前订单状态为【{GetStatusName(kitchenOrder.status)}】，不允许更新为【{GetStatusName(status)}】");
                //}
                if (status == 2 || status == 3)
                {
                    result = await _dal.Db.Updateable<sys_kitchen_order>()
                  .SetColumns(x => new sys_kitchen_order
                  {
                      status = (byte)status,
                      cook_id = userid,
                      finish_time = status == 3 ? DateTime.Now : (DateTime?)null
                  })
                   .Where(x => x.kitchen_id == kitchenOrderId)
                   .ExecuteCommandAsync();
                    //开始制作扣掉库存
                    if (status == 2)
                    {
                        var kitchen = await _dal.Db.Queryable<sys_kitchen_order>()
                            .Includes(a => a.orderitem, b => b.dish, c => c.dish_formula).With(SqlWith.UpdLock).FirstAsync(a=>a.kitchen_id ==kitchenOrderId );
                        if (kitchen?.orderitem?.dish?.dish_formula == null
                            || !kitchen.orderitem.dish.dish_formula.Any())
                        {
                            await _dal.Db.Ado.RollbackTranAsync();
                            return Fail<bool>("该菜品无食材配方，无法扣减库存");
                        }
                        foreach (var item in kitchen.orderitem.dish.dish_formula)
                        {
                            var inventorysum = await GetMaterialCurrentStock(kitchen.store_id, item.material_id);
                             var material = await _dal.Db.Queryable<sys_raw_material>().FirstAsync(a=>a.material_id == item.material_id);
                            if (inventorysum <  item.consumption )
                            {
                                await _dal.Db.Ado.RollbackTranAsync();
                               
                                return Fail<bool>($"食材【{material.material_name}】库存不足，当前库存：{inventorysum}，需消耗：{item.consumption}");
                            }
                            var inventoryList = await _dal.Db.Queryable<sys_inventory>().With(SqlWith.UpdLock).Where(a =>a.store_id ==kitchen.store_id &&  a.material_id == item.material_id && a.quantity > 0).OrderBy(a => a.quantity).ToListAsync();
                            if (!inventoryList.Any())
                            {
                                await _dal.Db.Ado.RollbackTranAsync();
                                return Fail<bool>($"食材【{material.material_name}】库存不足，无法扣减");
                            }
                            decimal remainingToDeduct = item.consumption;
                            var deductedInventories = new List<sys_inventory>();

                            foreach (var inventory in inventoryList)
                            {
                                if (remainingToDeduct <= 0) break; // 已扣减完成

                                // 本次可扣减的数量（不超过当前库存和剩余需扣量）
                                decimal deductAmount = Math.Min(inventory.quantity, remainingToDeduct);

                                // 执行扣减
                                inventory.quantity -= deductAmount;
                                inventory.out_quantity += deductAmount; 
                                deductedInventories.Add(inventory);

                                // 更新剩余需扣减量
                                remainingToDeduct -= deductAmount;
                            }
                            if (deductedInventories.Any())
                            {
                                await _dal.Db.Updateable(deductedInventories).ExecuteCommandAsync();
                            }
                        }
                        result = await _dal.Db.Updateable<sys_kitchen_order>()
                                .SetColumns(x => new sys_kitchen_order
                                {
                                    status = (byte)status,
                                    picker_id = userid,
                                    pick_time = DateTime.Now
                                })
                                .Where(x => x.kitchen_id == kitchenOrderId)
                                .ExecuteCommandAsync();
                        await _dal.Db.Updateable<sys_order_item>()
                            .SetColumns(a => new sys_order_item { status = 3 }).Where(a => a.item_id == kitchen.item_id).ExecuteCommandAsync();
                    }
                }
                if (status == 4)
                {
                    result = await _dal.Db.Updateable<sys_kitchen_order>()
                        .SetColumns(x => new sys_kitchen_order
                        {
                            status = (byte)status,
                            picker_id = userid,
                            pick_time = DateTime.Now
                        })
                        .Where(x => x.kitchen_id == kitchenOrderId)
                        .ExecuteCommandAsync();
                    var kitchenorder = await _dal.Db.Queryable<sys_kitchen_order>().FirstAsync(a=>a.kitchen_id == kitchenOrderId);
                    await _dal.Db.Updateable<sys_order_item>()
                        .SetColumns(a => new sys_order_item { status = 3 }).Where(a => a.item_id == kitchenorder.item_id).ExecuteCommandAsync();
                }
                  await _dal.Db.Ado.CommitTranAsync();
                return Success(result > 0, result > 0 ? "操作成功" : "操作失败");
            }
            catch (Exception e)
            {

                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>($"操作失败！{e.Message}");
            }
        }

        private string GetStatusName(int status)
        {
            return status switch
            {
                0 => "待分配",
                2 => "开始制作",
                3 => "制作完成",
                4 => "已取餐",
                _ => $"未知状态（{status}）"
            };
        }

        private async Task<decimal> GetMaterialCurrentStock(long storeId, long materialId)
        {
            var inventory = await _dal.Db.Queryable<sys_inventory>()
                .Where(a => a.store_id == storeId && a.material_id == materialId).GroupBy(a => new { a.store_id, a.material_id })
                    .Select(a => new
                    {
                        StoreId = a.store_id,
                        MaterialId = a.material_id,
                        TotalQuantity = SqlFunc.AggregateSum(a.quantity) // 使用ORM的Sum函数计算总库存
                    })
                .FirstAsync();
            return inventory?.TotalQuantity ?? 0;
        }
    }
}
