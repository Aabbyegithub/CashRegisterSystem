using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.DishIServise;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.DishServices
{
    public class SetMealServices : SetMealIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public SetMealServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        // 获取套餐列表（分页+筛选）
        public async Task<ApiPageResponse<List<sys_set_meal>>> GetMealListAsync(int? storeId, string? mealName, int? status, int pageIndex, int pageSize, RefAsync<int> count,int orgId)
        {
            var query = _dal.Db.Queryable<sys_set_meal>()
            .WhereIF(orgId != 1, x => x.store_id == orgId)  ; // 非总部用户只能看到自己门店的数据
            
            if (storeId.HasValue)
                query = query.Where(x => x.store_id == storeId.Value);
            if (!string.IsNullOrEmpty(mealName))
                query = query.Where(x => x.meal_name.Contains(mealName));
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.meal_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, count);
            return PageSuccess(list, count);
        }

        // 获取套餐详情
        public async Task<ApiResponse<sys_set_meal>> GetMealByIdAsync(long mealId)
        {
            var meal = await _dal.Db.Queryable<sys_set_meal>().Includes(a=>a.item).FirstAsync(x => x.meal_id == mealId);
            return meal != null ? Success(meal, "获取成功") : Fail<sys_set_meal>("未找到套餐");
        }

        // 新增套餐
        public async Task<ApiResponse<bool>> AddMealAsync(sys_set_meal meal)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var result = await _dal.Db.Insertable(meal).ExecuteReturnBigIdentityAsync();
                meal.meal_item.ForEach(item => item.meal_id = result);
                await _dal.Db.Insertable(meal.meal_item).ExecuteCommandAsync();
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "新增成功");
            }
            catch (Exception)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>( "新增失败");
            }
        }

        // 修改套餐
        public async Task<ApiResponse<bool>> UpdateMealAsync(sys_set_meal meal)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                await _dal.Db.Updateable(meal).ExecuteCommandAsync();
                var insert = meal.meal_item.Where(a => a.item_id == 0).ToList();
                var update = meal.meal_item.Where(a => a.item_id != 0).ToList();
                await _dal.Db.Updateable(update).ExecuteCommandAsync();
                await _dal.Db.Insertable(insert).ExecuteCommandAsync();
                await _dal.Db.Ado.CommitTranAsync();
                return Success(true, "修改成功");
            }
            catch (Exception)
            {

                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>("修改失败");
            }

        }

        // 删除套餐
        public async Task<ApiResponse<bool>> DeleteMealAsync(long mealId)
        {
            var result = await _dal.Db.Updateable<sys_set_meal>().SetColumns(a=>a.status ==0).Where(a=>a.meal_id == mealId).ExecuteCommandAsync() > 0;
            // 同时删除子表
            //if (result)
            //    await _dal.Db.Deleteable<sys_set_meal_item>().Where(x => x.meal_id == mealId).ExecuteCommandAsync();
            return Success(result, result ? "删除成功" : "删除失败");
        }

        // 获取套餐明细（子表）
        public async Task<ApiResponse<List<sys_set_meal_item>>> GetMealItemListAsync(long mealId)
        {
            var items = await _dal.Db.Queryable<sys_set_meal_item>().Where(x => x.meal_id == mealId).ToListAsync();
            return Success(items, "获取成功");
        }

        // 新增/编辑套餐明细
        public async Task<ApiResponse<bool>> SaveMealItemAsync(sys_set_meal_item item)
        {
            if (item.item_id == 0)
            {
                var result = await _dal.Db.Insertable(item).ExecuteCommandAsync() > 0;
                return Success(result, result ? "新增成功" : "新增失败");
            }
            else
            {
                var result = await _dal.Db.Updateable(item).ExecuteCommandAsync() > 0;
                return Success(result, result ? "修改成功" : "修改失败");
            }
        }

        // 删除套餐明细
        public async Task<ApiResponse<bool>> DeleteMealItemAsync(long itemId)
        {
            var result = await _dal.Db.Deleteable<sys_set_meal_item>().In(itemId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }

        /// <summary>
        /// 删除套餐分组（自定义组合分组及其下所有菜品）
        /// </summary>
        public async Task<ApiResponse<bool>> DeleteMealGroupAsync(long mealId, string groupName)
        {
            // 删除该套餐下指定分组的所有明细
            var result = await _dal.Db.Deleteable<sys_set_meal_item>()
                .Where(x => x.meal_id == mealId && x.meal_group == groupName)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "分组及其菜品已删除" : "删除失败");
        }
    }
}
