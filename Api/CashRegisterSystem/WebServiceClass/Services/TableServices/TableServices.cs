using Microsoft.EntityFrameworkCore.Metadata.Internal;
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
        private readonly IAppSettinghelper _AppSetting;
        public TableServices(ISqlHelper dal, IAppSettinghelper appSetting)
        {
            _dal = dal ?? throw new ArgumentNullException(nameof(dal));
            _AppSetting = appSetting ?? throw new ArgumentNullException(nameof(appSetting));
        }
        public async Task<ApiResponse<bool>> AddTableAsync(sys_restaurant_table table)
        {
            try
            {
                string _windowsBasePath = _AppSetting.Get("UpFile:Windows");
                string _linuxBasePath = _AppSetting.Get("UpFile:Linux");
                string _Url = _AppSetting.Get("UpFile:FileUrl");
                var id = await _dal.Db.Insertable(table).ExecuteReturnIdentityAsync();
                table.table_id = id;
                string appid = _AppSetting.Get("WhChat:appId");
                string secret = _AppSetting.Get("WhChat:appSecret");
                using var httpClient = new HttpClient();
                var tokenResp = await httpClient.GetAsync($"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={appid}&secret={secret}");
                var tokenJson = await tokenResp.Content.ReadAsStringAsync();
                var tokenObj = System.Text.Json.JsonDocument.Parse(tokenJson).RootElement;
                string accessToken = tokenObj.GetProperty("access_token").GetString();
                var qrApi = $"https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token={accessToken}";
                var qrParam = new
                {
                    scene = $"storeId={table.store_id}&tableId={table.table_id}", // 自定义参数
                    page = "pages/table/index", // 小程序页面路径
                    width = 430
                };
                var qrContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(qrParam), Encoding.UTF8, "application/json");
                var qrResp = await httpClient.PostAsync(qrApi, qrContent);
                var qrBytes = await qrResp.Content.ReadAsByteArrayAsync();

                // 保存二维码图片到服务器
                string folder = OperatingSystem.IsWindows() ? _windowsBasePath : _linuxBasePath;
                if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                string fileName = $"table_{table.table_id}.png";
                string filePath = Path.Combine(folder, fileName);
                await File.WriteAllBytesAsync(filePath, qrBytes);

                string relativePath = Path.GetRelativePath(folder, filePath)
                          .Replace(Path.DirectorySeparatorChar, '/');

                // 7. 拼接正确的URL（确保URL前缀以"/"结尾，避免拼接错误）
                string fullUrl = $"{_Url.TrimEnd('/')}/{relativePath}";
                // 5. 更新二维码路径到数据库
                table.qrcode_url = fullUrl;
                await _dal.Db.Updateable(table).UpdateColumns(x => x.qrcode_url).Where(x => x.table_id == table.table_id).ExecuteCommandAsync();

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

        public async Task<ApiResponse<bool>> RegenerateTableAsync(long tableId)
        {
            try
            {
                string _windowsBasePath = _AppSetting.Get("UpFile:Windows");
                string _linuxBasePath = _AppSetting.Get("UpFile:Linux");
                string _Url = _AppSetting.Get("UpFile:FileUrl");
                var table = await _dal.Db.Queryable<sys_restaurant_table>().Where(a=>a.table_id == tableId).FirstAsync();
                string appid = _AppSetting.Get("WhChat:appId");
                string secret = _AppSetting.Get("WhChat:appSecret");
                using var httpClient = new HttpClient();
                var tokenResp = await httpClient.GetAsync($"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={appid}&secret={secret}");
                var tokenJson = await tokenResp.Content.ReadAsStringAsync();
                var tokenObj = System.Text.Json.JsonDocument.Parse(tokenJson).RootElement;
                string accessToken = tokenObj.GetProperty("access_token").GetString();
                var qrApi = $"https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token={accessToken}";
                var qrParam = new
                {
                    scene = $"storeId={table.store_id}&tableId={table.table_id}", // 自定义参数
                    page = "pages/table/index", // 小程序页面路径
                    width = 430
                };
                var qrContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(qrParam), Encoding.UTF8, "application/json");
                var qrResp = await httpClient.PostAsync(qrApi, qrContent);
                var qrBytes = await qrResp.Content.ReadAsByteArrayAsync();

                // 保存二维码图片到服务器
                string folder = OperatingSystem.IsWindows() ? _windowsBasePath : _linuxBasePath;
                if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                string fileName = $"table_{table.table_id}.png";
                string filePath = Path.Combine(folder, fileName);
                await File.WriteAllBytesAsync(filePath, qrBytes);

                string relativePath = Path.GetRelativePath(folder, filePath)
                          .Replace(Path.DirectorySeparatorChar, '/');

                // 7. 拼接正确的URL（确保URL前缀以"/"结尾，避免拼接错误）
                string fullUrl = $"{_Url.TrimEnd('/')}/{relativePath}";
                // 5. 更新二维码路径到数据库
                table.qrcode_url = fullUrl;
                await _dal.Db.Updateable(table).UpdateColumns(x => x.qrcode_url).Where(x => x.table_id == table.table_id).ExecuteCommandAsync();

                return Success(true, "重新生成桌台二维码成功");
            }
            catch (Exception ex)
            {
                return Error<bool>($"生成桌台二维码失败:{ex.Message}");
            }
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
