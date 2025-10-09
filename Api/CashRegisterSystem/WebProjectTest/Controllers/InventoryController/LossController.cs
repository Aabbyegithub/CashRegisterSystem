using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SqlSugar;
using MyNamespace;
using WebIServices.IBase;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using WebIServices.IServices.InventoryIServices;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;
using Microsoft.AspNetCore.Authorization;

namespace CashRegisterSystem.Controllers.Inventory
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class InventoryLossController(IRedisCacheService redisCacheService, LossIServices _service) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取损耗记录列表（筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>损耗管理", "损耗记录列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_inventory_loss>>> GetLossList(
            long? storeId,
            long? materialId,
            int? lossType,
            int pageIndex = 1,
            int pageSize = 10)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetLossListAsync(OrgId, storeId, materialId, lossType, pageIndex, pageSize, totalCount);
        }

        /// <summary>
        /// 新增损耗记录
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>损耗管理", "新增损耗记录", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddLoss([FromBody] sys_inventory_loss loss)
        {
            return await _service.AddLossAsync(loss,OrgId,UserId);
        }

        /// <summary>
        /// 修改损耗记录
        /// </summary>
        /// <param name="loss"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("库存管理>损耗管理", "修改损耗记录", ActionType.Add)]
        public async Task<ApiResponse<bool>> UpdateLossAsync([FromBody] sys_inventory_loss loss)
        {
            return await _service.UpdateLossAsync(loss, UserId);
        }

        /// <summary>
        /// 删除损耗记录
        /// </summary>
        /// <param name="lossId"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("库存管理>损耗管理", "删除损耗记录", ActionType.Add)]
        public async Task<ApiResponse<bool>> DelLossDetailAsync(long lossId)
        {
            return await _service.DelLossDetailAsync(lossId);
        }

        /// <summary>
        /// 获取损耗详情
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>损耗管理", "损耗详情", ActionType.Search)]
        public async Task<ApiResponse<sys_inventory_loss>> GetLossDetail(long lossId)
        {
            return await _service.GetLossDetailAsync(lossId);
        }
    }
}