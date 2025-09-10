using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.InventoryIServices;
using static WebProjectTest.Common.Message;
using WebIServices.IBase;

namespace WebServiceClass.Services.InventoryServices
{
    public class LossServices : LossIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public LossServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_inventory_loss>>> GetLossListAsync(
            int orgId,
            long? storeId,
            long? materialId,
            int? lossType,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_inventory_loss>().Includes(a=>a.staff).WhereIF(orgId !=1,a=>a.store_id == orgId || a.store_id == 0);
            if (storeId.HasValue && storeId.Value > 0)
                query = query.Where(x => x.store_id == storeId.Value);
            if (materialId.HasValue && materialId.Value > 0)
                query = query.Where(x => x.material_id == materialId.Value);
            if (lossType.HasValue && lossType.Value >= 0)
                query = query.Where(x => x.loss_type == lossType);

            var list = await query.OrderBy(x => x.loss_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }

        public async Task<ApiResponse<bool>> AddLossAsync(sys_inventory_loss loss, int orgId,int userId)
        {
            loss.loss_time = DateTime.Now;loss.store_id = orgId;loss.operator_id = userId;
            loss.batch_no = DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(100000, 999999);
            var result = await _dal.Db.Insertable(loss).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<bool>> UpdateLossAsync(sys_inventory_loss loss,int userId)
        {
            
            await _dal.Db.Updateable<sys_inventory_loss>().SetColumns(a=>new sys_inventory_loss
            {
                loss_type = loss.loss_type,
                loss_quantity = loss.loss_quantity,
                loss_reason = loss.loss_reason,
                updateuser_id = userId,
                updatetime = DateTime.Now
            }).Where(a=>a.loss_id == loss.loss_id).ExecuteCommandAsync();
            return Success(true, "更新成功" );
        }

        public async Task<ApiResponse<bool>> DelLossDetailAsync(long lossId)
        {
            var entity = await _dal.Db.Deleteable<sys_inventory_loss>().Where(x => x.loss_id == lossId).ExecuteCommandAsync();
            return  Success(true, "删除成功");
        }

        public async Task<ApiResponse<sys_inventory_loss>> GetLossDetailAsync(long lossId)
        {
            var entity = await _dal.Db.Queryable<sys_inventory_loss>().FirstAsync(x => x.loss_id == lossId);
            return Success(entity, entity != null ? "查询成功" : "未找到记录");
        }
    }
}
