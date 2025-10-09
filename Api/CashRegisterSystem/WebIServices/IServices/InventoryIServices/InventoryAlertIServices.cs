using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using MyNamespace;
using SqlSugar;
using static WebProjectTest.Common.Message;
using static ModelClassLibrary.Model.Dto.inventoryDto.inventory;

namespace WebIServices.IServices.InventoryIServices
{
    public interface InventoryAlertIServices : IBaseService
    {
        /// <summary>
        /// 获取库存预警列表（筛选+分页）
        /// </summary>
        Task<ApiPageResponse<List<InventoryAlertDto>>> GetInventoryAlertListAsync(
            int orgId,
            long? storeId,
            long? materialId,
            string? category,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount);

        /// <summary>
        /// 采购原材料
        /// </summary>
        Task<ApiResponse<bool>> PurchaseMaterialAsync(long materialId, decimal quantity, string remark,int userId,int orgId);
    }
}
