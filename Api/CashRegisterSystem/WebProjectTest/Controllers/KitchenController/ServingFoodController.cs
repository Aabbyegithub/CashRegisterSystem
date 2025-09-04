using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.KitchenIServices;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.KitchenController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class ServingFoodController(IRedisCacheService redisCacheService, ServingFoodIServices servingFoodIServices) : AutherController(redisCacheService)
    {
        private readonly ServingFoodIServices _servingFoodIServices = servingFoodIServices;

        /// <summary>
        /// 获取厨房订单列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("厨房管理>出餐记录表>", "出餐记录表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_kitchen_order>>> GetKitchenOrderList(int? storeId, string? kitchenType, int? status, string? StartTime, string? EndTime, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            return await _servingFoodIServices.GetkitchenListAsync(storeId, kitchenType, status, OrgId, StartTime, EndTime, page, size, count);
        }
    }
}
