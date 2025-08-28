using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.KitchenIServices;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.KitchenServices
{
    public class ServingFoodServices : ServingFoodIServices,IBaseService
    {
        private readonly ISqlHelper _dal;

        public ServingFoodServices(ISqlHelper dal)
        {
            _dal = dal;
        }
        public async Task<ApiPageResponse<List<sys_kitchen_order>>> GetkitchenListAsync(int? storeId, string? kitchenType, int? status, int orgId, string? StartTime, string? EndTime, int page, int size, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_kitchen_order>()
                .Includes(x => x.cook).Includes(x => x.picker).Includes(x => x.orderitem)
                .WhereIF(orgId != 1, x => x.store_id == orgId);

            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);

            if (!string.IsNullOrEmpty(kitchenType))
                query = query.Where(x => x.kitchen_type == kitchenType);

            if (status > 0)
                query = query.Where(x => x.status == status);

            if (!string.IsNullOrEmpty(StartTime) && !string.IsNullOrEmpty(EndTime))
            {
                DateTime startDate, endDate;
                if (DateTime.TryParse(StartTime, out startDate) && DateTime.TryParse(EndTime, out endDate))
                {
                    // Ensure endDate includes the entire day
                    endDate = endDate.AddDays(1).AddTicks(-1);
                    query = query.Where(x => x.create_time >= startDate && x.create_time <= endDate);
                }
            }

            var list = await query.OrderBy(x => x.create_time, OrderByType.Desc) .ToPageListAsync(page, size, count);
            return PageSuccess(list,count, "获取厨房订单成功");
        }
    }
}
