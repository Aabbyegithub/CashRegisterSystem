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
using WebIServices.IBase;
using WebIServices.IServices;

namespace WebServiceClass.Services.CouponServices
{
    public class PromotionalListServices:PromotionIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public PromotionalListServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        /// <summary>
        /// 获取促销活动列表（分页+筛选）
        /// </summary>
        public async Task<ApiPageResponse<List<sys_promotion>>> GetPromotionListAsync(long? storeId, string? name, byte? type, byte? status, int pageIndex, int pageSize,int orgId, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_promotion>().WhereIF(orgId != 1, x => x.store_id == orgId || x.store_id == 0);
            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.promotion_name.Contains(name));
            if (type.HasValue)
                query = query.Where(x => x.type == type.Value);
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.promotion_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, count);
            return PageSuccess(list, count);
        }

        /// <summary>
        /// 获取促销活动详情
        /// </summary>
        public async Task<ApiResponse<sys_promotion>> GetPromotionByIdAsync(long promotionId)
        {
            var promotion = await _dal.Db.Queryable<sys_promotion>().FirstAsync(x => x.promotion_id == promotionId);
            return promotion != null ? Success(promotion, "获取成功") : Fail<sys_promotion>("未找到活动");
        }

        /// <summary>
        /// 新增促销活动
        /// </summary>
        public async Task<ApiResponse<bool>> AddPromotionAsync(sys_promotion promotion)
        {
            var result = await _dal.Db.Insertable(promotion).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        /// <summary>
        /// 编辑促销活动
        /// </summary>
        public async Task<ApiResponse<bool>> UpdatePromotionAsync(sys_promotion promotion)
        {
            var result = await _dal.Db.Updateable(promotion).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        /// <summary>
        /// 删除促销活动
        /// </summary>
        public async Task<ApiResponse<bool>> DeletePromotionAsync(long promotionId)
        {
            var result = await _dal.Db.Deleteable<sys_promotion>().In(promotionId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }
    }
}
