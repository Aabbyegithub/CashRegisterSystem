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
    public class KitchenManageController(IRedisCacheService redisCacheService, KichenManageIServices kichenManageIServices) : AutherController(redisCacheService)
    {
        private readonly KichenManageIServices _kichenManageIServices = kichenManageIServices;

        /// <summary>
        /// 获取厨房列表
        /// </summary>
        /// <param name="orgId"></param>
        /// <param name="storeId"></param>
        /// <param name="kitchenType"></param>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("厨房管理>厨房管理", "厨房列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_kitchen>>> GetKitchenListAsync(int? storeId, string? kitchenType, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _kichenManageIServices.GetkitchenListAsync(storeId, kitchenType, OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_kitchen>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_kitchen>>("服务器错误");
            }
        }

        /// <summary>
        /// 获取门店所有厨房
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<sys_kitchen>>> GetAllKitchenListAsync()
        {
            return Success( await _kichenManageIServices.GetAllKichenListAsync());
        }

        /// <summary>
        /// 添加厨房
        /// </summary>
        [HttpPost]
        [OperationLogFilter("厨房管理>厨房管理", "新增厨房", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddKitchenAsync([FromBody] sys_kitchen kitchen)
        {
            return await _kichenManageIServices.AddkitchenAsync(kitchen);
        }

        /// <summary>
        /// 删除厨房
        /// </summary>
        [HttpPost]
        [OperationLogFilter("厨房管理>厨房管理", "删除厨房", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteKitchenAsync([FromBody] int kitchenId)
        {
            return await _kichenManageIServices.DeleteKitchenAsync(kitchenId);
        }

        /// <summary>
        /// 修改厨房
        /// </summary>
        [HttpPost]
        [OperationLogFilter("厨房管理>厨房管理", "修改厨房", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateKitchenAsync([FromBody] sys_kitchen kitchen)
        {
            return await _kichenManageIServices.UpdateKitchenAsync(kitchen);
        }
    }
}
