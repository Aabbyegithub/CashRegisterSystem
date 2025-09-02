using MyNamespace;
using SqlSugar;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.QueueIServices;
using static ModelClassLibrary.Model.Dto.QueueDto.QueueDto;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.QueueServices
{
    public class QueueServices : IBaseService, IQueueServices
    {
        private readonly ISqlHelper _dal;

        public QueueServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<List<sys_queue>> GetQueuePageListAsync(int orgId, int? storeId, int? status, int? partySize, string? keyword, int page, int size, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_queue>();
            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId);
            if (status.HasValue)
                query = query.Where(x => x.status == status);
            if (partySize.HasValue)
                query = query.Where(x => x.party_size == partySize);
            if (!string.IsNullOrEmpty(keyword))
                query = query.Where(x => x.customer_phone.Contains(keyword) || x.customer_name.Contains(keyword));
            return await query.OrderBy(x => x.created_at, OrderByType.Desc)
                             .ToPageListAsync(page, size, count);
        }


        public async Task<List<sys_queue>> GetQueuePageListAsync(int orgId)
        {
            var query = _dal.Db.Queryable<sys_queue>().Where(a=>a.store_id == orgId && a.status !=4 && a.status !=5);
            return await query.OrderBy(x => x.created_at, OrderByType.Desc)
                             .ToListAsync();
        }

        public async Task<ApiResponse<bool>> AddQueueAsync(sys_queue queue,int orgId)
        {
            var quCount = await _dal.Db.Queryable<sys_queue>().Where(a => a.store_id == (queue.store_id > 0 ? queue.store_id : orgId) && a.created_at.Date == DateTime.Today).CountAsync();
            queue.queue_no = $"A{quCount+1:000}";
            queue.created_at = DateTime.Now;
            queue.queue_time = DateTime.Now;
            queue.status = 1;
            queue.store_id = queue.store_id  > 0 ? queue.store_id:  orgId;
            var result = await _dal.Db.Insertable(queue).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增排队成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateQueueStatusAsync(long queueId, int status)
        {
            var result = await _dal.Db.Updateable<sys_queue>()
                .SetColumns(x => x.status == status)
                .Where(x => x.queue_id == queueId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "状态更新成功" : "状态更新失败");
        }

        public async Task<ApiResponse<bool>> CancelQueueAsync(long queueId)
        {
            return await UpdateQueueStatusAsync(queueId,5);
        }

        public async Task<ApiResponse<bool>> CallQueueAsync(long queueId)
        {
            return await UpdateQueueStatusAsync(queueId,2);
        }

        public async Task<ApiResponse<bool>> SkipQueueAsync(long queueId)
        {
            return await UpdateQueueStatusAsync(queueId, 3);
        }

        public async Task<ApiResponse<bool>> finishQueueAsync(long queueId)
        {
            return await UpdateQueueStatusAsync(queueId, 4);
        }

        public async Task<ApiResponse<bool>> AssignTableAsync(long queueId, long tableId)
        {
            var result = await _dal.Db.Updateable<sys_queue>()
                .SetColumns(x => new sys_queue { status =4, table_id = tableId })
                .Where(x => x.queue_id == queueId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "安排桌台成功" : "安排失败");
        }

        public async Task<sys_queue?> GetQueueByIdAsync(long queueId)
        {
            return await _dal.Db.Queryable<sys_queue>().FirstAsync(x => x.queue_id == queueId);
        }

        public async Task<QueueStatsDto> GetQueueStatsAsync(int? storeId)
        {
            var query = _dal.Db.Queryable<sys_queue>();
            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId);
            var today = System.DateTime.Today;
            var totalToday = await query.Where(x => x.created_at >= today).CountAsync();
            var waitingCount = await _dal.Db.Queryable<sys_queue>().WhereIF(storeId.HasValue,a=>a.store_id == storeId).Where(x => x.status == 1).CountAsync();
            var skippedCount = await query.Where(x => x.status == 4).CountAsync();
            var waitingList = await  _dal.Db.Queryable<sys_queue>().WhereIF(storeId.HasValue,a=>a.store_id == storeId).Where(x => x.created_at >= today).ToListAsync();
            var finished = await _dal.Db.Queryable<sys_queue>().WhereIF(storeId.HasValue,a=>a.store_id == storeId).Where(x => x.created_at >= today && x.status !=1).CountAsync();
            double avgWait = 0;
            if (waitingList.Count > 0)
            {
                avgWait = waitingList.Average(x => (DateTime.Now - x.created_at).TotalMinutes);
            }
            // var avgWait = await query.Where(x => x.status == 1).AvgAsync(x =>(DateTime.Now - x.created_at).TotalMinutes);
            var skippedRate = totalToday > 0 ? (int)((double)skippedCount / totalToday * 100) : 0;
            return new QueueStatsDto
            {
                waitingCount = waitingCount,
                averageWaitTime =(int) avgWait,
                totalToday = totalToday,
                skippedRate = skippedRate,
                finished = finished
            };
        }

        private async Task<string> GenerateQueueNumber(int? storeId)
        {
            var today = System.DateTime.Today;
            var count = await _dal.Db.Queryable<sys_queue>()
                .Where(x => x.store_id == storeId && x.created_at >= today)
                .CountAsync();
            return $"A{(count + 1):D3}";
        }
    }
}
