using ModelClassLibrary.Model.Dto.AppDto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.ClientIServices;
using WebProjectTest.Common;

namespace WebServiceClass.Services.AppServices
{
    public class ClientServices : IBaseService, IClientServices
    {
        private readonly ISqlHelper _dal;

        public TableServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }
        public Task<Message.ApiResponse<List<ClientModel>>> GetTableListInfo(int store_id)
        {
            throw new NotImplementedException();
        }
    }
}
