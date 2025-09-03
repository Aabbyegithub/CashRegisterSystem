using MyNamespace;
using SqlSugar;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.DishIServise
{
    public interface IDishConfigService : IBaseService
    {
        /// <summary>
        /// 获取菜品配方列表（可筛选）
        /// </summary>
        Task<ApiPageResponse<List<sys_dish_formula>>> GetFormulaListAsync(
            long? dishId,
            long? materialId,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount);

        /// <summary>
        /// 新增菜品配方
        /// </summary>
        Task<ApiResponse<bool>> AddFormulaAsync(sys_dish_formula formula);

        /// <summary>
        /// 编辑菜品配方
        /// </summary>
        Task<ApiResponse<bool>> UpdateFormulaAsync(sys_dish_formula formula);

        /// <summary>
        /// 删除菜品配方
        /// </summary>
        Task<ApiResponse<bool>> DeleteFormulaAsync(long formulaId);
    }
}
