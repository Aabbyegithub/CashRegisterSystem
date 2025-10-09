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
    public class AutomatedTask : IJob
    {
        private readonly ISqlHelper _dal;
        public AutomatedTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        /// 自动执行优惠卷和活动列表开始和过期
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task Execute(IJobExecutionContext context)
        {
            var promotion = await _dal.Db.Queryable<sys_promotion>().Where(a => a.status != 2).ToListAsync();
            if (promotion.Count >0)
            {
                //自动开始开始活动
                var Start = promotion.Where(a => a.start_time <= DateTime.Now && a.status == 0).ToList();
                Start.ForEach(item => item.status = 1);
                await _dal.Db.Updateable(Start).ExecuteCommandAsync();
                //自动过期
                var End =  promotion.Where(a => a.end_time <= DateTime.Now && a.status == 1).ToList();
                End.ForEach(item => item.status = 2);
                await _dal.Db.Updateable(End).ExecuteCommandAsync();
            }

            //优惠卷自动开始和过期
            var coupon = await _dal.Db.Queryable<sys_coupon>().Where(a => a.status != 2).ToListAsync();
            if (coupon.Count > 0)
            {
                //自动开始开始活动
                var Start = coupon.Where(a => a.valid_start <= DateTime.Now && a.status == 0).ToList();
                Start.ForEach(item => item.status = 1);
                await _dal.Db.Updateable(Start).ExecuteCommandAsync();
                //自动过期
                var End = coupon.Where(a => a.valid_end <= DateTime.Now && a.status == 1).ToList();
                End.ForEach(item => item.status = 2);
                await _dal.Db.Updateable(End).ExecuteCommandAsync();
            }
        }
    }
}
