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
    public class AddTask:IJob
    {
        private readonly ISqlHelper _dal;
        public AddTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        public Task Execute(IJobExecutionContext context)
        {
           var aa= _dal.Db.Queryable<lq_operationlog>().ToList();
            Console.WriteLine($"Add job executed at: {DateTime.UtcNow}");
            return Task.CompletedTask;
        }
    }
}
