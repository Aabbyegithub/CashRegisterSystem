using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.DishIServise;
using MyNamespace;
using WebProjectTest.Common.Filter;
using SqlSugar;
using static WebProjectTest.Common.Message;
using Microsoft.AspNetCore.Authorization;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;

namespace CashRegisterSystem.Controllers.Dish
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class DishConfigController(IRedisCacheService redisCacheService, IDishConfigService _service) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取菜品配方列表（可筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>配方管理", "配方列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_dish_formula>>> GetFormulaList(
            long? dishId,
            long? materialId,
            int pageIndex = 1,
            int pageSize = 9999)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetFormulaListAsync(dishId, materialId, pageIndex, pageSize, totalCount);
        }

        /// <summary>
        /// 新增菜品配方
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>配方管理", "新增配方", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddFormula([FromBody] sys_dish_formula formula)
        {
            return await _service.AddFormulaAsync(formula);
        }

        /// <summary>
        /// 编辑菜品配方
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>配方管理", "编辑配方", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateFormula([FromBody] sys_dish_formula formula)
        {
            return await _service.UpdateFormulaAsync(formula);
        }

        /// <summary>
        /// 删除菜品配方
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>配方管理", "删除配方", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteFormula(long formulaId)
        {
            return await _service.DeleteFormulaAsync(formulaId);
        }
    }
}