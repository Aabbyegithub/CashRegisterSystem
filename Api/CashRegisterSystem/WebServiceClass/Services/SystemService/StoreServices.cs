using Azure;
using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.SystemIServices;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.SystemService
{
    public class StoreServices:IBaseService, IStoreServices
    {
        private readonly ISqlHelper _dal;

        public StoreServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }

        public async Task<ApiResponse<bool>> AddStoreAsync(sys_store sys_Store)
        {
            try
            {
                sys_Store.store_code = $"STORE-{DateTime.Now.ToString("yyyyMMddHHmmssfff")}";
                await _dal.Db.Insertable(sys_Store)
                    .ExecuteCommandAsync();
                return Success<bool>(true, "商店添加成功");
            }
            catch (Exception)
            {
                return Error<bool>("商店添加失败，请稍后重试");
            }
        }

        public async Task<ApiResponse<bool>> DeleteStoreAsync(List<int> storeIds)
        {
            try
            {
                await _dal.Db.Deleteable<sys_store>()
                    .In(storeIds)
                    .ExecuteCommandAsync();
                return Success<bool>(true, "商店删除成功");
            }
            catch (Exception)
            {
                return Error<bool>("商店删除失败，请稍后重试");
            }
        }

        public async Task<ApiPageResponse<List<sys_store>>> GetStoreListAsync(string StoreName, string phone, string address, int page, int size, RefAsync<int> count)
        {
            try
            {
                var res = await _dal.Db.Queryable<sys_store>()
                    .WhereIF(!string.IsNullOrEmpty(StoreName), a => a.store_name.Contains(StoreName))
                    .WhereIF(!string.IsNullOrEmpty(phone), a => a.phone.Contains(phone))
                    .WhereIF(!string.IsNullOrEmpty(address), a => a.address.Contains(address))
                    .Where(a=>!a.store_name.Contains("管理员"))
                    .ToPageListAsync(page, size,count);
                return PageSuccess(res,count,"商店列表获取成功");
            }
            catch (Exception)
            {
                return PageError <List<sys_store>>( "商店列表获取失败，请稍后重试");
            }
        }

        public async Task<ApiResponse<List<sys_store>>> GetStoreListAsync(int orgId)
        {
            try
            {
                var res = await _dal.Db.Queryable<sys_store>()
                    .WhereIF(orgId != 1,a=>a.store_id == orgId)
                    .ToListAsync();
                return Success(res,  "商店列表获取成功");
            }
            catch (Exception)
            {
                return Error<List<sys_store>>("商店列表获取失败，请稍后重试");
            }
        }

        public async Task<ApiResponse<bool>> UpdateStoreAsync(sys_store sys_Store)
        {
            try
            {
                await _dal.Db.Updateable(sys_Store)
                    .ExecuteCommandAsync();
                return Success<bool>(true, "商店信息更新成功");
            }
            catch (Exception)
            {

               return Error<bool>("商店信息更新失败，请稍后重试");
            }
        }

        public async Task<ApiResponse<bool>> UpdateStoreAsync(int storeId, byte status)
        {
            try
            {
                await _dal.Db.Updateable<sys_store>()
                    .SetColumns(a => new sys_store { status = status })
                    .Where(a => a.store_id == storeId)
                    .ExecuteCommandAsync();
                return Success<bool>(true, "商店状态更新成功");
            }
            catch (Exception)
            {
                return Error<bool>("商店状态更新失败，请稍后重试");
            }
        }
    }
}
