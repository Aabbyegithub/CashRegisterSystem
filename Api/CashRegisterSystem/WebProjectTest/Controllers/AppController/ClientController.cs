using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.Dto.AppDto;
using WebIServices.IServices.ClientIServices;
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
    }
}
