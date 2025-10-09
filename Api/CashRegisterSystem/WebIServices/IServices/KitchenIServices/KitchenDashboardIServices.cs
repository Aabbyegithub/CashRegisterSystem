using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.KitchenIServices
{
    public interface KitchenDashboardIServices : IBaseService
    {
        /// <summary>
        /// 获取厨房订单列表（支持筛选）
        /// </summary>
        Task<ApiResponse<List<sys_kitchen_order>>> GetkitchenListAsync(int? storeId, string? kitchenType, int? status, int orgId);

        /// <summary>
        /// 统计各状态订单数量
        /// </summary>
        Task<ApiResponse<Dictionary<int, int>>> GetOrderStatusStatsAsync(int? storeId, string? kitchenType, int orgId);

        /// <summary>
        /// 操作订单状态（开始制作、完成、取餐、退菜）
        /// </summary>
        Task<ApiResponse<bool>> UpdateOrderStatusAsync(int kitchenOrderId, int status, int userid);
    }
}
