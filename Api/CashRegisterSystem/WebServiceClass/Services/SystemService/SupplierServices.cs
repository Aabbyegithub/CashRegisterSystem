using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.SystemIServices;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.SystemServices
{
    public class SupplierServices : ISupplierServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public SupplierServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_supplier>>> GetSupplierListAsync(
            string? name,
            byte? status,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_supplier>();
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.supplier_name.Contains(name));
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.supplier_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }

        public async Task<ApiResponse<List<sys_supplier>>> GetAllSupplierListAsync()
        {
            var list = await _dal.Db.Queryable<sys_supplier>()
                .OrderBy(x => x.supplier_id, OrderByType.Desc)
                .ToListAsync();
            return Success(list);
        }

        public async Task<ApiResponse<bool>> AddSupplierAsync(sys_supplier supplier)
        {
            var result = await _dal.Db.Insertable(supplier).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateSupplierAsync(sys_supplier supplier)
        {
            var result = await _dal.Db.Updateable(supplier).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> DeleteSupplierAsync(long supplierId)
        {
            var result = await _dal.Db.Deleteable<sys_supplier>().Where(x => x.supplier_id == supplierId).ExecuteCommandAsync() > 0;
            return Success(result, result ? "删除成功" : "删除失败");
        }

        public async Task<ApiResponse<sys_supplier>> GetSupplierDetailAsync(long supplierId)
        {
            var entity = await _dal.Db.Queryable<sys_supplier>().FirstAsync(x => x.supplier_id == supplierId);
            return Success(entity, entity != null ? "查询成功" : "未找到记录");
        }
    }
}