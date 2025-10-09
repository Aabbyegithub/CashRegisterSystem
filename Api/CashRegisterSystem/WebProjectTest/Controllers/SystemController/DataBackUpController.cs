using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;
using WebProjectTest.Common.Filter;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.SystemController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class DataBackUpController(IRedisCacheService redisCacheService, IDataBackUpServices _dataBackUpServices) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 获取备份列表
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("系统设置>数据备份", "查询备份信息", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_backup>>> GetBackUpListAsync(string? name, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            return await _dataBackUpServices.GetBackUpListAsync(name, page, size, count);
        }

        /// <summary>
        /// 添加备份
        /// </summary>
        /// <param name="backupName"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("系统设置>数据备份", "添加备份", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddBackUpAsync()
        {
            return await _dataBackUpServices.AddBackUpAsync();
        }
    }
}
