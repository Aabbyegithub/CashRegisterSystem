using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.MemberIServices
{
    public interface MemberBalanceIServices : IBaseService
    {
        Task<ApiPageResponse<List<sys_member_balance>>> GetBalanceRecordListAsync(string? keyword, string? startDate, string? endDate, string? operatorId, int page, int size,RefAsync<int> count );
    }
}
