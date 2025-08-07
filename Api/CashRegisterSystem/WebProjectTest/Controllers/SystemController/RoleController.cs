using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;

namespace WebProjectTest.Controllers.SystemController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class RoleController(IRedisCacheService redisCacheService) : AutherController(redisCacheService)
    {
        private readonly IRoleServices _RoleServices;
    }
}
