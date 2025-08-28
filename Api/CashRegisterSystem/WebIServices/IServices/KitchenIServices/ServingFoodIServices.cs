using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.KitchenIServices
{
    public interface ServingFoodIServices : IBaseService
    {
        Task<ApiPageResponse<List<sys_kitchen_order>>> GetkitchenListAsync(int? storeId, string? kitchenType, int? status, int orgId,string? StartTime,string?EndTime,int page, int size, RefAsync<int> count);
    }
}
