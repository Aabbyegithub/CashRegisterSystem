using MyNamespace;
using SqlSugar;
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
    public class DishcategoryServices:IBaseService,IDishcategoryServices
    {
        private readonly ISqlHelper _dal;

        public DishcategoryServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<bool>> AddDishCategoryAsync(sys_dish_category dishCategory)
        {
            try
            {
                await _dal.Db.Insertable(dishCategory).ExecuteCommandAsync();
                return Success(true, "添加菜品分类成功");
            }
            catch (Exception ex)
            {
                return Error<bool>( $"添加菜品分类失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<bool>> DeleteDishCategoryAsync(List<int> categoryIds)
        {
            try
            {
                await _dal.Db.Deleteable<sys_dish_category>().In(categoryIds).ExecuteCommandAsync();
                return Success(true, "删除菜品分类成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"删除菜品分类失败:{ex.Message}");
            }
        }

        public async Task<List<sys_dish_category>> GetDishCategoryListAsync(int orgId, int page, int size, RefAsync<int> count)
        {
            return await _dal.Db.Queryable<sys_dish_category>()
                .Where(x => x.store_id ==null || x.store_id == orgId)
                .ToPageListAsync(page, size, count);
        }

        public async Task<ApiResponse<bool>> UpdateDishCategoryAsync(sys_dish_category dishCategory)
        {
           try
            {
                await _dal.Db.Updateable(dishCategory).ExecuteCommandAsync();
                return Success(true, "修改菜品分类成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"修改菜品分类失败:{ex.Message}");
            }
        }
    }
}
