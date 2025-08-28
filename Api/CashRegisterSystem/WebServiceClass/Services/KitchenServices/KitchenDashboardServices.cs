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
                query = query.Where(x => x.kitchen_type == kitchenType);

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
                query = query.Where(x => x.kitchen_type == kitchenType);

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
            var result = 0;
            if (status == 2 || status == 3)
            {
                result = await _dal.Db.Updateable<sys_kitchen_order>()
              .SetColumns(x =>new sys_kitchen_order
              {
                  status = (byte)status,
                  cook_id = userid,
                  finish_time = status == 3 ? DateTime.Now : (DateTime?)null
              })
               .Where(x => x.kitchen_id == kitchenOrderId)
               .ExecuteCommandAsync();
            }
            if (status == 4)
            {
                result = await _dal.Db.Updateable<sys_kitchen_order>()
                    .SetColumns(x =>new sys_kitchen_order
                    {
                        status = (byte)status,
                        picker_id = userid,
                        pick_time = DateTime.Now
                    })
                    .Where(x => x.kitchen_id == kitchenOrderId)
                    .ExecuteCommandAsync();
            }


            return Success(result > 0, result > 0 ? "操作成功" : "操作失败");
        }
    }
}
