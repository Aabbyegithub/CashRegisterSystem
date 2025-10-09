using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using MyNamespace;
using SqlSugar;

namespace WebProjectTest.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class CouponController(IRedisCacheService redisCacheService, CouponIServices _couponService) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 获取优惠券列表（分页+筛选）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("促销管理>优惠券管理", "优惠券列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_coupon>>> GetCouponList(long? storeId, string? name, byte? type, byte? status, int pageIndex = 1, int pageSize = 10)
        {
            RefAsync<int> count = 0;
            return await _couponService.GetCouponListAsync(storeId, name, type, status, pageIndex, pageSize,OrgId, count);
        }

        /// <summary>
        /// 获取优惠券详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("促销管理>优惠券管理", "优惠券详情查询", ActionType.Search)]
        public async Task<ApiResponse<sys_coupon>> GetCouponById(long couponId)
        {
            return await _couponService.GetCouponByIdAsync(couponId);
        }

        /// <summary>
        /// 新增优惠券
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>优惠券管理", "新增优惠券", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddCoupon([FromBody] sys_coupon coupon)
        {
            return await _couponService.AddCouponAsync(coupon);
        }

        /// <summary>
        /// 编辑优惠券
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>优惠券管理", "编辑优惠券", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateCoupon([FromBody] sys_coupon coupon)
        {
            return await _couponService.UpdateCouponAsync(coupon);
        }


        /// <summary>
        /// 删除优惠券
        /// </summary>
        [HttpPost]
        [OperationLogFilter("促销管理>优惠券管理", "删除优惠券", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteCoupon([FromBody] long couponId)
        {
            return await _couponService.DeleteCouponAsync(couponId);
        }
    }
}
