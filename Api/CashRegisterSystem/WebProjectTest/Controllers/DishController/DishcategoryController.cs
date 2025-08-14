using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.DishIServise;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.DishController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class DishcategoryController(IRedisCacheService redisCacheService, IDishcategoryServices _DishcategoryServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取菜品分类列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("系统设置>角色管理", "菜品分类管理查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_dish_category>>> GetDishCategoryListAsync(int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _DishcategoryServices.GetDishCategoryListAsync(OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_dish_category>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_dish_category>>("服务器错误");
            }
        }

        /// <summary>
        /// 添加菜品分类
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "新增菜品分类", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddDishCategoryAsync([FromBody] sys_dish_category dishCategory)
        {
            try
            {
                return await _DishcategoryServices.AddDishCategoryAsync(dishCategory);
            }
            catch (Exception ex)
            {
                return Fail<bool>("添加菜品分类失败: " + ex.Message);
            }
        }

        /// <summary>
        /// 删除菜品分类
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "删除菜品分类", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteDishCategoryAsync([FromBody] List<int> categoryIds)
        {
            try
            {
                return await _DishcategoryServices.DeleteDishCategoryAsync(categoryIds);
            }
            catch (Exception ex)
            {
                return Fail<bool>("删除菜品分类失败: " + ex.Message);
            }
        }

        /// <summary>
        /// 修改菜品分类
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "修改菜品分类", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateDishCategoryAsync([FromBody] sys_dish_category dishCategory)
        {
            try
            {
                return await _DishcategoryServices.UpdateDishCategoryAsync(dishCategory);
            }
            catch (Exception ex)
            {
                return Fail<bool>("修改菜品分类失败: " + ex.Message);
            }
        }
    }
}
