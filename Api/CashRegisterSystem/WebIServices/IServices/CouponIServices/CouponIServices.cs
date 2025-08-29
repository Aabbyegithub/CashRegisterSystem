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
    public interface CouponIServices : IBaseService
    {
        /// <summary>
        /// 获取优惠券列表（分页+筛选）
        /// </summary>
        Task<ApiPageResponse<List<sys_coupon>>> GetCouponListAsync(long? storeId, string? name, byte? type, byte? status, int pageIndex, int pageSize,int OrgId, RefAsync<int> count);

        /// <summary>
        /// 获取优惠券详情
        /// </summary>
        Task<ApiResponse<sys_coupon>> GetCouponByIdAsync(long couponId);

        /// <summary>
        /// 新增优惠券
        /// </summary>
        Task<ApiResponse<bool>> AddCouponAsync(sys_coupon coupon);

        /// <summary>
        /// 编辑优惠券
        /// </summary>
        Task<ApiResponse<bool>> UpdateCouponAsync(sys_coupon coupon);

        /// <summary>
        /// 删除优惠券
        /// </summary>
        Task<ApiResponse<bool>> DeleteCouponAsync(long couponId);
    }
}
