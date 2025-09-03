using MyNamespace;
using SqlSugar;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.DishIServise
{
    public interface DishSpecificationsIServices : IBaseService
    {
        /// <summary>
        /// 获取规格列表（分页）
        /// </summary>
        Task<ApiPageResponse<List<sys_dish_spec>>> GetSpecListAsync(long? dishId, string? specName, string? specType,int orgId, int pageIndex, int pageSize, RefAsync<int> count);
        Task<ApiResponse<List<sys_dish_spec>>> GetSpecListAsync();
        Task<ApiResponse<List<sys_dish_spec>>> GetDishSpecListAsync(int dishId);

        /// <summary>
        /// 获取规格详情
        /// </summary>
        Task<ApiResponse<sys_dish_spec>> GetSpecByIdAsync(long specId);

        /// <summary>
        /// 新增规格
        /// </summary>
        Task<ApiResponse<bool>> AddSpecAsync(sys_dish_spec spec);

        /// <summary>
        /// 修改规格
        /// </summary>
        Task<ApiResponse<bool>> UpdateSpecAsync(sys_dish_spec spec);

        /// <summary>
        /// 删除规格
        /// </summary>
        Task<ApiResponse<bool>> DeleteSpecAsync(long specId);
    }
}
