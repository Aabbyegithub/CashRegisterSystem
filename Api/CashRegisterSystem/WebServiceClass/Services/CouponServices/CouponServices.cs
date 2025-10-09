using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using static WebProjectTest.Common.Message;
using WebIServices.IServices;
using WebIServices.IBase;

namespace WebServiceClass.Services.CouponServices
{
    public class CouponServices : CouponIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public CouponServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_coupon>>> GetCouponListAsync(long? storeId, string? name, byte? type, byte? status, int pageIndex, int pageSize,int OrgId, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_coupon>().WhereIF(OrgId != 1, x => x.store_id == OrgId || x.store_id == 0);
            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.coupon_name.Contains(name));
            if (type.HasValue)
                query = query.Where(x => x.type == type.Value);
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.coupon_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, count);
            return PageSuccess(list, count);
        }

        public async Task<ApiResponse<sys_coupon>> GetCouponByIdAsync(long couponId)
        {
            var coupon = await _dal.Db.Queryable<sys_coupon>().FirstAsync(x => x.coupon_id == couponId);
            return coupon != null ? Success(coupon, "获取成功") : Fail<sys_coupon>("未找到优惠券");
        }

        public async Task<ApiResponse<bool>> AddCouponAsync(sys_coupon coupon)
        {
            coupon.coupon_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999);
            var result = await _dal.Db.Insertable(coupon).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateCouponAsync(sys_coupon coupon)
        {
            var result = await _dal.Db.Updateable(coupon).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> DeleteCouponAsync(long couponId)
        {
            var result = await _dal.Db.Deleteable<sys_coupon>().In(couponId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }
    }
}
