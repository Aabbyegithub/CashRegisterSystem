using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.DishIServise;
using MyNamespace;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using SqlSugar;
using WebProjectTest.Controllers.SystemController;
using WebIServices.IBase;

namespace WebProjectTest.Controllers.DishController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class DishSpecificationsController(IRedisCacheService redisCacheService, DishSpecificationsIServices _specService) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取规格列表（分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>规格管理", "规格列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_dish_spec>>> GetSpecList(long? dishId, string? specName, string? specType, int pageIndex = 1, int pageSize = 10)
        {
            RefAsync<int> count = 0;
            return await _specService.GetSpecListAsync(dishId, specName, specType, OrgId, pageIndex, pageSize, count);
        }

        [HttpGet]
        public async Task<ApiResponse<List<sys_dish_spec>>> GetAllSpecList()
        {
            return await _specService.GetSpecListAsync();
        }

        /// <summary>
        /// 获取规格详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>规格管理", "规格详情查询", ActionType.Search)]
        public async Task<ApiResponse<sys_dish_spec>> GetSpecById(long specId)
        {
            return await _specService.GetSpecByIdAsync(specId);
        }

        /// <summary>
        /// 新增规格
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>规格管理", "新增规格", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddSpec([FromBody] sys_dish_spec spec)
        {
            return await _specService.AddSpecAsync(spec);
        }

        /// <summary>
        /// 修改规格
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>规格管理", "修改规格", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateSpec([FromBody] sys_dish_spec spec)
        {
            return await _specService.UpdateSpecAsync(spec);
        }

        /// <summary>
        /// 删除规格
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>规格管理", "删除规格", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteSpec([FromBody] long specId)
        {
            return await _specService.DeleteSpecAsync(specId);
        }
        /// <summary>
        /// 根据菜品ID获取分量规格列表
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<List<sys_dish_spec>>> GetSpecListByDishId(long dishId)
        {
            var specs = await _specService.GetSpecListAsync(dishId, null, null, OrgId, 1, 100, new RefAsync<int>(0));
            return Success(specs.Response ?? new List<sys_dish_spec>(), "获取成功");
        }
        [HttpGet]
        public async Task<ApiResponse<List<sys_dish_spec>>> GetDishSpecListAsync(int dishId)
        {
            return await _specService.GetDishSpecListAsync(dishId);
        }
    }
}
