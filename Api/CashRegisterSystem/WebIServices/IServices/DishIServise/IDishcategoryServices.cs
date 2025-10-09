using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.DishIServise
{
    public interface IDishcategoryServices : IBaseService
    {
        /// <summary>
        /// 获取菜品分类列表--可根据门店获取特有分类
        /// </summary>
        /// <param name="orgId"></param>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        Task<List<sys_dish_category>> GetDishCategoryListAsync(string name,int orgId, int page, int size, RefAsync<int> count);
        Task<List<sys_dish_category>> GetDishCategoryListAsync(int orgId);

        /// <summary>
        /// 添加菜品分类
        /// </summary>
        Task<ApiResponse<bool>> AddDishCategoryAsync(sys_dish_category dishCategory);

        /// <summary>
        /// 删除菜品分类
        /// </summary>
        Task<ApiResponse<bool>> DeleteDishCategoryAsync(List<int> categoryIds);

        /// <summary>
        /// 修改菜品分类
        /// </summary>
        Task<ApiResponse<bool>> UpdateDishCategoryAsync(sys_dish_category dishCategory);
    }
}
