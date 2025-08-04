using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebIServices.ITask;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;

namespace WebProjectTest.Controllers.TaskController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    [AllowAnonymous]
    public class TaskController : ControllerBase
    {
        private readonly ITaskService _taskService;
        public TaskController(ITaskService taskService)
        {
            _taskService = taskService;
        }
        /// <summary>
        /// 开启定时服务
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Open)]
        public async Task<string> StartTaskAsync()
        {
            return await _taskService.StartAsync(new CancellationToken());
            
        }

        /// <summary>
        /// 关闭定时服务
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Close)]
        public async Task<string> StopTaskAsync()
        {
             return await _taskService.StopAsync(new CancellationToken());
           
        }

        /// <summary>
        /// 任务管理器新添加一条调度任务
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Add)]
        public async Task<string> AddJobAsync(string jobId,string jobName, string cronExpression)
        {
            return await _taskService.AddJobAsync(jobId,jobName, cronExpression, default);
            
        }

        /// <summary>
        /// 任务管理器移除一个定时任务
        /// </summary>
        /// <param name="jobId"></param>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Remove)]
        public async Task<string> RemoveJobAsync(string jobId)
        {
            return await _taskService.RemoveJobAsync(jobId, default);
    
        }

        /// <summary>
        /// 定时任务暂停
        /// </summary>
        /// <param name="jobId"></param>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Pause)]
        public async Task<string> PauseJobAsync(string jobId)
        {
            return await _taskService.PauseJobAsync(jobId, default);
     
        }

        /// <summary>
        /// 定时任务恢复运行
        /// </summary>
        /// <param name="jobId"></param>
        /// <returns></returns>
        [HttpPost]
        [OperationLogFilter("定时器管理", "启动定时服务", ActionType.Open)]
        public async Task<string> ResumeJobAsync(string jobId)
        {
            return await _taskService.ResumeJobAsync(jobId, default);
           
        }
    }
}
