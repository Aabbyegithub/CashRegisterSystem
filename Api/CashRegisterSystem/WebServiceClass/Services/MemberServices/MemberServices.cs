using MyNamespace;
using SqlSugar;
using SqlSugar.Extensions;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.MemberIServices;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.MemberServices
{
    public class MemberServices : MemberIServices,IBaseService
    {
        private readonly ISqlHelper _dal;

        public MemberServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<List<sys_member>> GetMemberPageList(string? phone, string? name, int? status, string? startDate, string? endDate, int page, int size, RefAsync<int> count)
        {
            var query = _dal.Db.Queryable<sys_member>();
            if (!string.IsNullOrEmpty(phone))
                query = query.Where(x => x.phone.Contains(phone));
            if (!string.IsNullOrEmpty(name))
                query = query.Where(x => x.name.Contains(name));
            if (status.HasValue)
                query = query.Where(x => x.status == status.Value);
            if (!string.IsNullOrEmpty(startDate) && !string.IsNullOrEmpty(endDate))
                query = query.Where(x => x.register_time >= startDate.ObjToDate() && x.register_time <= endDate.ObjToDate());

            return await query.OrderByDescending(x => x.member_id)
                              .ToPageListAsync(page, size, count);
        }

        public async Task<ApiResponse<bool>> AddMemberAsync(sys_member member)
        {
            var exists = await _dal.Db.Queryable<sys_member>().AnyAsync(x => x.phone == member.phone);
            if (exists)
                return Fail<bool>("手机号已存在");
            member.register_time = System.DateTime.Now;
            member.status = 1;
            member.member_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(1000, 9999);
            var result = await _dal.Db.Insertable(member).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }
        
        public async Task<ApiResponse<bool>> UpdateMemberAsync(sys_member member)
        {
            var result = await _dal.Db.Updateable(member).IgnoreColumns(x => new { x.register_time, x.status }).ExecuteCommandAsync() > 0;
            return Success(result, result ? "修改成功" : "修改失败");
        }

        public async Task<ApiResponse<bool>> ToggleStatusAsync(long memberId, int status)
        {
            var result = await _dal.Db.Updateable<sys_member>()
                .SetColumns(x => x.status == status)
                .Where(x => x.member_id == memberId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "操作成功" : "操作失败");
        }

        public async Task<ApiResponse<bool>> AddBalanceAsync(sys_member_balance balance)
        {
            balance.recharge_time = System.DateTime.Now;
            var result = await _dal.Db.Insertable(balance).ExecuteCommandAsync() > 0;
            if (result)
            {
                // 更新会员余额
                await _dal.Db.Updateable<sys_member>()
                    .SetColumns(x => x.balance == x.balance + balance.recharge_amount + balance.give_amount)
                    .Where(x => x.member_id == balance.member_id)
                    .ExecuteCommandAsync();
            }
            return Success(result, result ? "储值成功" : "储值失败");
        }

        public async Task<sys_member?> GetMemberByIdAsync(long memberId)
        {
            return await _dal.Db.Queryable<sys_member>().FirstAsync(x => x.member_id == memberId);
        }

        public async Task<List<sys_member_balance>> GetBalanceRecordsAsync(long memberId, int page, int size, RefAsync<int> count)
        {
            return await _dal.Db.Queryable<sys_member_balance>()
                .Where(x => x.member_id == memberId)
                .OrderBy(x => x.recharge_time, OrderByType.Desc)
                .ToPageListAsync(page, size, count);
        }
    }
}
