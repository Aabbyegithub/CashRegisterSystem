using ModelClassLibrary.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;

namespace WebIServices.IServices.AutherServices
{
    public interface IAutherService:IBaseService
    {
         Task<string> AddAsync();
    }
}
