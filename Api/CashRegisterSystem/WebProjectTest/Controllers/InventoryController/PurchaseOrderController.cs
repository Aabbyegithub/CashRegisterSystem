using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.InventoryIServices;
using MyNamespace;
using WebProjectTest.Common.Filter;
using SqlSugar;
using static WebProjectTest.Common.Message;
using Microsoft.AspNetCore.Authorization;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;

namespace CashRegisterSystem.Controllers.Inventory
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class PurchaseOrderController(IRedisCacheService redisCacheService, PurchaseOrderIServices _service) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取采购单列表（筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>采购单管理", "采购单列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_purchase_order>>> GetPurchaseOrderList(
            long? storeId,
            string? poNo,
            long? supplierId,
            byte? status,
            int pageIndex = 1,
            int pageSize = 10)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetPurchaseOrderListAsync(OrgId, storeId, poNo, supplierId, status, pageIndex, pageSize, totalCount);
        }

        /// <summary>
        /// 新增采购单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>采购单管理", "新增采购单", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddPurchaseOrder([FromBody] sys_purchase_order order)
        {
            return await _service.AddPurchaseOrderAsync(order);
        }

        /// <summary>
        /// 采购单详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>采购单管理", "采购单详情", ActionType.Search)]
        public async Task<ApiResponse<sys_purchase_order>> GetPurchaseOrderDetail(long poId)
        {
            return await _service.GetPurchaseOrderDetailAsync(poId);
        }

        /// <summary>
        /// 取消采购单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>采购单管理", "取消采购单", ActionType.Edit)]
        public async Task<ApiResponse<bool>> CancelPurchaseOrder(long poId)
        {
            return await _service.CancelPurchaseOrderAsync(poId);
        }

        /// <summary>
        ///确认收货采购单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>采购单管理", "采购单确认收货", ActionType.Edit)]
        public async Task<ApiResponse<bool>> ArrivedPurchaseOrderAsync(long poId)
        {
            return await _service.ArrivedPurchaseOrderAsync(poId);
        }


        /// <summary>
        ///采购单审核
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>采购单管理", "采购单审核", ActionType.Edit)]
        public async Task<ApiResponse<bool>> SavePurchaseOrderAsync(long poId, long supplier_id)
        {
            return await _service.SavePurchaseOrderAsync(poId,supplier_id);
        }

    }
}
