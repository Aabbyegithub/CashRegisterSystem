using ModelClassLibrary.Model.Dto.AppDto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.ClientIServices
{
    public interface IClientServices:IBaseService
    {
        /// <summary>
        /// 获取当前门店相关桌台信息
        /// </summary>
        /// <param name="store_id"></param>
        /// <returns></returns>
        Task<ApiResponse<List<ClientModel>>> GetTableListInfo(int store_id);
    }
}
