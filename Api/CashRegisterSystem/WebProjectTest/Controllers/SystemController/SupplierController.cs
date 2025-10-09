using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.SystemIServices;
using MyNamespace;
using WebProjectTest.Common.Filter;
using SqlSugar;
using static WebProjectTest.Common.Message;
using Microsoft.AspNetCore.Authorization;
using WebIServices.IBase;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;

namespace CashRegisterSystem.Controllers.System
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class SupplierController(IRedisCacheService redisCacheService, ISupplierServices _service) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取供应商列表（筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("系统设置>供应商管理", "供应商列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_supplier>>> GetSupplierList(
            string? name,
            byte? status,
            int pageIndex = 1,
            int pageSize = 10)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetSupplierListAsync(name, status, pageIndex, pageSize, totalCount);
        }

        /// <summary>
        /// 获取所有供应商列表
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<List<sys_supplier>>> GetAllSupplierList()
        {
            return await _service.GetAllSupplierListAsync();
        }

        /// <summary>
        /// 新增供应商
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>供应商管理", "新增供应商", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddSupplier([FromBody] sys_supplier supplier)
        {
            return await _service.AddSupplierAsync(supplier);
        }

        /// <summary>
        /// 编辑供应商
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>供应商管理", "编辑供应商", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateSupplier([FromBody] sys_supplier supplier)
        {
            return await _service.UpdateSupplierAsync(supplier);
        }

        /// <summary>
        /// 删除供应商
        /// </summary>
        [HttpPost]
        [OperationLogFilter("系统设置>供应商管理", "删除供应商", ActionType.Delete)]
        public async Task<ApiResponse<bool>> DeleteSupplier(long supplierId)
        {
            return await _service.DeleteSupplierAsync(supplierId);
        }

        /// <summary>
        /// 获取供应商详情
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<sys_supplier>> GetSupplierDetail(long supplierId)
        {
            return await _service.GetSupplierDetailAsync(supplierId);
        }
    }
}