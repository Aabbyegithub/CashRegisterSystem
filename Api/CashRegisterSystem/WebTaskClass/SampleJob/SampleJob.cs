using Quartz;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTaskClass.SampleJob
{
    public class SampleJob : IJob
    {
        public Task Execute(IJobExecutionContext context)
        {
            Console.WriteLine($"Sample job executed at: {DateTime.UtcNow}");
            return Task.CompletedTask;
        }
    }
}
