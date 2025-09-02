using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using WebIServices.IBase;
using WebIServices.IServices.DashboardIServices;
using WebIServices.IServices.DishIServise;
using WebProjectTest.Controllers.SystemController;
using static ModelClassLibrary.Model.Dto.DashboardDto.Dashboard;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.DashboardController
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CoreKPIReportController(IRedisCacheService redisCacheService, CoreKPIReportIServices _Services) : AutherController(redisCacheService)
    {
        [HttpGet]
         public async Task<ApiResponse< KPIDashboardDto>> GetDashboardDataAsync()
        {
            return Success(await _Services.GetDashboardDataAsync());
        }
    }
}
