using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.KitchenIServices;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using MyNamespace;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;

namespace WebProjectTest.Controllers.KitchenController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class KitchenDashboardController(IRedisCacheService redisCacheService, KitchenDashboardIServices dashboardService) : AutherController(redisCacheService)
    {
        private readonly KitchenDashboardIServices _dashboardService= dashboardService;
        /// <summary>
        /// 获取厨房订单列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("厨房管理>厨房看板", "厨房订单查询", ActionType.Search)]
        public async Task<ApiResponse<List<sys_kitchen_order>>> GetKitchenOrderList(int? storeId, string? kitchenType, int? status)
        {
            return await _dashboardService.GetkitchenListAsync(storeId, kitchenType, status, OrgId);
        }

        /// <summary>
        /// 统计各状态订单数量
        /// </summary>
        [HttpGet]
        [OperationLogFilter("厨房管理>厨房看板", "订单状态统计", ActionType.Search)]
        public async Task<ApiResponse<Dictionary<int, int>>> GetOrderStatusStats(int? storeId, string? kitchenType)
        {
            return await _dashboardService.GetOrderStatusStatsAsync(storeId, kitchenType, OrgId);
        }

        /// <summary>
        /// 操作订单状态（开始制作、完成、取餐、退菜）
        /// </summary>
        [HttpPost]
        [OperationLogFilter("厨房管理>厨房看板", "订单状态操作", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateOrderStatus(int kitchenOrderId, int status)
        {
            return await _dashboardService.UpdateOrderStatusAsync(kitchenOrderId, status,UserId);
        }
    }
}
