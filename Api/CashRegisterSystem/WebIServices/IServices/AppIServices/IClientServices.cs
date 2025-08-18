using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.ClientIServices
{
    public interface IClientServices:IBaseService
    {
        /// <summary>
        /// 获取当前门店相关桌台信息
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        Task<ApiResponse<List<ClientModel>>> GetTableListInfo(int store_id);

        /// <summary>
        /// 获取菜品类型
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        Task<ApiResponse<List<DishCategory>>> GetDishType(int store_id);

        /// <summary>
        /// 获取菜单
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        Task<ApiResponse<List<DishList>>> GetDish(int store_id);

        /// <summary>
        /// 下单
        /// </summary>
        /// <param name="order"></param>
        /// <param name="store_id"></param>
        /// <param name="table_id"></param>
        /// <param name="sourceType"></param>
        /// <param name="people"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>>SaveOrder(List<Order> order, int store_id, int table_id, int sourceType,int people);

        /// <summary>
        /// 获取桌台订单
        /// </summary>
        /// <param name="store_id"></param>
        /// <param name="table_id"></param>
        /// <returns></returns>
        Task<ApiResponse<List<sys_order>>> GetTableOrder(int store_id, int table_id);

        /// <summary>
        /// 催单
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> OrderReminder(int orderId);
    }
}
