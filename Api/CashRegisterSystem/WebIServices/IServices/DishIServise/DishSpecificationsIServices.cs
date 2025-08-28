using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;

namespace WebIServices.IServices.DishIServise
{
    public interface DishSpecificationsIServices : IBaseService
    {
        Task<List<sys_dish_spec>> GetSpecListAsync(long? dishId, string? specName, string? specType, int pageIndex, int pageSize);
        Task<int> GetSpecCountAsync(long? dishId, string? specName, string? specType);
        Task<bool> AddSpecAsync(sys_dish_spec spec);
        Task<bool> UpdateSpecAsync(sys_dish_spec spec);
        Task<bool> DeleteSpecAsync(long specId);
        Task<sys_dish_spec?> GetSpecByIdAsync(long specId);
    }
}
