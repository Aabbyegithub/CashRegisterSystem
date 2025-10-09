using MyNamespace;
using SqlSugar;
using SqlSugar.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.DishIServise;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.DishServices
{
    public class DishServices : IBaseService, IDishServices
    {
        private readonly ISqlHelper _dal;

        public DishServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<bool>> AddDishAsync(sys_dish dish)
        {
            try
            {
                await _dal.Db.Insertable(dish).ExecuteCommandAsync();
                return Success(true, "添加菜品成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"添加菜品失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<bool>> DeleteDishAsync(List<int> dishIds)
        {
            try
            {
                await _dal.Db.Updateable<sys_dish>().SetColumns(a=>a.status == 0).Where(a=>dishIds.Contains(a.dish_id.ObjToInt())).ExecuteCommandAsync();
                return Success(true, "删除菜品成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"删除菜品失败:{ex.Message}");
            }
        }

        public Task<List<sys_dish>> GetDishPageList(string? name, int? type, int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_dish>()
                .WhereIF(!string.IsNullOrEmpty(name), x => x.dish_name.Contains(name))
                .WhereIF(type.HasValue, x => x.category_id == type)
                .WhereIF(orgId != 1, a => a.store_id == orgId || a.store_id == null)
                .ToPageListAsync(page, size, count);
        }

        public Task<List<sys_dish>> GetDishPageList( int orgId)
        {
            return _dal.Db.Queryable<sys_dish>()

                .WhereIF(orgId != 1, a => a.store_id == orgId || a.store_id == null)
                .ToListAsync();
        }

        public async Task<ApiResponse<bool>> UpdateDishAsync(sys_dish dish)
        {
           try
            {
                await _dal.Db.Updateable(dish).ExecuteCommandAsync();
                return Success(true, "修改菜品成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"修改菜品失败:{ex.Message}");
            }
        }
    }
}
