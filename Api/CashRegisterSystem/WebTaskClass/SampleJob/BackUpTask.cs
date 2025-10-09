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
    public class BackUpTask : IJob
    {
        private readonly ISqlHelper _dal;
        public BackUpTask(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        /// 每天o点自动备份前一天的已结算的订单
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task Execute(IJobExecutionContext context)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var order = await _dal.Db.Queryable<sys_order>()
                    .Includes(a => a.orderitem, b => b.kitchenorder)
                    .Where(a => a.status == 4 && a.is_backup == 0).ToListAsync();
                order.ForEach(item => item.is_backup = 1);
                var orderItem = order.SelectMany(a => a.orderitem).ToList();
                var kitchenorder = orderItem.Select(a => a.kitchenorder).ToList();
                await _dal.Db.Updateable(order).ExecuteCommandAsync();
                await _dal.Db.Insertable(order).AS("sys_order_backup").ExecuteCommandAsync();
                await _dal.Db.Insertable(orderItem).AS("sys_order_item_backup").ExecuteCommandAsync();
                await _dal.Db.Insertable(kitchenorder).AS("sys_kitchen_order_backup").ExecuteCommandAsync();
                await _dal.Db.Insertable(new sys_backup
                {
                    backup_name = $"自动备份-{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")}",
                    backup_time = DateTime.Now,
                    status = 1,
                    backup_remark = $"备份成功--已结算订单{order.Count()}",
                    backup_sum = order.Count()
                }).ExecuteCommandAsync();
                await _dal.Db.Ado.CommitTranAsync();
            }
            catch (Exception e)
            {
                 await _dal.Db.Ado.RollbackTranAsync();
                await _dal.Db.Insertable(new sys_backup
                {
                    backup_name = $"自动备份-{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")}",
                    backup_time = DateTime.Now,
                    status = 0,
                    backup_remark = $"备份失败--{e.Message}"
                }).ExecuteCommandAsync();
            }
        }
    }
}
