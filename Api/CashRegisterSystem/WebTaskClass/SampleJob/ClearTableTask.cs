using MyNamespace;
using Quartz;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;

namespace WebTaskClass.SampleJob
{
    public class ClearTableTask : IJob
    {
        private readonly ISqlHelper _dal;
        public ClearTableTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        ///清洁中桌台十分钟自动变为空闲
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task Execute(IJobExecutionContext context)
        {
            await _dal.Db.Updateable<sys_restaurant_table>().SetColumns(a=>new sys_restaurant_table { status = 1}).Where(a => a.status == 4 && DateTime.Now.AddMinutes(-10) >= a.lastUseTime).ExecuteCommandAsync();
        }
    }
}
