using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.InventoryIServices;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.InventoryServices
{
    public class RawMaterialsServices : RawMaterialsIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public RawMaterialsServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_raw_material>>> GetRawMaterialListAsync(int orgId,
            long? storeId, string? name, string? category, byte? status,
            int pageIndex, int pageSize, RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_raw_material>().WhereIF(orgId !=1,a=>a.store_id == orgId || a.store_id == 0);
            if (storeId.HasValue && storeId.Value > 0)
                query = query.Where(x => x.store_id == storeId.Value);
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.material_name.Contains(name));
            if (!string.IsNullOrEmpty(category))
                query = query.Where(x => x.category == category);
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.material_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }


        public async Task<ApiResponse<List<sys_raw_material>>> GetRawMaterialListAsync(int orgId)
        {
            var query = _dal.Db.Queryable<sys_raw_material>().WhereIF(orgId != 1, a => a.store_id == orgId || a.store_id == 0);

            var list = await query.OrderBy(x => x.material_id, OrderByType.Desc)
                                  .ToListAsync();
            return Success(list);
        }

        public async Task<ApiResponse<bool>> AddRawMaterialAsync(sys_raw_material material)
        {
            var result = await _dal.Db.Insertable(material).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateRawMaterialAsync(sys_raw_material material)
        {
            var result = await _dal.Db.Updateable(material).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> ChangeStatusAsync(long materialId, byte status)
        {
            var result = await _dal.Db.Updateable<sys_raw_material>()
                .SetColumns(x => x.status == status)
                .Where(x => x.material_id == materialId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "状态修改成功" : "状态修改失败");
        }
    }
}
