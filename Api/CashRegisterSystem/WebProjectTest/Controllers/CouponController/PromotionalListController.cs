using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;

namespace WebProjectTest.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class PromotionController(IRedisCacheService redisCacheService, PromotionIServices _promotionService) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 获取促销活动列表（分页+筛选）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("促销管理>促销活动", "促销活动列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_promotion>>> GetPromotionList(long? storeId, string? name, byte? type, byte? status, int pageIndex = 1, int pageSize = 10)
        {
            RefAsync<int> count = 0;
            return await _promotionService.GetPromotionListAsync(storeId, name, type, status, pageIndex, pageSize,OrgId, count);
        }

        /// <summary>
        /// 获取促销活动详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("促销管理>促销活动", "促销活动详情查询", ActionType.Search)]
        public async Task<ApiResponse<sys_promotion>> GetPromotionById(long promotionId)
        {
            return await _promotionService.GetPromotionByIdAsync(promotionId);
        }

        /// <summary>
        /// 新增促销活动
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>促销活动", "新增促销活动", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddPromotion([FromBody] sys_promotion promotion)
        {
            return await _promotionService.AddPromotionAsync(promotion);
        }

        /// <summary>
        /// 编辑促销活动
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>促销活动", "编辑促销活动", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdatePromotion([FromBody] sys_promotion promotion)
        {
            return await _promotionService.UpdatePromotionAsync(promotion);
        }

        /// <summary>
        /// 删除促销活动
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>促销活动", "删除促销活动", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeletePromotion([FromBody] long promotionId)
        {
            return await _promotionService.DeletePromotionAsync(promotionId);
        }
    }
}
