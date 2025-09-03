using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.DishIServise;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.DishServices
{
    public class DishSpecificationsServices : DishSpecificationsIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public DishSpecificationsServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_dish_spec>>> GetSpecListAsync(long? dishId, string? specName, string? specType,int orgId, int pageIndex, int pageSize, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_dish_spec>().Includes(a=>a.dish).WhereIF(orgId !=1 ,a=> a.dish.store_id == orgId || a.dish.store_id == null);
            if (dishId.HasValue)
                query = query.Where(x => x.dish_id == dishId.Value);
            if (!string.IsNullOrEmpty(specName))
                query = query.Where(x => x.spec_name.Contains(specName));
            if (!string.IsNullOrEmpty(specType))
                query = query.Where(x => x.spec_type == specType);

            var list = await query.OrderBy(x => x.spec_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, count);
            return PageSuccess(list, count);
        }

        public async Task<ApiResponse<List<sys_dish_spec>>> GetSpecListAsync()
        {
            var query =await _dal.Db.Queryable<sys_dish_spec>().Includes(a => a.dish).OrderBy(x => x.spec_id, OrderByType.Desc)
                                  .ToListAsync();
            return Success(query);
        }
        public async Task<ApiResponse<sys_dish_spec>> GetSpecByIdAsync(long specId)
        {
            var spec = await _dal.Db.Queryable<sys_dish_spec>().FirstAsync(x => x.spec_id == specId);
            return spec != null ? Success(spec, "获取成功") : Fail<sys_dish_spec>("未找到规格");
        }

        public async Task<ApiResponse<bool>> AddSpecAsync(sys_dish_spec spec)
        {
            var result = await _dal.Db.Insertable(spec).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateSpecAsync(sys_dish_spec spec)
        {
            var result = await _dal.Db.Updateable(spec).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> DeleteSpecAsync(long specId)
        {
            var result = await _dal.Db.Deleteable<sys_dish_spec>().In(specId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }

        public async Task<ApiResponse<List<sys_dish_spec>>> GetDishSpecListAsync(int dishId)
        {
            var query = await _dal.Db.Queryable<sys_dish_spec>().Includes(a => a.dish).Where(a=>a.dish_id == dishId).OrderBy(x => x.spec_id, OrderByType.Desc)
                       .ToListAsync();
            return Success(query);
        }
    }
}
