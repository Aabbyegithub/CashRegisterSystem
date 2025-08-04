using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using SqlSugar;
using System.ComponentModel.Design.Serialization;
using WebIServices.IBase;
using WebProjectTest.Common;
using WebProjectTest.Common.Filter;
using WebServiceClass.Helper;
using static ModelClassLibrary.Model.CommonEnmFixts;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.AutherUser
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class RoleController(IRedisCacheService redisCacheService, ISqlHelper dal) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 角色查询
        /// </summary>
        /// <param name="RoleName"></param>
        /// <param name="Page"></param>
        /// <param name="Size"></param>
        /// <param name="IsDelete"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("设置>权限设置", "角色分页查询", ActionType.Search)]
        public async Task<ApiPageResponse<lq_sys_role>> GetRoleDataAsync(string? RoleName, int Page = 1, int Size = 20, int IsDelete = 1)
        {
            RefAsync<int> count = 0;
            var data = await dal.Db.Queryable<lq_sys_role>().Where(a => a.IsDelete == IsDelete && a.OrgId == OrgId)
                .WhereIF(!string.IsNullOrWhiteSpace(RoleName),a =>a.RoleName.Contains(RoleName))
                .LeftJoin<lq_user>((a, b) => a.AddUserId == b.Id).Select((a, b) => new lq_sys_role()
                {
                    AddUser = b.User,
                    IsTrue = a.IsDelete == 0 ? "失效" : "有效"
                }, true)
                .ToPageListAsync(Page, Size, count);
            return PageSuccess(data, count);
        }
        /// <summary>
        /// 添加角色
        /// </summary>
        /// <param name="RoleName">角色名称</param>
        /// <param name="RoleDepicted">角色描述</param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("设置>权限设置", "新增角色", ActionType.Add)]
        public async Task<ApiResponse<string>> AddRoleAsync(string RoleName, string? RoleDepicted)
        {
            try
            {
                var Table = dal.Db.Queryable<lq_sys_role>().Where(a => a.OrgId == OrgId);
                var OldData = await Table.Where(a =>a.RoleName == RoleName).FirstAsync();
                if (OldData != null)
                {
                    if (OldData.IsDelete == 0)
                    {
                        throw new Exception("已存在该角色，当前状态已失效，请重新启用！");
                    }
                    else
                    {
                        throw new Exception("已存在该角色，请勿重复添加！"); 
                    }
                }
                else
                {
                    await dal.Db.Insertable(new lq_sys_role()
                    {
                        RoleCode = $"Ro-{DateTime.Now.ToString("yyyyMMdd")}{ Table.Where(a =>a.AddTime.Date == DateTime.Today).Count()+1:D2}",
                        RoleName = RoleName,
                        RoleDepicted = RoleDepicted,
                        OrgId = OrgId,
                        AddUserId = UserId,
                        UpUserId = UserId,
                        IsDelete = 1
                    }).ExecuteCommandAsync();
                    return Success("保存成功！");
                }
            }
            catch (Exception e)
            {
                return Fail<string>("保存失败！" + e.Message);
            }

        }
        /// <summary>
        /// 编辑角色
        /// </summary>
        /// <param name="RoleName"></param>
        /// <param name="RoleDepicted"></param>
        /// <param name="Id"></param>
        /// <returns></returns>
        [HttpGet]
        [OperationLogFilter("设置>权限设置", "角色修改", ActionType.Exit)]
        public async Task<ApiResponse<string>> EditRoleAsync(int Id, string RoleName, string? RoleDepicted)
        {
            try
            {
                var Old = await dal.Db.Queryable<lq_sys_role>().FirstAsync(a => a.Id == Id);
                await dal.Db.Updateable<lq_sys_role>()
                    .SetColumns(a => new lq_sys_role() { RoleName = RoleName, RoleDepicted = RoleDepicted }).Where(a => a.Id == Id).ExecuteCommandAsync();
                return Success("保存成功！");
            }
            catch (Exception e)
            {
                return Fail<string>("保存失败！" + e.Message);
            }
        }
        /// <summary>
        /// 删除角色
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        [HttpDelete("{Id}")]
        [OperationLogFilter("设置>权限设置", "删除角色", ActionType.Delete)]
        public async Task<ApiResponse<string>> DeleteRoleAsync(int Id)
        {
            try
            {
                var Old = await dal.Db.Queryable<lq_sys_role>().FirstAsync(a => a.Id == Id);
                await dal.Db.Updateable<lq_sys_role>()
                    .SetColumns(a => new lq_sys_role() { IsDelete =  0 }).Where(a => a.Id == Id).ExecuteCommandAsync();
                return Success("删除成功！");
            }
            catch (Exception e)
            {

                return Fail<string>("删除失败！" + e.Message);
            }
        }
    }
}
