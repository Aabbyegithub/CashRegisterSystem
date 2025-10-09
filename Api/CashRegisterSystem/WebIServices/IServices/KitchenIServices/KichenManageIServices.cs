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
    public interface KichenManageIServices : IBaseService
    {
        /// <summary>
        /// 获取厨房
        /// </summary>
        /// <returns></returns>
        Task<List<sys_kitchen>> GetkitchenListAsync(int? storeId, string? kitchenType, int orgId, int page, int size, RefAsync<int> count);

        Task<List<sys_kitchen>> GetAllKichenListAsync();
         
        /// <summary>
        /// 添加厨房
        /// </summary>
        Task<ApiResponse<bool>> AddkitchenAsync(sys_kitchen kitchen);

        /// <summary>
        /// 删除厨房
        /// </summary>
        Task<ApiResponse<bool>> DeleteKitchenAsync(int kitchenId);

        /// <summary>
        /// 修改厨房
        /// </summary>
        Task<ApiResponse<bool>> UpdateKitchenAsync(sys_kitchen kitchen);
    }
}
