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
        [OperationLogFilter("菜品管理>菜品分类", "菜品分类管理查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_dish_category>>> GetDishCategoryListAsync(string? name,int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _DishcategoryServices.GetDishCategoryListAsync(name,OrgId, page, size, count);
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

        [HttpGet]
        public async Task<ApiPageResponse<List<sys_dish_category>>> GetAllDishCategoryListAsync()
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _DishcategoryServices.GetDishCategoryListAsync(OrgId);
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
        [OperationLogFilter("菜品管理>菜品分类", "新增菜品分类", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddDishCategoryAsync([FromBody] sys_dish_category dishCategory)
        {

                return await _DishcategoryServices.AddDishCategoryAsync(dishCategory);

        }

        /// <summary>
        /// 删除菜品分类
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>菜品分类", "删除菜品分类", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteDishCategoryAsync([FromBody] List<int> categoryIds)
        {

                return await _DishcategoryServices.DeleteDishCategoryAsync(categoryIds);
        }

        /// <summary>
        /// 修改菜品分类
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>菜品分类", "修改菜品分类", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateDishCategoryAsync([FromBody] sys_dish_category dishCategory)
        {
                return await _DishcategoryServices.UpdateDishCategoryAsync(dishCategory);
        }
    }
}
