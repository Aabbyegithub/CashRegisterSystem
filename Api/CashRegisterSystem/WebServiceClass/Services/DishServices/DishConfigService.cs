using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.DishIServise;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.DishServices
{
    public class DishConfigService : IDishConfigService, IBaseService
    {
        private readonly ISqlHelper _dal;

        public DishConfigService(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_dish_formula>>> GetFormulaListAsync(
            long? dishId,
            long? materialId,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_dish_formula>().Includes(x=>x.dish_material);
            if (dishId.HasValue && dishId.Value > 0)
                query = query.Where(x => x.dish_id == dishId.Value);
            if (materialId.HasValue && materialId.Value > 0)
                query = query.Where(x => x.material_id == materialId.Value);

            var list = await query.OrderBy(x => x.formula_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }

        public async Task<ApiResponse<bool>> AddFormulaAsync(sys_dish_formula formula)
        {
            var result = await _dal.Db.Insertable(formula).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateFormulaAsync(sys_dish_formula formula)
        {
            var result = await _dal.Db.Updateable(formula).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> DeleteFormulaAsync(long formulaId)
        {
            var result = await _dal.Db.Deleteable<sys_dish_formula>().Where(x => x.formula_id == formulaId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }
    }
}