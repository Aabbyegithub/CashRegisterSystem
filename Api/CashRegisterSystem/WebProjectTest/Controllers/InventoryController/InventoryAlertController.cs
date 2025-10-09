using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.InventoryIServices;
using MyNamespace;
using WebProjectTest.Common.Filter;
using SqlSugar;
using static WebProjectTest.Common.Message;
using static ModelClassLibrary.Model.Dto.inventoryDto.inventory;
using Microsoft.AspNetCore.Authorization;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;

namespace CashRegisterSystem.Controllers.Inventory
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class InventoryAlertController(IRedisCacheService redisCacheService, InventoryAlertIServices _service) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取库存预警列表（筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>库存预警", "库存预警列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<InventoryAlertDto>>> GetInventoryAlertList(
            long? storeId,
            long? materialId,
            string? category,
            int pageIndex = 1,
            int pageSize = 10)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetInventoryAlertListAsync(OrgId, storeId, materialId, category, pageIndex, pageSize, totalCount);
        }

        /// <summary>
        /// 采购原材料
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>库存预警", "采购原材料", ActionType.Add)]
        public async Task<ApiResponse<bool>> PurchaseMaterial(long materialId, decimal quantity, string remark)
        {
            return await _service.PurchaseMaterialAsync(materialId, quantity, remark,UserId,OrgId);
        }
    }
}
