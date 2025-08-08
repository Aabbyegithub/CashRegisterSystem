using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;

namespace WebIServices.IServices.SystemIServices
{
    public interface IDataBackUpServices:IBaseService
    {
        /// <summary>
        /// 获取备份列表
        /// </summary>
        /// <returns></returns>
        Task<List<string>> GetBackUpListAsync();
        /// <summary>
        /// 获取备份信息
        /// </summary>
        /// <param name="backupId"></param>
        /// <returns></returns>
        Task<string> GetBackUpInfoAsync(string backupId);
        /// <summary>
        /// 添加备份
        /// </summary>
        /// <param name="backupName"></param>
        /// <returns></returns>
        Task<bool> AddBackUpAsync(string backupName);

    }
}
