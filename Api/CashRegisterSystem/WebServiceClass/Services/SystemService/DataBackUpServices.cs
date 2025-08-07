using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;

namespace WebServiceClass.Services.SystemService
{
    public class DataBackUpServices:IBaseService,IDataBackUpServices
    {
        private readonly ISqlHelper _dal;

        public DataBackUpServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }
    }
}
