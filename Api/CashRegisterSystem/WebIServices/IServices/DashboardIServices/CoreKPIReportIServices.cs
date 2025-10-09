using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static ModelClassLibrary.Model.Dto.DashboardDto.Dashboard;

namespace WebIServices.IServices.DashboardIServices
{
    public interface CoreKPIReportIServices : IBaseService
    {
        /// <summary>
        /// 获取餐饮运营核心指标看板数据
        /// </summary>
        Task<KPIDashboardDto> GetDashboardDataAsync();
    }
}
