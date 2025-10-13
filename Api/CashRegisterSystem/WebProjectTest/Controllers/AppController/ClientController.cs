using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebProjectTest.Common;
using WebServiceClass.Helper.WeChat;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.AppController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class ClientController(IClientServices _clientServices,ISqlHelper _dal,WeChatPayHelper _payHelper) : ControllerBase
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
        public async Task<ApiResponse<Dictionary<string, string>>> OrderCheckout(int orderId, int? CouponsId, string type,string Code)
        {
            return await _clientServices.OrderCheckout(orderId, CouponsId, type,Code,0);
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

        /// <summary>
        /// 微信支付回调接口
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> PayNotify()
        {
            // 微信通知返回格式要求：必须返回XML，且根节点为<xml>
            string successXml = "<xml><return_code><![CDATA[SUCCESS]]></return_code><return_msg><![CDATA[OK]]></return_msg></xml>";
            string failXml = "<xml><return_code><![CDATA[FAIL]]></return_code><return_msg><![CDATA[处理失败]]></return_msg></xml>";

            try
            {
                // 1. 读取微信通知的XML数据
                string xmlData;
                using (var reader = new StreamReader(Request.Body))
                {
                    xmlData = await reader.ReadToEndAsync();
                }

                // 2. XML转字典，验证签名（防止伪造通知）
                var notifyData = WeChatSignHelper.FromXml(xmlData);
                if (!_payHelper.VerifySign(notifyData)) // 复用签名验证工具类
                {
                    return Content(failXml, "application/xml");
                }

                // 3. 验证微信支付业务结果
                if (notifyData["return_code"] != "SUCCESS" || notifyData["result_code"] != "SUCCESS")
                {
                    string errMsg = $"微信支付失败：{notifyData.GetValueOrDefault("err_code_des", "未知错误")}";
                    return Content(successXml, "application/xml"); // 即使失败，也返回SUCCESS避免微信重复通知
                }

                // 4. 提取关键参数（商户订单号、支付金额、微信支付单号）
                string outTradeNo = notifyData["out_trade_no"]; // 商户订单号（order1.order_no）
                decimal payAmount = Convert.ToDecimal(notifyData["total_fee"]) / 100; // 微信返回的是分，转换为元
                string transactionId = notifyData["transaction_id"]; // 微信支付单号

                // 5. 查询订单和支付记录（加锁防止并发）
                var order = await _dal.Db.Queryable<sys_order>()
                    .With(SqlWith.UpdLock)
                    .FirstAsync(a => a.order_no == outTradeNo);
                if (order == null)
                {
                    return Content(successXml, "application/xml");
                }
                if (order.status == 3) // 已支付，避免重复处理
                {
                    return Content(successXml, "application/xml");
                }

                var payment = await _dal.Db.Queryable<sys_payment>()
                    .With(SqlWith.UpdLock)
                    .FirstAsync(a => a.order_id == order.order_id && a.status == 1); // 1=待支付
                if (payment == null)
                {
                    return Content(successXml, "application/xml");
                }

                // 6. 金额校验（防止金额篡改）
                if (Math.Round(payment.pay_amount, 2) != Math.Round(payAmount, 2))
                {
                    return Content(successXml, "application/xml");
                }

                // 7. 开启事务，更新订单和支付记录状态
                await _dal.Db.Ado.BeginTranAsync();
                try
                {
                    // 更新订单为已支付
                    await _dal.Db.Updateable<sys_order>()
                        .SetColumns(a => new sys_order
                        {
                            status = 3, // 3=已支付
                            pay_time = DateTime.Now,
                            close_time = DateTime.Now,
                        })
                        .Where(a => a.order_id == order.order_id)
                        .ExecuteCommandAsync();

                    // 更新支付记录为已支付
                    await _dal.Db.Updateable<sys_payment>()
                        .SetColumns(p => new sys_payment
                        {
                            status = 2, // 2=已支付
                            pay_time = DateTime.Now,
                            transaction_id = transactionId,// 记录微信支付单号
                        })
                        .Where(p => p.payment_id == payment.payment_id)
                        .ExecuteCommandAsync();

                    await _dal.Db.Ado.CommitTranAsync();
                }
                catch (Exception ex)
                {
                    await _dal.Db.Ado.RollbackTranAsync();
                    return Content(failXml, "application/xml");
                }

                // 8. 返回成功通知（微信收到SUCCESS后会停止重试）
                return Content(successXml, "application/xml");
            }
            catch (Exception ex)
            {
                return Content(failXml, "application/xml");
            }
        }
    }
}
