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
    public class DishController(IRedisCacheService redisCacheService, IDishServices _DishServices) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 获取角色列表
        /// </summary>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("菜品管理>菜品列表", "菜品列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_dish>>> GetDishListAsync(string? dishname, int? type, int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _DishServices.GetDishPageList(dishname, type,OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_dish>>("获取数据失败");
            }
            catch (Exception)
            {

                return PageError<List<sys_dish>>("服务器错误");
            }
        }

        [HttpGet]
        [OperationLogFilter("菜品管理>菜品列表", "菜品列表查询", ActionType.Search)]
        public async Task<ApiResponse<List<sys_dish>>> GetAllDishListAsync()
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _DishServices.GetDishPageList(OrgId);
                if (res != null)
                {
                    return Success(res);
                }
                return Fail<List<sys_dish>>("获取数据失败");
            }
            catch (Exception)
            {

                return Error<List<sys_dish>>("服务器错误");
            }
        }
        /// <summary>
        /// 添加菜品
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>菜品列表", "新增菜品", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddDishAsync([FromBody] sys_dish sys_Dish)
        {
            return    await _DishServices.AddDishAsync(sys_Dish);
        }

        /// <summary>
        /// 删除菜品
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>菜品列表", "删除菜品", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteDishAsync([FromBody] List<int> ids)
        {
            return    await _DishServices.DeleteDishAsync(ids);
        }

        /// <summary>
        /// 修改菜品
        /// </summary>
        [HttpPost]
        [OperationLogFilter("菜品管理>菜品列表", "修改菜品", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateDishAsync([FromBody] sys_dish sys_Dish)
        {
           return     await _DishServices.UpdateDishAsync(sys_Dish);

        }
    }
}
