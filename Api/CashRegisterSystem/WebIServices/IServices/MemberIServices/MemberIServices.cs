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
    /// <summary>
    /// 会员相关服务接口
    /// </summary>
    public interface MemberIServices : IBaseService
    {
        /// <summary>
        /// 获取会员分页列表
        /// </summary>
        /// <param name="phone">手机号筛选</param>
        /// <param name="name">姓名筛选</param>
        /// <param name="status">状态筛选（1-正常，0-冻结）</param>
        /// <param name="startDate">注册开始日期</param>
        /// <param name="endDate">注册结束日期</param>
        /// <param name="page">页码</param>
        /// <param name="size">每页数量</param>
        /// <param name="count">总数引用</param>
        /// <returns>会员列表</returns>
        Task<List<sys_member>> GetMemberPageList(string? phone, string? name, int? status, string? startDate, string? endDate, int page, int size, RefAsync<int> count);

        /// <summary>
        /// 新增会员
        /// </summary>
        /// <param name="member">会员实体</param>
        /// <returns>操作结果</returns>
        Task<ApiResponse<bool>> AddMemberAsync(sys_member member);

        /// <summary>
        /// 修改会员信息
        /// </summary>
        /// <param name="member">会员实体</param>
        /// <returns>操作结果</returns>
        Task<ApiResponse<bool>> UpdateMemberAsync(sys_member member);

        /// <summary>
        /// 切换会员状态（冻结/解冻）
        /// </summary>
        /// <param name="memberId">会员ID</param>
        /// <param name="status">目标状态</param>
        /// <returns>操作结果</returns>
        Task<ApiResponse<bool>> ToggleStatusAsync(long memberId, int status);

        /// <summary>
        /// 新增会员储值记录
        /// </summary>
        /// <param name="balance">储值记录实体</param>
        /// <returns>操作结果</returns>
        Task<ApiResponse<bool>> AddBalanceAsync(long member_id, decimal recharge_amount, decimal give_amount,string type, string url, int userId);

        /// <summary>
        /// 根据会员ID获取会员信息
        /// </summary>
        /// <param name="memberId">会员ID</param>
        /// <returns>会员实体</returns>
        Task<sys_member?> GetMemberByIdAsync(long memberId);

        /// <summary>
        /// 获取会员储值记录分页列表
        /// </summary>
        /// <param name="memberId">会员ID</param>
        /// <param name="page">页码</param>
        /// <param name="size">每页数量</param>
        /// <param name="count">总数引用</param>
        /// <returns>储值记录列表</returns>
        Task<List<sys_member_balance>> GetBalanceRecordsAsync(long memberId, int page, int size, RefAsync<int> count);
    }
}
