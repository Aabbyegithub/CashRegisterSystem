using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.MemberIServices;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.MemberServices
{
    public class MemberBalanceServices : MemberBalanceIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public MemberBalanceServices(ISqlHelper dal)
        {
            _dal = dal;
        }
        public async Task<ApiPageResponse<List<sys_member_balance>>> GetBalanceRecordListAsync(string? keyword, string? startDate, string? endDate, string? operatorId, int page, int size, RefAsync<int> count)
        {
            var res = await _dal.Db.Queryable<sys_member_balance>()
                .Includes(a => a.member)
                .Includes(a => a.operatorName)
                .WhereIF(!string.IsNullOrEmpty(keyword), a => a.member.name.Contains(keyword) || a.member.phone.Contains(keyword))
                .WhereIF(!string.IsNullOrEmpty(startDate) && !string.IsNullOrEmpty(endDate), a => a.recharge_time >= Convert.ToDateTime(startDate) && a.recharge_time <= Convert.ToDateTime(endDate).AddDays(1).AddSeconds(-1))
                .WhereIF(!string.IsNullOrEmpty(operatorId), a => a.operatorName.name == operatorId)
                .OrderBy(a => a.recharge_time, OrderByType.Desc)
                .ToPageListAsync(page, size, count);
            return PageSuccess(res, count);
        }
    }
}
