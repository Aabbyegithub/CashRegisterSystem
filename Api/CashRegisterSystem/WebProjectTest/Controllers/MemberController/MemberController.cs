using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.MemberIServices;
using WebProjectTest.Common;
using WebProjectTest.Common.Filter;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.MemberController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class MemberController(IRedisCacheService redisCacheService, MemberIServices _memberServices) : AutherController(redisCacheService)
    {
        /// <summary>
        /// 获取会员分页列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("会员管理>会员列表", "会员列表查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_member>>> GetMemberPageList(string? phone, string? name, int? status, string? startDate, string? endDate, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _memberServices.GetMemberPageList(phone, name, status, startDate, endDate, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_member>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_member>>("服务器错误");
            }
        }

        /// <summary>
        /// 新增会员
        /// </summary>
        [HttpPost]
        [OperationLogFilter("会员管理>会员列表", "新增会员", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddMemberAsync([FromBody] sys_member member)
        {
            return await _memberServices.AddMemberAsync(member);
        }

        /// <summary>
        /// 修改会员信息
        /// </summary>
        [HttpPost]
        [OperationLogFilter("会员管理>会员列表", "修改会员", ActionType.Edit)]
        public async Task<ApiResponse<bool>> UpdateMemberAsync([FromBody] sys_member member)
        {
            return await _memberServices.UpdateMemberAsync(member);
        }

        /// <summary>
        /// 切换会员状态（冻结/解冻）
        /// </summary>
        [HttpPost]
        [OperationLogFilter("会员管理>会员列表", "切换会员状态", ActionType.Edit)]
        public async Task<ApiResponse<bool>> ToggleStatusAsync(long memberId, int status)
        {
            return await _memberServices.ToggleStatusAsync(memberId, status);
        }

        /// <summary>
        /// 新增会员储值记录
        /// </summary>
        [HttpPost]
        [OperationLogFilter("会员管理>会员列表", "会员储值", ActionType.Add)]
        public async Task<ApiResponse<bool>> AddBalanceAsync(long member_id, decimal recharge_amount, decimal give_amount, string type)
        {
            var url = "";
            switch (type)
            {
                case "wechat":
                    url = AppSettings.GetConfig("Payment:WeChat:CustomUrl");
                    break;
                case "alipay":
                    url = "";
                    break;
                case "现金":
                    url = "";
                    break;
                default:
                    return Error<bool>("支付失败");

            }
            return await _memberServices.AddBalanceAsync(member_id, recharge_amount, give_amount,type, url, UserId);
        }

        /// <summary>
        /// 获取会员储值记录分页列表
        /// </summary>
        [HttpGet]
        [OperationLogFilter("会员管理>会员列表", "会员储值记录查询", ActionType.Search)]
        public async Task<ApiPageResponse<List<sys_member_balance>>> GetBalanceRecordsAsync(long memberId, int page = 1, int size = 10)
        {
            RefAsync<int> count = 0;
            try
            {
                var res = await _memberServices.GetBalanceRecordsAsync(memberId, page, size, count);
                if (res != null)
                {
                    return PageSuccess(res, count);
                }
                return PageFail<List<sys_member_balance>>("获取数据失败");
            }
            catch (Exception)
            {
                return PageError<List<sys_member_balance>>("服务器错误");
            }
        }
    }
}
