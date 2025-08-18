using ModelClassLibrary.Model.Dto.AppDto;
using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.AppServices
{
    public class ClientServices : IBaseService, IClientServices
    {
        private readonly ISqlHelper _dal;

        public ClientServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<List<ClientModel>>> GetTableListInfo(int store_id)
        {
            var tableList = await _dal.Db.Queryable<sys_restaurant_table>()
                .Includes(a => a.order)
                .Includes(a=>a.order.reservation)
                .Where(a => a.store_id == store_id)
                .ToListAsync();

            var result = tableList.Select(a => new ClientModel
            {
                Id = a.table_id,
                Name = a.table_no,
                Status = a.status,
                People = a.order == null ? 0 : (int)(a.order.table_capacity ?? 0),
                Max = a.capacity,
                bookedTime = a.order == null ? "" :  (a.order.reservation == null ? "":  a.order.reservation?.reservation_time.ToString("yy-MM-dd HH:mm:ss"))
            }).ToList();
            return Success(result, "获取桌台列表成功");
        }

        public async Task<ApiResponse<List<DishList>>> GetDish(int store_id)
        {
            var res = await _dal.Db.Queryable<sys_dish>()
                  .Includes(a=>a.dish_category).OrderBy(a=>a.dish_category.sort_order)
                  .Where(a => a.store_id == store_id || a.store_id == null)
                  .Select(a => new DishList
                  {
                      Id = a.dish_id,
                      Name = a.dish_name,
                      Desc = a.description,
                      DishCategoryType = a.category_id,
                      Price = a.member_price,
                      Spece = 1,
                      Img = a.image_url
                  }).ToListAsync();
            return Success(res, "菜品获取成功");
        }

        public async Task<ApiResponse<List<DishCategory>>> GetDishType(int store_id)
        {
            var res = await _dal.Db.Queryable<sys_dish_category>()
                 .Where(a=>a.store_id == store_id || a.store_id == null).OrderBy(a=>a.sort_order)
                 .Select(a => new DishCategory
                 {
                     Id = a.category_id,
                     Name = a.category_name,
                 }).ToListAsync();
            if(res.Count > 0)
              res.FirstOrDefault().active = true;
            return Success(res,"菜品类型获取成功");
        }

        public Task<ApiResponse<List<bool>>> SaveOrder(Order order)
        {
             
        }
    }
}
