using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using SqlSugar;
using MyNamespace;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.InventoryIServices
{
    public interface LossIServices : IBaseService
    {
        /// <summary>
        /// 获取损耗记录列表（筛选+分页）
        /// </summary>
        Task<ApiPageResponse<List<sys_inventory_loss>>> GetLossListAsync(
            int orgId,
            long? storeId,
            long? materialId,
            int? lossType,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount);

        /// <summary>
        /// 新增损耗记录
        /// </summary>
        Task<ApiResponse<bool>> AddLossAsync(sys_inventory_loss loss,int orgId,int userId);

        Task<ApiResponse<bool>> UpdateLossAsync(sys_inventory_loss loss, int userId);

        Task<ApiResponse<bool>> DelLossDetailAsync(long lossId);

        /// <summary>
        /// 获取损耗详情
        /// </summary>
        Task<ApiResponse<sys_inventory_loss>> GetLossDetailAsync(long lossId);
    }
}
