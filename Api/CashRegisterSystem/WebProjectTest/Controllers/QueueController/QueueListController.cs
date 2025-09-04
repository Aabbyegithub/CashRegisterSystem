using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SqlSugar;
using System.Collections.Generic;
using WebIServices.IServices.QueueIServices;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;
using static ModelClassLibrary.Model.CommonEnmFixts;
using MyNamespace;
using static ModelClassLibrary.Model.Dto.QueueDto.QueueDto;

namespace WebProjectTest.Controllers.QueueController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class QueueController(IRedisCacheService redisCacheService, IQueueServices _queueServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 排队分页列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("排队叫号>排队列表", "排队列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_queue>>> GetQueuePageList(int? storeId, int? status, int? partySize, string? keyword, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _queueServices.GetQueuePageListAsync(OrgId, storeId, status, partySize, keyword, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_queue>>("获取数据失败");
            }
            catch
            {
                return PageError<List<sys_queue>>("服务器错误");
            }
        }

        /// <summary>
        /// 排队分页列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("排队叫号>排队列表", "排队列表查询", ActionType.Search)]
        public async Task<ApiResponse<List<sys_queue>>> GetQueueList()
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _queueServices.GetQueuePageListAsync(OrgId);
                if (res != null)
                {
                    return Success(res);
                }
                return Fail<List<sys_queue>>("获取数据失败");
            }
            catch
            {
                return Error<List<sys_queue>>("服务器错误");
            }
        }

        /// <summary>
        /// 新增排队
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "新增排队", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddQueueAsync([FromBody] sys_queue queue)
        {
            return await _queueServices.AddQueueAsync(queue,OrgId);
        }

        /// <summary>
        /// 叫号
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "叫号", ActionType.Edit)]
        public async Task<ApiResponse<bool>> CallQueueAsync(long queueId)
        {
            return await _queueServices.CallQueueAsync(queueId);
        }

        /// <summary>
        /// 过号
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "过号", ActionType.Edit)]
        public async Task<ApiResponse<bool>> SkipQueueAsync(long queueId)
        {
            return await _queueServices.SkipQueueAsync(queueId);
        }

        /// <summary>
        /// 入座
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "过号", ActionType.Edit)]
        public async Task<ApiResponse<bool>> finishQueueAsync(long queueId)
        {
            return await _queueServices.finishQueueAsync(queueId);
        }

        /// <summary>
        /// 取消排队
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "取消排队", ActionType.Delete)]
        public async Task<ApiResponse<bool>> CancelQueueAsync(long queueId)
        {
            return await _queueServices.CancelQueueAsync(queueId);
        }

        /// <summary>
        /// 安排桌台
        /// </summary>
        [HttpPost]
        [OperationLogFilter("排队叫号>排队列表", "安排桌台", ActionType.Edit)]
        public async Task<ApiResponse<bool>> AssignTableAsync(long queueId, long tableId)
        {
            return await _queueServices.AssignTableAsync(queueId, tableId);
        }

        /// <summary>
        /// 排队统计
        /// </summary>
        [HttpGet]
        [OperationLogFilter("排队叫号>排队列表", "排队统计", ActionType.Search)]
        public async Task<ApiResponse<QueueStatsDto>> GetQueueStats(int? storeId)
        {
            var stats = await _queueServices.GetQueueStatsAsync(storeId);
            return Success(stats, "统计获取成功");
        }

        /// <summary>
        /// 排队统计
        /// </summary>
        [HttpGet]
        [OperationLogFilter("排队叫号>排队列表", "排队统计", ActionType.Search)]
        public async Task<ApiResponse<QueueStatsDto>> GetAppQueueStats()
        {
            var stats = await _queueServices.GetQueueStatsAsync(OrgId);
            return Success(stats, "统计获取成功");
        }
    }
}
