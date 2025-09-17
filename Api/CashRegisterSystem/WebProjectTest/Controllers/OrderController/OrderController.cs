using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.Dto.OrderDto;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebIServices.IServices.OrderIServices;
using WebProjectTest.Common;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using WebServiceClass.Services.OrderServices;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.OrderController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class OrderController(IRedisCacheService redisCacheService, IOrderServices _OrderServices,IClientServices _clientServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取订单列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "查询订单列表", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_order>>> GetOrderListAsync(int?store_Id,string?OrdderNo,int? tableId, int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _OrderServices.GetOrderListAsync(store_Id,OrdderNo,tableId, OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_order>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_order>>("服务器错误");
            }
        }

        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "查询未结算订单列表", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_order>>> GetNotCheckoutOrderListAsync(int? tableId, string? orderno, int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _OrderServices.GetNotCheckoutOrderListAsync(tableId, orderno, OrgId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_order>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_order>>("服务器错误");
            }
        }

        /// <summary>
        /// 添加新订单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("订单管理>订单列表", "新增订单", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddOrderAsync([FromBody] sys_order sys_Order)
        {
            return await _OrderServices.AddOrderAsync(sys_Order);
        }

        /// <summary>
        /// 删除订单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("订单管理>订单列表", "删除订单", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteOrderAsync([FromBody] List<int> orderIds)
        {
            return await _OrderServices.DeleteOrderAsync(orderIds);
        }

        /// <summary>
        /// 修改订单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("订单管理>订单列表", "修改订单", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateOrderAsync([FromBody] sys_order sys_Order)
        {
            return await _OrderServices.UpdateOrderAsync(sys_Order);
        }

        /// <summary>
        /// 获取订单明细 
        /// summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "获取订单明细", ActionType.Search)]
        public async Task<ApiResponse<OrderDetailModel>> GetOrderDetailsAsync(int orderId)
        {
            return await _OrderServices.OrderDetails(orderId);
        }

        /// <summary>
        /// 换桌
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "换桌", ActionType.Edit)]
        public async Task<ApiResponse<bool>> ChangeTableAsync(int oldTableId, int newTableId, int orderId,string? remark)
        {
            return await _OrderServices.ChangeTables(oldTableId, newTableId, orderId,remark);
        }

        /// <summary>
        /// 并桌
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "并桌", ActionType.Edit)]
        public async Task<ApiResponse<bool>> MergeTableAsync(int oldTableId, int newTableId, int orderId,string? remark)
        {
            return await _OrderServices.MergeTables(oldTableId, newTableId, orderId,remark);
        }

        /// <summary>
        /// 订单子项退款    
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "订单子项退款", ActionType.Edit)]
        public async Task<ApiResponse<bool>> OrderItemRefundAsync(string orderItemId)
        {
            return await _OrderServices.OrderItemRefund(orderItemId, UserId);
        }

        /// <summary>
        /// 订单退款
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "订单退款", ActionType.Edit)]
        public async Task<ApiResponse<bool>> OrderRefundAsync(int orderId)
        {
            return await _OrderServices.OrderRefund(orderId, UserId);
        }

        /// <summary>
        /// 订单重做
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "订单重做", ActionType.Edit)]
        public async Task<ApiResponse<bool>> OrderRedoAsync(int orderId)
        {
            return await _OrderServices.OrderRedo(orderId, UserId);
        }

        /// <summary>
        /// 订单结账
        /// summary>
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "订单结账", ActionType.Edit)]
        public async Task<ApiResponse<bool>> OrderCheckoutAsync(int orderId, int? CouponsId, string type,string payCode)
        {
            var url = "";
            switch (type)
            {
                case "wechat":
                    url = AppSettings.GetConfig("Payment:WeChat:CustomUrl");
                    break;
                case "alipay":
                    url = "";
                    break;
                default:
                    return Error<bool>("支付失败");

            }
            return await _clientServices.OrderCheckout(orderId, CouponsId, type, payCode, url, UserId);
        }

        [HttpPost]
        [OperationLogFilter("订单管理>订单列表", "新增预定", ActionType.Add)]
        public async Task<ApiResponse<bool>> ReserveOrderAsync([FromBody] sys_reservation orderreservation)
        {
            return await _OrderServices.ReserveOrderAsync(orderreservation,UserId);
        }
        [HttpGet]
        [OperationLogFilter("订单管理>订单列表", "挂单", ActionType.Edit)]
        public async Task<ApiResponse<bool>> HangOrderAsync(int order)
        {   
            return await _OrderServices.HangOrderAsync(order,UserId);
        }
    }
}
