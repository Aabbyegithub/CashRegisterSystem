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
    public interface PurchaseOrderIServices : IBaseService
    {
        /// <summary>
        /// 获取采购单列表（筛选+分页）
        /// </summary>
        Task<ApiPageResponse<List<sys_purchase_order>>> GetPurchaseOrderListAsync(
            int orgId,
            long? storeId,
            string? poNo,
            long? supplierId,
            byte? status,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount);

        /// <summary>
        /// 新增采购单
        /// </summary>
        Task<ApiResponse<bool>> AddPurchaseOrderAsync(sys_purchase_order order);

        /// <summary>
        /// 采购单详情
        /// </summary>
        Task<ApiResponse<sys_purchase_order>> GetPurchaseOrderDetailAsync(long poId);

        /// <summary>
        /// 取消采购单
        /// </summary>
        Task<ApiResponse<bool>> CancelPurchaseOrderAsync(long poId);

        /// <summary>
        /// 确认到货
        /// </summary>
        /// <param name="poId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> ArrivedPurchaseOrderAsync(long poId);

        /// <summary>
        /// 统一采购
        /// </summary>
        /// <param name="poId"></param>
        /// <param name="supplier_id"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> SavePurchaseOrderAsync(long poId, long supplier_id);
    }
}
