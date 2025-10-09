using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.SystemIServices
{
    public interface IDataBackUpServices:IBaseService
    {
        /// <summary>
        /// 获取备份列表
        /// </summary>
        /// <returns></returns>
        Task<ApiPageResponse<List<sys_backup>>> GetBackUpListAsync(string? name, int page, int size,RefAsync<int> count);
        /// <summary>
        /// 添加备份
        /// </summary>
        /// <param name="backupName"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> AddBackUpAsync();

    }
}
