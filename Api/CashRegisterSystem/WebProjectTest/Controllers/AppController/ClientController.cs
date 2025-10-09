using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using WebIServices.IServices.ClientIServices;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.AppController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class ClientController(IClientServices _clientServices) : ControllerBase
    {
        /// <summary>
        /// 获取门店桌台列表
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<ClientModel>>> GetTableListInfoAsync(int store_id)
        {
            return await _clientServices.GetTableListInfo(store_id);
        }

        /// <summary>
        /// 获取菜品类型
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<DishCategory>>> GetDishTypeAsync(int store_id)
        {
            return await _clientServices.GetDishType(store_id);
        }

        /// <summary>
        /// 获取菜品列表
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<DishList>>> GetDishAsync(int store_id)
        {
            return await _clientServices.GetDish(store_id);
        }

        /// <summary>
        /// 下单
        /// </summary>
        /// <param name="order"></param>
        /// <param name="store_id"></param>
        /// <param name="table_id"></param>
        /// <param name="sourceType"></param>
        /// <param name="people"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<ApiResponse<bool>> SaveOrderAsync(List<Order> order, int store_id, int table_id, int sourceType, int people, int? orderId,string?memberPhone)
        {
            return await _clientServices.SaveOrder(order, store_id, table_id, sourceType, people, orderId,memberPhone);
        }

        /// <summary>
        /// 获取桌台订单，可以结算或者加菜，催菜
        /// </summary>
        /// <param name="store_id"></param>
        /// <param name="table_id"></param>
        /// <returns></returns>
        [HttpGet]

        public async Task<ApiResponse<List<sys_order>>> GetTableOrderAsync(int store_id, int? table_id, int sourceType)
        {
            return await _clientServices.GetTableOrder(store_id, table_id, sourceType);
        }

        /// <summary>
        /// 长时间有未上菜品，对未上菜品进行催单
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<bool>> OrderReminderAsync(int orderId)
        {
            return await _clientServices.OrderReminder(orderId);
        }

        /// <summary>
        /// 获取订单详情
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<OrderDetailResult>> OrderDetails(int orderId)
        {
            return await _clientServices.OrderDetails(orderId);
        }

        /// <summary>
        /// 结账
        /// </summary>
        /// <param name="orderId"></param>
        /// <param name="CouponsId"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<bool>> OrderCheckout(int orderId, int? CouponsId, string type,string Code)
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
            return await _clientServices.OrderCheckout(orderId, CouponsId, type,Code,url,0);
        }

        /// <summary>
        /// 并桌
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<bool>> MergeTablesAsync(int oldTableId, int newTableId, int orderId)
        {
            return await _clientServices.MergeTables(oldTableId, newTableId, orderId);
        }

        /// <summary>
        /// 转桌
        /// </summary>
        /// <param name="oldTableId"></param>
        /// <param name="newTableId"></param>
        /// <param name="orderId"></param>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<bool>> ChangeTablesAsync(int oldTableId, int newTableId, int orderId)
        {
            return await _clientServices.ChangeTables(oldTableId, newTableId, orderId);
        }

        /// <summary>
        /// 获取优惠券列表
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<List<sys_coupon>>> GetCouponList(long? storeId)
        {
            return await _clientServices.GetCouponListAsync(storeId);
        }
    }
}
