using ModelClassLibrary.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;

namespace WebIServices.ITask
{
    public interface ITaskService :IBaseService
    {
        /// <summary>
        /// 开启调度任务
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> StartAsync(CancellationToken cancellationToken);

        /// <summary>
        /// 关闭调度任务
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> StopAsync(CancellationToken cancellationToken);

        /// <summary>
        /// 添加一个调度任务
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="NameSpase"></param>
        /// <param name="jobName"></param>
        /// <param name="cronExpression"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> AddJobAsync(string jobId,string jobName, string cronExpression, CancellationToken cancellationToken);

        /// <summary>
        /// 移除一个调度任务
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> RemoveJobAsync(string jobId, CancellationToken cancellationToken);

        /// <summary>
        /// 暂停一个调度任务
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> PauseJobAsync(string jobId, CancellationToken cancellationToken);
        
        /// <summary>
        /// 恢复该调度任务的运行
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<string> ResumeJobAsync(string jobId, CancellationToken cancellationToken);
    }
}
