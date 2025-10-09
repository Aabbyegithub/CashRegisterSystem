using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SqlSugar;
using WebIServices.IServices.MemberIServices;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static WebProjectTest.Common.Message;
using static ModelClassLibrary.Model.CommonEnmFixts;
using WebIServices.IBase;
using MyNamespace;

namespace WebProjectTest.Controllers.MemberController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class MemberBalanceController(IRedisCacheService redisCacheService, MemberBalanceIServices _memberServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 储值记录分页查询
        /// </summary>
        [HttpGet]
        [OperationLogFilter("会员管理>储值记录", "储值记录查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_member_balance>>> GetBalanceRecordListAsync(
            string? keyword, string? startDate, string? endDate, string? operatorId, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            return await _memberServices.GetBalanceRecordListAsync(keyword, startDate, endDate, operatorId, page, size, count);
        }
    }
}
