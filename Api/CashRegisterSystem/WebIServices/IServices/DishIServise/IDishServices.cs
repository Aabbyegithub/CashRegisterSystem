using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.DishIServise
{
    public interface IDishServices : IBaseService
    {
        ///<summary>
        ///获取菜单列表
        ///</summary>
        Task<List<sys_dish>> GetDishPageList(string? name,int?type,int orgid,int page,int size, RefAsync<int> count );

        Task<List<sys_dish>> GetDishPageList(int orgId);

        /// <summary>
        /// 添加菜品
        /// </summary>
        /// <param name="table"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> AddDishAsync(sys_dish dish);

        /// <summary>
        /// 删除菜品
        /// </summary>
        /// <param name="storeId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> DeleteDishAsync(List<int> dishIds);

        ///<summary>
        ///修改菜品
        ///<summary>
        Task<ApiResponse<bool>> UpdateDishAsync(sys_dish dish);
    }
}
