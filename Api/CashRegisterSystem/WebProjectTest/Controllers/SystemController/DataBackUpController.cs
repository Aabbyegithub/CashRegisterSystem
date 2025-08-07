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
    public class DataBackUpController(IRedisCacheService redisCacheService) : AutherController(redisCacheService)
    {
        private readonly IDataBackUpServices _RoleServices;
    }
}
