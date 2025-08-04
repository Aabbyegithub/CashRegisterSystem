using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyNamespace;
using WebIServices.IBase;

namespace WebProjectTest.Controllers.AutherUser
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class OrgController : ControllerBase
    {
        private readonly ISqlHelper _dal;
        public OrgController(ISqlHelper dal)
        {
            _dal = dal;
        }
        /// <summary>
        /// 获取服务系统
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<List<lq_serveorg>> GetOrg()
        {
            return await _dal.Db.Queryable<lq_serveorg>().ToListAsync();
        }

    }
}
