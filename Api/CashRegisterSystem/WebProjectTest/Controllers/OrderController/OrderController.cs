using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.OrderIServices;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.OrderController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class OrderController(IRedisCacheService redisCacheService, IOrderServices _OrderServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取订单列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("订单管理", "查询订单列表", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_order>>> GetOrderListAsync(int page = 0, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _OrderServices.GetOrderListAsync(OrgId, page, size, count);
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
        [OperationLogFilter("订单管理", "新增订单", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddOrderAsync([FromBody] sys_order sys_Order)
        {
           return await _OrderServices.AddOrderAsync(sys_Order);
        }

        /// <summary>
        /// 删除订单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("订单管理", "删除订单", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteOrderAsync([FromBody] List<int> orderIds)
        {
           return  await _OrderServices.DeleteOrderAsync(orderIds);
        }

        /// <summary>
        /// 修改订单
        /// </summary>
        [HttpPost]
        [OperationLogFilter("订单管理", "修改订单", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateOrderAsync([FromBody] sys_order sys_Order)
        {
            return  await _OrderServices.UpdateOrderAsync(sys_Order);
        }
    }
}
