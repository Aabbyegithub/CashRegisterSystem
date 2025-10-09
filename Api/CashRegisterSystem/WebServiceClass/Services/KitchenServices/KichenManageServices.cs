using MyNamespace;
using SqlSugar;
using WebIServices.IBase;
using WebIServices.IServices.KitchenIServices;
using static WebProjectTest.Common.Message;

public class KichenManageServices :IBaseService, KichenManageIServices
{
    private readonly ISqlHelper _dal;

    public KichenManageServices(ISqlHelper dal)
    {
        _dal = dal;
    }

    public async Task<List<sys_kitchen>> GetkitchenListAsync(int? storeId, string? kitchenType, int orgId, int page, int size, RefAsync<int> count)
    {
        return await _dal.Db.Queryable<sys_kitchen>()
            .WhereIF(storeId.HasValue, x => x.store_id == storeId)
            .WhereIF(!string.IsNullOrEmpty(kitchenType), x => x.kitchen_type == kitchenType)
            .ToPageListAsync(page, size, count);
    }

    public async Task<ApiResponse<bool>> AddkitchenAsync(sys_kitchen kitchen)
    {
        var result = await _dal.Db.Insertable(kitchen).ExecuteCommandAsync() > 0;
        return Success(result, result ? "添加成功" : "添加失败");
    }

    public async Task<ApiResponse<bool>> DeleteKitchenAsync(int kitchenId)
    {
        var result = await _dal.Db.Deleteable<sys_kitchen>().In(kitchenId).ExecuteCommandAsync() > 0;
        return Success(result, result ? "删除成功" : "删除失败");
    }

    public async Task<ApiResponse<bool>> UpdateKitchenAsync(sys_kitchen kitchen)
    {
        var result = await _dal.Db.Updateable(kitchen).ExecuteCommandAsync() > 0;
        return Success(result, result ? "修改成功" : "修改失败");
    }

    public Task<List<sys_kitchen>> GetAllKichenListAsync()
    {
        return _dal.Db.Queryable<sys_kitchen>()
            .ToListAsync();
    }
}