using MyNamespace;
using SqlSugar;
using SqlSugar.Extensions;
using System.Collections.Generic;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.MemberIServices;
using WebServiceClass.Helper.WeChat;
using static Azure.Core.HttpHeader;
using static Dm.net.buffer.ByteArrayBuffer;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.MemberServices
{
    public class MemberServices : MemberIServices,IBaseService
    {
        private readonly ISqlHelper _dal;
        private readonly WeChatPayHelper _weChatPayHelper;

        public MemberServices(ISqlHelper dal, WeChatPayHelper weChatPayHelper)
        {
            _dal = dal;
            _weChatPayHelper = weChatPayHelper;
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
            member.member_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999);
            var result = await _dal.Db.Insertable(member).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }
        
        public async Task<ApiResponse<bool>> UpdateMemberAsync(sys_member member)
        {
            var result = await _dal.Db.Updateable<sys_member>()
                .SetColumns(x => new sys_member{phone = member.phone,name = member.name,birthday = member.birthday }).Where(a=>a.member_id == member.member_id).ExecuteCommandAsync() ;
            return Success(true,"修改成功");
        }

        public async Task<ApiResponse<bool>> ToggleStatusAsync(long memberId, int status)
        {
            var result = await _dal.Db.Updateable<sys_member>()
                .SetColumns(x => x.status == status)
                .Where(x => x.member_id == memberId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "操作成功" : "操作失败");
        }

        public async Task<ApiResponse<bool>> AddBalanceAsync(long member_id,decimal recharge_amount,decimal give_amount,string type, string PayCode, int userId)
        {
            try
            {
                await _dal.Db.Ado.BeginTranAsync();
                var member = await _dal.Db.Queryable<sys_member>().With(SqlWith.UpdLock).FirstAsync(a=>a.member_id== member_id);
                if (member == null) throw new Exception("会员不存在");

                // 更新会员余额
                await _dal.Db.Updateable<sys_member>()
                        .SetColumns(x => x.balance == x.balance + recharge_amount + give_amount)
                        .Where(x => x.member_id == member_id)
                        .ExecuteCommandAsync();
                string balance_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999);

                byte pay_type = 0;
                switch (type)
                {
                    case "wechat": //微信付款码支付
                        pay_type = 1;
                        decimal amount = 0.01m; // 支付金额，单位：元

                        bool isSuccess = _weChatPayHelper.CodePay(balance_no, amount, PayCode);
                        if (isSuccess)
                        {
                            //支付记录
                            var payId = await _dal.Db.Insertable(new sys_payment
                            {
                                payment_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999),
                                pay_amount = recharge_amount,
                                pay_type = pay_type,
                                status = 2,
                                pay_time = DateTime.Now,
                            }).ExecuteReturnBigIdentityAsync();

                            var result = await _dal.Db.Insertable(new sys_member_balance
                            {
                                member_id = member_id,
                                balance_no = balance_no,
                                balance = member.balance.HasValue ? member.balance.Value : 0,
                                recharge_amount = recharge_amount,
                                give_amount = give_amount,
                                recharge_time = DateTime.Now,
                                operator_id = userId,
                                payment_id = payId
                            }).ExecuteReturnBigIdentityAsync();
                            await _dal.Db.Ado.CommitTranAsync();
                            return Success(true,"储值成功");
                        }
                        else
                        {

                        }
                        break;
                    case "alipay": //支付宝

                        break;
                    default:
                        break;
                }

                return Success(true,"储值成功");
            }
            catch (Exception e)
            {
                await _dal.Db.Ado.RollbackTranAsync();
                return Fail<bool>($"储值失败-{e.Message}");
            }

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
