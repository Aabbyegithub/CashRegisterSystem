using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using static WebProjectTest.Common.Message;

namespace WebIServices.IServices.TableMangeIServices
{
    public interface ITableServices:IBaseService
    {
        /// <summary>
        /// 获取桌台列表
        /// </summary>
        /// <param name="tableType"></param>
        /// <param name="status"></param>
        /// <param name="tableCode"></param>
        /// <param name="orgId"></param>
        /// <param name="page"></param>
        /// <param name="size"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        Task<List<sys_restaurant_table>> GetTableListAsync(int? tableType,int? status,string?tableCode, int orgId,int page,int size,RefAsync<int>count);

        /// <summary>
        /// 添加桌台
        /// </summary>
        /// <param name="table"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> AddTableAsync(sys_restaurant_table table);

        /// <summary>
        /// 删除桌台
        /// </summary>
        /// <param name="storeId"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> DeleteTableAsync(List<int> tableIds);

        /// <summary>
        /// 重新生成桌台二维码
        /// </summary>
        /// <param name="tableIds"></param>
        /// <returns></returns>
        Task<ApiResponse<bool>> RegenerateTableAsync(long tableId);

        ///<summary>
        ///修改桌台
        ///<summary>
        Task<ApiResponse<bool>> UpdateTableAsync(sys_restaurant_table  table);
    }
}
