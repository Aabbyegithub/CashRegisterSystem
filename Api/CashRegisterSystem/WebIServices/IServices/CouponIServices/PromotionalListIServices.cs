using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices
{
    public interface PromotionIServices
    {
        /// <summary>
        /// 获取促销活动列表（分页+筛选）
        /// </summary>
        Task<ApiPageResponse<List<sys_promotion>>> GetPromotionListAsync(long? storeId, string? name, byte? type, byte? status, int pageIndex, int pageSize,int orgId, RefAsync<int> count);

        /// <summary>
        /// 获取促销活动详情
        /// </summary>
        Task<ApiResponse<sys_promotion>> GetPromotionByIdAsync(long promotionId);

        /// <summary>
        /// 新增促销活动
        /// </summary>
        Task<ApiResponse<bool>> AddPromotionAsync(sys_promotion promotion);

        /// <summary>
        /// 编辑促销活动
        /// </summary>
        Task<ApiResponse<bool>> UpdatePromotionAsync(sys_promotion promotion);

        /// <summary>
        /// 删除促销活动
        /// </summary>
        Task<ApiResponse<bool>> DeletePromotionAsync(long promotionId);
    }
}
