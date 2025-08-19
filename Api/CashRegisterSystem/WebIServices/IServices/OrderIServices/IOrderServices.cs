using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.OrderIServices
{
    public interface IOrderServices : IBaseService
    {
        /// <summary>
        /// 获取订单列表
        /// </summary>
        Task<List<sys_order>> GetOrderListAsync(int orgId, int page, int size, RefAsync<int> count);
        Task<List<sys_order>> GetNotCheckoutOrderListAsync(int? tableId,string? orderno,int orgId, int page, int size, RefAsync<int> count);

        /// <summary>
        /// 添加订单
        /// </summary>
        Task<ApiResponse<bool>> AddOrderAsync(sys_order order);

        /// <summary>
        /// 删除订单
        /// </summary>
        Task<ApiResponse<bool>> DeleteOrderAsync(List<int> orderIds);

        /// <summary>
        /// 修改订单
        /// </summary>
        Task<ApiResponse<bool>> UpdateOrderAsync(sys_order order);
    }
}
