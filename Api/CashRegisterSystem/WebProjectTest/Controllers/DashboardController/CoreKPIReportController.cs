using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IBase;
using WebIServices.IServices.DishIServise;
using WebProjectTest.Controllers.SystemController;

namespace WebProjectTest.Controllers.DashboardController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CoreKPIReportController(IRedisCacheService redisCacheService, IDishServices _DishServices) : AutherController(redisCacheService)
    {

    }
}
