using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;
using WebProjectTest.Controllers.SystemController;

namespace WebProjectTest.Controllers.TableManagController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class TableController(IRedisCacheService redisCacheService, IStoreServices _StoreServices) : AutherController(redisCacheService)
    {

    }
}
