using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.DishIServise
{
    public interface SetMealIServices : IBaseService
    {
        /// <summary>
        /// 获取套餐列表（分页+筛选）
        /// </summary>
        Task<ApiPageResponse<List<sys_set_meal>>> GetMealListAsync(int? storeId, string? mealName, int? status, int pageIndex, int pageSize, RefAsync<int> count,int orgId);

        /// <summary>
        /// 获取套餐详情
        /// </summary>
        Task<ApiResponse<sys_set_meal>> GetMealByIdAsync(long mealId);

        /// <summary>
        /// 新增套餐
        /// </summary>
        Task<ApiResponse<bool>> AddMealAsync(sys_set_meal meal);

        /// <summary>
        /// 修改套餐
        /// </summary>
        Task<ApiResponse<bool>> UpdateMealAsync(sys_set_meal meal);

        /// <summary>
        /// 删除套餐
        /// </summary>
        Task<ApiResponse<bool>> DeleteMealAsync(long mealId);

        /// <summary>
        /// 获取套餐明细（子表）
        /// </summary>
        Task<ApiResponse<List<sys_set_meal_item>>> GetMealItemListAsync(long mealId);

        /// <summary>
        /// 新增/编辑套餐明细
        /// </summary>
        Task<ApiResponse<bool>> SaveMealItemAsync(sys_set_meal_item item);

        /// <summary>
        /// 删除套餐明细
        /// </summary>
        Task<ApiResponse<bool>> DeleteMealItemAsync(long itemId);

        /// <summary>
        /// 删除套餐分组（自定义组合分组及其下所有菜品）
        /// </summary>
        Task<ApiResponse<bool>> DeleteMealGroupAsync(long mealId, string groupName);
    }
}
