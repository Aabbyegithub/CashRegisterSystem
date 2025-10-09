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
    public class DishMealTask : IJob
    {
        private readonly ISqlHelper _dal;
        public DishMealTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        ///自动管理套餐的上下架
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task Execute(IJobExecutionContext context)
        {
            await _dal.Db.Updateable<sys_set_meal>().SetColumns(a => new sys_set_meal { status = 0 }).Where(a => a.status == 1 && DateTime.Now >=a.end_time).ExecuteCommandAsync();
            await _dal.Db.Updateable<sys_set_meal>().SetColumns(a => new sys_set_meal { status = 1 }).Where(a => a.status == 0 && DateTime.Now >=a.start_time).ExecuteCommandAsync();
        }
    }
}
