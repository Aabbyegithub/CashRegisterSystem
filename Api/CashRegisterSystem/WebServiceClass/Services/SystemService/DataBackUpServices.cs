using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.SystemService
{
    public class DataBackUpServices:IBaseService,IDataBackUpServices
    {
        private readonly ISqlHelper _dal;

        public DataBackUpServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }
        /// <summary>
        /// 添加备份
        /// </summary>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<ApiResponse<bool>> AddBackUpAsync()
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var order = await _dal.Db.Queryable<sys_order>()
                    .Includes(a => a.orderitem,b=>b.kitchenorder)
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
                    backup_name = $"手动备份-{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")}",
                    backup_time = DateTime.Now,
                    status = 1,
                    backup_remark = $"备份成功--已结算订单{order.Count()}",
                     backup_sum = order.Count()
                }).ExecuteCommandAsync();
                 await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "备份成功");
            }
            catch (Exception e)
            {
                 await _dal.Db.Ado.RollbackTranAsync();
                await _dal.Db.Insertable(new sys_backup
                {
                    backup_name = $"手动备份-{DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")}",
                    backup_time = DateTime.Now,
                    status = 0,
                    backup_remark = $"备份失败--{e.Message}"
                }).ExecuteCommandAsync();
                return Fail<bool>($"备份失败--{e.Message}");
            }
        }
        /// <summary>
        /// 获取备份列表
        /// </summary>
        /// <returns></returns>
        public async Task<ApiPageResponse<List<sys_backup>>> GetBackUpListAsync(string? name, int page, int size, RefAsync<int> count)
        {
            var list =await  _dal.Db.Queryable<sys_backup>()
                .WhereIF(!string.IsNullOrEmpty(name), a => a.backup_name.Contains(name))
                .OrderBy(a => a.backup_time, OrderByType.Desc)
                .ToPageListAsync(page, size, count);
            return PageSuccess(list, count);
        }
    }
}
