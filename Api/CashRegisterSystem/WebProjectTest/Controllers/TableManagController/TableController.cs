using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebIServices.IServices.SystemIServices;
using WebIServices.IServices.TableMangeIServices;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.TableManagController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class TableController(IRedisCacheService redisCacheService, ITableServices _TableServices,IClientServices _clientServices) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 获取餐桌列表
        /// </summary>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("系统设置>角色管理", "菜品管理查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_restaurant_table>>> GetTableListAsync(int? tableType, int? status, string? tableCode, int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _TableServices.GetTableListAsync(tableType, status, tableCode, OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_restaurant_table>>("获取数据失败");
            }
            catch (Exception)
            {

                return PageError<List<sys_restaurant_table>>("服务器错误");
            }
        }

        /// <summary>
        /// 获取门店桌台列表
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<ClientModel>>> GetTableListInfoAsync()
        {
            return await _clientServices.GetTableListInfo(OrgId);
        }

        /// <summary>
        /// 添加餐桌
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "新增桌台", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddTableAsync([FromBody] sys_restaurant_table sys_Table)
        {

            return  await _TableServices.AddTableAsync(sys_Table);
        }

        /// <summary>
        /// 删除餐桌
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "删除桌台", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteTableAsync([FromBody] List<int> tableIds)
        {

            return  await _TableServices.DeleteTableAsync(tableIds);

        }
        /// <summary>
        /// 修改餐桌
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>角色管理", "修改桌台", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateTableAsync([FromBody] sys_restaurant_table sys_Table)
        {
            return  await _TableServices.UpdateTableAsync(sys_Table);

        }

        /// <summary>
        /// 重新生成餐桌二维码
        /// </summary>
        [HttpGet]
        [OperationLogFilter("系统设置>角色管理", "重新生成餐桌二维码", ActionType.Edit)]
        public async Task<ApiResponse<bool>> RegenerateTableAsync(long tableId)
        {
            return await _TableServices.RegenerateTableAsync(tableId);

        }
    }
}
