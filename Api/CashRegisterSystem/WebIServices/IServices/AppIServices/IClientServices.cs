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

       Task<ApiResponse<List<bool>>>SaveOrder();
    }
}
