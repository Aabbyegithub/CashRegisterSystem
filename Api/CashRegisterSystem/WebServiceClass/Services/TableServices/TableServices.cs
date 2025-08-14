using MyNamespace;
using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebIServices.IBase;
using WebIServices.IServices.TableMangeIServices;
using static WebProjectTest.Common.Message;

namespace WebServiceClass.Services.TableServices
{
    public class TableServices : IBaseService, ITableServices
    {
        private readonly ISqlHelper _dal;

        public TableServices(ISqlHelper dal)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
        }
        public async Task<ApiResponse<bool>> AddTableAsync(sys_restaurant_table table)
        {
           try
            {
                await _dal.Db.Insertable(table).ExecuteCommandAsync();
                return Success(true, "添加桌台成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"添加桌台失败:{ex.Message}");
            }
        }

        public async Task<ApiResponse<bool>> DeleteTableAsync(List<int> tableIds)
        {
            try
            {
                await _dal.Db.Deleteable<sys_restaurant_table>().In(tableIds).ExecuteCommandAsync();
                return Success(true, "删除桌台成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"删除桌台失败:{ex.Message}");
            }
        }

        public Task<List<sys_restaurant_table>> GetTableListAsync(int? tableType, int? status, string? tableCode, int orgId, int page, int size, RefAsync<int> count)
        {
            return _dal.Db.Queryable<sys_restaurant_table>()
                .WhereIF(tableType.HasValue, x => x.table_type == tableType)
                .WhereIF(status.HasValue, x => x.status == status)
                .WhereIF(!string.IsNullOrEmpty(tableCode), x => x.table_no.Contains(tableCode))
                .WhereIF(orgId != 1, x => x.store_id == orgId)
                .OrderBy(x => x.table_no)
                .ToPageListAsync(page, size, count);
        }

        public async Task<ApiResponse<bool>> UpdateTableAsync(sys_restaurant_table table)
        {
            try
            {
                await _dal.Db.Updateable(table).ExecuteCommandAsync();
                return Success(true, "修改桌台成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"修改桌台失败:{ex.Message}");
            }
        }
    }
}
