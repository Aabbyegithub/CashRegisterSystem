using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using static WebProjectTest.Common.Message;
using System;
using System.Linq;
using System.Text;
using WebIServices.IBase;
using MyNamespace;
using static ModelClassLibrary.Model.Dto.QueueDto.QueueDto;

namespace WebIServices.IServices.QueueIServices
{
    public interface IQueueServices : IBaseService
    {
        /// <summary>
        ///获取排队分页
        /// </summary>
        /// <param name="orgId"></param>
        /// <param name="storeId"></param>
        /// <param name="status"></param>
        /// <param name="partySize"></param>
        /// <param name="keyword"></param>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        Task<List<sys_queue>> GetQueuePageListAsync(int orgId, int? storeId, int? status, int? partySize, string? keyword, int page, int size, RefAsync<int> count);
        Task<List<sys_queue>> GetQueuePageListAsync(int orgId);
        
        /// <summary>
        /// 新增排队
        /// </summary>
        /// <param name="queue"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> AddQueueAsync(sys_queue queue,int orgId);

        /// <summary>
        /// 更新状态
        /// </summary>
        /// <param name="queueId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> UpdateQueueStatusAsync(long queueId, int status);

        /// <summary>
        /// 取消排队
        /// </summary>
        /// <param name="queueId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> CancelQueueAsync(long queueId);

        /// <summary>
        /// 叫号
        /// </summary>
        /// <param name="queueId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> CallQueueAsync(long queueId);

        /// <summary>
        /// 过号
        /// </summary>
        /// <param name="queueId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> SkipQueueAsync(long queueId);

        /// <summary>
        /// 入座
        /// </summary>
        /// <param name="queueId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> finishQueueAsync(long queueId);

        /// <summary>
        /// 安排桌台
        /// </summary>
        /// <param name="queueId"></param>
        /// <param name="tableId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> AssignTableAsync(long queueId, long tableId);
        Task<sys_queue?> GetQueueByIdAsync(long queueId);

        /// <summary>
        /// 计算指标
        /// </summary>
        /// <param name="storeId"></param>
        /// <returns></returns>
        Task<QueueStatsDto> GetQueueStatsAsync(int? storeId);
    }
}
