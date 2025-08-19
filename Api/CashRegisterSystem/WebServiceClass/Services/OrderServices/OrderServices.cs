using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.OrderIServices;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.OrderServices
{
    public class OrderServices : IBaseService, IOrderServices
    {
        private readonly ISqlHelper _dal;

        public OrderServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<bool>> AddOrderAsync(sys_order order)
        {
            try
            {
                await _dal.Db.Insertable(order).ExecuteCommandAsync();
                return Success(true, "添加订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"添加订单失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<bool>> DeleteOrderAsync(List<int> orderIds)
        {
            try
            {
                await _dal.Db.Deleteable<sys_order>().In(orderIds).ExecuteCommandAsync();
                return Success(true, "删除订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"删除订单失败:{ex.Message}");
            }
        }

        public Task<List<sys_order>> GetNotCheckoutOrderListAsync(int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_order>()
                 .WhereIF(orgId != 1, x => x.store_id == orgId)
                 .Where(x => x.status == 1|| x.status == 2)
                 .OrderBy(x => x.created_at, OrderByType.Desc)
                 .ToPageListAsync(page, size, count);
        }

        public Task<List<sys_order>> GetOrderListAsync(int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_order>()
                .WhereIF(orgId != 1, x => x.store_id == orgId)
                .OrderBy(x => x.created_at, OrderByType.Desc)
                .ToPageListAsync(page, size, count);
        }

        public async Task<ApiResponse<bool>> UpdateOrderAsync(sys_order order)
        {
            try
            {
                await _dal.Db.Updateable(order).ExecuteCommandAsync();
                return Success(true, "修改订单成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"修改订单失败:{ex.Message}");
            }
        }
    }
}
