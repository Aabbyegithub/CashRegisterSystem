using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IServices.InventoryIServices;
using MyNamespace;
using static WebProjectTest.Common.Message;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using SqlSugar;
using WebIServices.IBase;
using Microsoft.AspNetCore.Authorization;
using WebProjectTest.Controllers.SystemController;

namespace CashRegisterSystem.Controllers.Inventory
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    [Authorize]
    public class RawMaterialsController(IRedisCacheService redisCacheService, RawMaterialsIServices _service) : AutherController(redisCacheService)
    {


        /// <summary>
        /// 获取原材料列表（筛选+分页）
        /// </summary>
        [HttpGet]
        [OperationLogFilter("库存管理>原材料管理", "原材料列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_raw_material>>> GetRawMaterialList(
            long? storeId,
            string? name,
            string? category,
            byte? status,
            int pageIndex = 1,
            int pageSize = 10)
        {
            RefAsync<int> totalCount = 0;
            return await _service.GetRawMaterialListAsync(OrgId, storeId, name, category, status, pageIndex, pageSize, totalCount);
        }


        /// <summary>
        /// 获取原材料列表
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<List<sys_raw_material>>> GetAllRawMaterialList()
        {

            return await _service.GetRawMaterialListAsync(OrgId);
        }

        /// <summary>
        /// 新增原材料
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>原材料管理", "新增原材料", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddRawMaterial([FromBody] sys_raw_material material)
        {
            return await _service.AddRawMaterialAsync(material);
        }

        /// <summary>
        /// 编辑原材料
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>原材料管理", "编辑原材料", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateRawMaterial([FromBody] sys_raw_material material)
        {
            return await _service.UpdateRawMaterialAsync(material);
        }

        /// <summary>
        /// 启用/禁用原材料
        /// </summary>
        [HttpPost]
        [OperationLogFilter("库存管理>原材料管理", "原材料状态变更", ActionType.Edit)]
        public async Task<ApiResponse<bool>> ChangeStatus(long materialId, byte status)
        {
            return await _service.ChangeStatusAsync(materialId, status);
        }
    }
}
