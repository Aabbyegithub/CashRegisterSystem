using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.SystemIServices
{
    public interface ISupplierServices
    {
        /// <summary>
        /// 获取供应商列表（可筛选+分页）
        /// </summary>
        Task<ApiPageResponse<List<sys_supplier>>> GetSupplierListAsync(
            string? name,
            byte? status,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount);

         Task<ApiResponse<List<sys_supplier>>> GetAllSupplierListAsync();

        /// <summary>
        /// 新增供应商
        /// </summary>
        Task<ApiResponse<bool>> AddSupplierAsync(sys_supplier supplier);

        /// <summary>
        /// 编辑供应商
        /// </summary>
        Task<ApiResponse<bool>> UpdateSupplierAsync(sys_supplier supplier);

        /// <summary>
        /// 删除供应商
        /// </summary>
        Task<ApiResponse<bool>> DeleteSupplierAsync(long supplierId);

        /// <summary>
        /// 获取供应商详情
        /// </summary>
        Task<ApiResponse<sys_supplier>> GetSupplierDetailAsync(long supplierId);
    }
}
