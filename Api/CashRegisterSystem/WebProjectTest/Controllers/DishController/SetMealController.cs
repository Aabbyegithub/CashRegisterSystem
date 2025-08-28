using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.DishIServise;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;

namespace WebProjectTest.Controllers.DishController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class SetMealController(IRedisCacheService redisCacheService, SetMealIServices _setMealService) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取套餐列表（分页+筛选）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>套餐管理", "套餐列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_set_meal>>> GetMealList(int? storeId, string? mealName, int? status, int pageIndex = 1, int pageSize = 10)
        {
            RefAsync<int> count = 0;
            return await _setMealService.GetMealListAsync(storeId, mealName, status, pageIndex, pageSize, count, OrgId);
        }

        /// <summary>
        /// 获取套餐详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>套餐管理", "套餐详情查询", ActionType.Search)]
        public async Task<ApiResponse<sys_set_meal>> GetMealById(long mealId)
        {
            return await _setMealService.GetMealByIdAsync(mealId);
        }

        /// <summary>
        /// 新增套餐
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "新增套餐", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddMeal([FromBody] sys_set_meal meal)
        {
            return await _setMealService.AddMealAsync(meal);
        }

        /// <summary>
        /// 修改套餐
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "修改套餐", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateMeal([FromBody] sys_set_meal meal)
        {
            return await _setMealService.UpdateMealAsync(meal);
        }

        /// <summary>
        /// 删除套餐
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "删除套餐", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteMeal([FromBody] long mealId)
        {
            return await _setMealService.DeleteMealAsync(mealId);
        }

        /// <summary>
        /// 获取套餐明细（子表）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("菜品管理>套餐管理", "套餐明细查询", ActionType.Search)]
        public async Task<ApiResponse<List<sys_set_meal_item>>> GetMealItemList(long mealId)
        {
            return await _setMealService.GetMealItemListAsync(mealId);
        }

        /// <summary>
        /// 新增/编辑套餐明细
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "保存套餐明细", ActionType.Edit)]
        public async Task<ApiResponse<bool>> SaveMealItem([FromBody] sys_set_meal_item item)
        {
            return await _setMealService.SaveMealItemAsync(item);
        }

        /// <summary>
        /// 删除套餐明细
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "删除套餐明细", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteMealItem([FromBody] long itemId)
        {
            return await _setMealService.DeleteMealItemAsync(itemId);
        }
        
        /// <summary>
        /// 删除套餐分组（自定义组合分组及其下所有菜品）
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>套餐管理", "删除套餐分组", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteMealGroup(long MealId, string GroupName)
        {
            return await _setMealService.DeleteMealGroupAsync(MealId, GroupName);
        }
    }
}