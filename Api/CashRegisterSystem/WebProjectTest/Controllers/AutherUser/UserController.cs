//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using ModelClassLibrary.Model.AutherModel.AutherDto;
//using MyNamespace;
//using Newtonsoft.Json;
//using SqlSugar;
//using WebIServices.IBase;
//using WebProjectTest.Common.Filter;
//using WebServiceClass.Base;
//using WebServiceClass.Helper;
//using static ModelClassLibrary.Model.CommonEnmFixts;
//using static WebProjectTest.Common.Message;

//// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

//namespace WebProjectTest.Controllers.AutherUser
//{
//    /// <summary>
//    /// 验证登陆
//    /// </summary>
//    [Route("api/[controller]/[action]")]
//    [ApiController]
//    [Authorize]
//    public class UserController(IRedisCacheService redisCacheService, ISqlHelper dal, TokenService token) : AutherController(redisCacheService)
//    {
//        private readonly TokenService _token = token;

//        /// <summary>
//        /// 验证登陆
//        /// </summary>
//        /// <param name="UserName"></param>
//        /// <param name="PassWord"></param>
//        /// <param name="orgid"></param>
//        /// <returns></returns>
//        /// <exception cref="Exception"></exception>
//        [HttpGet]
//        [AllowAnonymous]
//        public async Task<ApiResponse<UserResult>> LoginAsync(string UserName, string PassWord, int orgid)
//        {
//            var User = await dal.Db.Queryable<lq_user>().FirstAsync(a => a.UserName == UserName && a.OrgId == orgid && a.IsDelete == 1);
//            if (User == null)
//            {

//                return new ApiResponse<UserResult>(500, false, "该用户不存在", new UserResult());
//            }
//            else
//            {

//                var Istrue = PasswordHelper.VerifyPassword(PassWord, User.PassWord, User.Salt);
//                if (!Istrue)
//                {
//                    return new ApiResponse<UserResult>(500, false, "账号或密码错误", new UserResult());
//                }
//                else
//                {
//                    var org = await dal.Db.Queryable<lq_serveorg>().FirstAsync(a => a.Id == orgid);
//                    if (org == null)
//                        return new ApiResponse<UserResult>(500, false, "没有该服务器", new UserResult());
//                    await dal.Db.Insertable(new lq_operationlog
//                    {
//                        ActionType = ActionType.Landing,
//                        ModuleName = "系统登陆",
//                        OrgId = User.OrgId,
//                        AddUserId =(int) User.Id,
//                        UpUserId = (int)User.Id,
//                        UserId = (int)User.Id,
//                        Description = "人员登陆",
//                        ActionContent = $"账号：{UserName}"
//                    }).ExecuteCommandAsync();
//                    var context = new UserContext
//                    {
//                        UserId = User.Id,
//                        UserName = User.User,
//                        OrgId = User.OrgId,
//                        OrgName = org.ServeName,
//                        PassWord =User.PassWord,
//                        Salt = User.Salt,
//                        RoleId = User.RoleId
//                    };
//                    string token = _token.GenerateToken(User.UserName);
//                    await redisCacheService.SetStringAsync(token, JsonConvert.SerializeObject(context));
//                    return new ApiResponse<UserResult>(200, true, "登陆成功", new UserResult(){ UserId =(int) User.Id,OrgId =(long)User.OrgId,UserName=User.User,Token = token,IsFirst = User.IsFirst });
//                }

//            }
//        }

//        /// <summary>
//        /// 退出系统，删除redis相关数据
//        /// </summary>
//        /// <returns></returns>
//        [HttpGet]
//        [OperationLogFilter("账号登出", "人员退出系统", ActionType.Exit)]
//        public async Task logoutAsync()
//        {
//            var authorizationHeader = Request.Headers["Authorization"].ToString();

//            if (!string.IsNullOrEmpty(authorizationHeader) && authorizationHeader.StartsWith("Bearer "))
//            {
//                // 提取 token
//                var token = authorizationHeader.Substring("Bearer ".Length).Trim();
//                try
//                {
//                    await redisCacheService.RemoveAsync(token);
//                }
//                catch (Exception)
//                {
//                    await dal.Db.Insertable(new lq_operationlog
//                    {
//                        ActionType = ActionType.Exit,
//                        ModuleName = "账号登出异常",
//                        OrgId = OrgId,
//                        AddUserId = UserId,
//                        UpUserId = UserId,
//                        UserId = UserId,
//                        Description = "人员退出系统",
//                        ActionContent = $"账号：{UserName}---->账号登出异常请检查redis连接，缓存未及时清理"
//                    }).ExecuteCommandAsync();
//                }

//            }
 
//        }
//        /// <summary>
//        /// 获取用户数据
//        /// </summary>
//        /// <param name="page"></param>
//        /// <param name="size"></param>
//        /// <returns></returns>
//        [HttpGet]
//        [OperationLogFilter("用户管理>用户列表", "用户分页查询", ActionType.Search)]
//        public async Task<ApiPageResponse<lq_user>> GetUserAsync(int page = 0, int size = 10)
//        {
//            RefAsync<int> count = 0;
//            var Data = await dal.Db.Queryable<lq_user>().Where(a => a.OrgId == OrgId ).ToPageListAsync(page, size, count);
//            return new ApiPageResponse<lq_user>(200, true, "Success", Data, count);
//        }

//        /// <summary>
//        /// 添加新用户
//        /// </summary>
//        /// <param name="User"></param>
//        /// <returns></returns>
//        [HttpPost]
//        public async Task<ApiResponse<string>> AddUserAsync([FromBody] lq_user User)
//        {
//            var (hashpassword, salt) = PasswordHelper.HashPassword(User.PassWord);
//            var istrue = await dal.Db.Queryable<lq_user>().FirstAsync(a => a.UserName == User.UserName && a.OrgId == OrgId && a.IsDelete == 1);
//            if (istrue != null)
//            {
//                return Fail<string>("账号密码已存在！");
//            }
//            User.PassWord = hashpassword;User.Salt = salt;User.IsDelete = 1;
//            var id = await dal.Db.Insertable<lq_user>(User).ExecuteCommandAsync();
//            if (id == 0)
//                return Error<string>("账号密码保存失败！");
//            else
//                return Success<string>(id.ToString(), "账号创建成功！");
//        }

//        /// <summary>
//        /// 修改密码
//        /// </summary>
//        /// <param name="User"></param>
//        /// <returns></returns>
//        [HttpPost]
//        public async Task<ApiResponse<string>> UpdateAsync([FromBody] UserParam User)
//        {
//            var date = await dal.Db.Queryable<lq_user>().FirstAsync(a => a.OrgId == OrgId && a.UserName == UserName && a.IsDelete == 1);
//            if (date != null)
//            {
//                if (!PasswordHelper.VerifyPassword(User.OldPassword,date.PassWord,date.Salt))
//                {
//                    return Fail<string>("账号或密码错误！");
//                }
//                var (hashpassword, salt) = PasswordHelper.HashPassword(User.NewPassword);
//                date.Salt = salt; date.PassWord = hashpassword;
//                var id = await dal.Db.Updateable<lq_user>(date).ExecuteCommandAsync();
//                if (id == 0)
//                    return Error<string>("修改密码发生错误！");
//                else
//                    return Success("", "密码修改成功！");
//            }
//            else
//                return Fail<string>( "账号或密码错误！");

//        }

//        /// <summary>
//        /// 注销账号
//        /// </summary>
//        [HttpDelete]
//        public async Task<int> DeleteAsync()
//        {
//            return await dal.Db.Deleteable<lq_user>().Where(a => a.OrgId == OrgId && a.UserName == UserName && a.PassWord == PassWord && a.Salt == Salt).ExecuteCommandAsync();
//        }

//        /// <summary>
//        /// 管理员删除
//        /// </summary>
//        /// <param name="id"></param>
//        /// <returns></returns>
//        [HttpDelete("{id}")]
//        [OperationLogFilter("用户管理>用户列表", "管理员删除", ActionType.Delete)]
//        public async Task<int> ManageDeleteAsync(int id)
//        {
//            var old = await dal.Db.Queryable<lq_user>().FirstAsync();
//            return await dal.Db.Deleteable<lq_user>().Where(a => a.Id == id).ExecuteCommandAsync();
//        }

//        /// <summary>
//        /// 获取用户数据
//        /// </summary>
//        /// <returns></returns>
//        [HttpGet]
//        public async Task<ApiResponse<lq_user>> GetUserMsgAsync()
//        {
//            return Success<lq_user>(await dal.Db.Queryable<lq_user>().Where(a=>a.Id == UserId).Select(a =>new lq_user(){User = a.User,UserName = a.UserName,Phone = a.Phone,Email = a.Email }).FirstAsync());
//        }
//    }
//}
