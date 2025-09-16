using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ModelClassLibrary.Model;
using ModelClassLibrary.Model.Dto.OrderDto;
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
        Task<List<sys_order>> GetOrderListAsync(int? store_Id, string? OrdderNo, int? tableId, int orgId, int page, int size, RefAsync<int> count);

        /// <summary>
        ///获取未结算的订单
        /// </summary>
        /// <param name="tableId"></param>
        /// <param name="orderno"></param>
        /// <param name="orgId"></param>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        Task<List<sys_order>> GetNotCheckoutOrderListAsync(int? tableId,string? orderno,int orgId, int page, int size, RefAsync<int> count);

        /// <summary>
        /// 添加订单
        /// </summary>
        Task<ApiResponse<bool>> AddOrderAsync(sys_order order);
        Task<ApiResponse<bool>> HangOrderAsync(int order,int userId);

        /// <summary>
        /// 删除订单
        /// </summary>
        Task<ApiResponse<bool>> DeleteOrderAsync(List<int> orderIds);

        /// <summary>
        /// 修改订单
        /// </summary>
        Task<ApiResponse<bool>> UpdateOrderAsync(sys_order order);

        /// <summary>
        /// 获取订单详情
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        Task<ApiResponse<OrderDetailModel>> OrderDetails(int orderId);


        /// <summary>
        /// 订单并桌
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> MergeTables(int oldTableId, int newTableId, int orderId,string? remark);

        /// <summary>
        /// 订单转桌
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> ChangeTables(int oldTableId, int newTableId, int orderId,string? remark);

        /// <summary>
        /// 单独菜品退款
        /// </summary>
        /// <param name="orderItemId"></param>
        /// <returns></returns>
         Task<ApiResponse<bool>>OrderItemRefund(string orderItemId,int userId);

        /// <summary>
        /// 订单退款
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
         Task<ApiResponse<bool>>OrderRefund(int orderId,int userId);

        /// <summary>
        /// 订单重做
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
         Task<ApiResponse<bool>>OrderRedo(int orderId, int userId);

        /// <summary>
        /// 订单结账
        /// </summary>
        /// <param name="orderId"></param>
        /// <param name="CouponsId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> OrderCheckout(int orderId, int? CouponsId, string type,int userId);

        /// <summary>
        /// 预定
        /// </summary>
        /// <param name="orderreservation"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> ReserveOrderAsync(sys_reservation orderreservation,int userId);
    }
}
