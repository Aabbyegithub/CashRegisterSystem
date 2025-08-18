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
    public class kitchenOverTimeTask:IJob
    {
        private readonly ISqlHelper _dal;
        public kitchenOverTimeTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        /// 厨房菜品制作超时预警
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task Execute(IJobExecutionContext context)
        {
            var data = await _dal.Db.Queryable<sys_kitchen_order>()
                .Includes(a => a.orderitem).Includes(a => a.orderitem.dish)
                .Where(a => a.status == 1 || a.status == 2).Where(a => (DateTime.Now - a.create_time).Minutes >= a.orderitem.dish.cooking_time)
                .ToListAsync();
            data.ForEach(a => a.overtime_warn = 1);
            await _dal.Db.Updateable(data).ExecuteCommandAsync();

        }
    }
}
