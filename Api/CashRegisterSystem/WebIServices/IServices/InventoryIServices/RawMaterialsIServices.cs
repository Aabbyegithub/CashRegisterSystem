using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using MyNamespace;
using static WebProjectTest.Common.Message;
using SqlSugar;

namespace WebIServices.IServices.InventoryIServices
{
    public interface RawMaterialsIServices : IBaseService
    {
        /// <summary>
        /// 获取原材料列表（筛选+分页）
        /// </summary>
        Task<ApiPageResponse<List<sys_raw_material>>> GetRawMaterialListAsync(int orgId,
            long? storeId, string? name, string? category, byte? status,
            int pageIndex, int pageSize, RefAsync<int> totalCount);

        Task<ApiResponse<List<sys_raw_material>>> GetRawMaterialListAsync(int orgId);

        /// <summary>
        /// 新增原材料
        /// </summary>
        Task<ApiResponse<bool>> AddRawMaterialAsync(sys_raw_material material);

        /// <summary>
        /// 编辑原材料
        /// </summary>
        Task<ApiResponse<bool>> UpdateRawMaterialAsync(sys_raw_material material);

        /// <summary>
        /// 启用/禁用原材料
        /// </summary>
        Task<ApiResponse<bool>> ChangeStatusAsync(long materialId, byte status);
    }
}
