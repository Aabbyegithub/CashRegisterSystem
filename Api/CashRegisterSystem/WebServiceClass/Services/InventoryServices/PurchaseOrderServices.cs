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
using Microsoft.VisualBasic;

namespace WebServiceClass.Services.InventoryServices
{
    public class PurchaseOrderServices : PurchaseOrderIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public PurchaseOrderServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<sys_purchase_order>>> GetPurchaseOrderListAsync(
            int orgId,
            long? storeId,
            string? poNo,
            long? supplierId,
            byte? status,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_purchase_order>().Includes(a=>a.staff).WhereIF(orgId !=1,a=>a.store_id == orgId || a.store_id == 0);
            if (storeId.HasValue && storeId.Value > 0)
                query = query.Where(x => x.store_id == storeId.Value);
            if (!string.IsNullOrEmpty(poNo))
                query = query.Where(x => x.po_no.Contains(poNo));
            if (supplierId.HasValue && supplierId.Value > 0)
                query = query.Where(x => x.supplier_id == supplierId.Value);
            if (status.HasValue && status.Value > 0)
                query = query.Where(x => x.status == status.Value);

            var list = await query.OrderBy(x => x.po_id, OrderByType.Desc)
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }

        public async Task<ApiResponse<bool>> AddPurchaseOrderAsync(sys_purchase_order order)
        {
            var result = await _dal.Db.Insertable(order).ExecuteCommandAsync() > 0;
            return Success(result, result ? "新增成功" : "新增失败");
        }

        public async Task<ApiResponse<sys_purchase_order>> GetPurchaseOrderDetailAsync(long poId)
        {
            var entity = await _dal.Db.Queryable<sys_purchase_order>().FirstAsync(x => x.po_id == poId);
            return Success(entity, entity != null ? "查询成功" : "未找到记录");
        }

        public async Task<ApiResponse<bool>> CancelPurchaseOrderAsync(long poId)
        {
            var result = await _dal.Db.Updateable<sys_purchase_order>()
                .SetColumns(x => x.status == 4) // 4=已取消
                .Where(x => x.po_id == poId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "取消成功" : "取消失败");
        }

        public async Task<ApiResponse<bool>> SavePurchaseOrderAsync(long poId,long supplier_id)
        {
            var result = await _dal.Db.Updateable<sys_purchase_order>()
                .SetColumns(x =>new sys_purchase_order { status =2,supplier_id = supplier_id}) // 4=已取消
                .Where(x => x.po_id == poId)
                .ExecuteCommandAsync() > 0;
            return Success(result, result ? "确认成功" : "确认失败");
        }

        public async Task<ApiResponse<bool>> ArrivedPurchaseOrderAsync(long poId)
        {
            var result = await _dal.Db.Updateable<sys_purchase_order>()
                .SetColumns(x => x.status == 3) // 3-到货
                .Where(x => x.po_id == poId)
                .ExecuteCommandAsync() > 0;
            var po = await _dal.Db.Queryable<sys_purchase_order>().FirstAsync(a=>a.po_id == poId);

            var material = await _dal.Db.Queryable<sys_raw_material>().FirstAsync(a => a.material_name == po.materialname);
            if(material != null)
            {
                await _dal.Db.Insertable(new sys_inventory
                {
                    batch_no =DateTime.Now.ToString("yyyyMMddHHmmssfff"),
                    material_id = material.material_id,store_id = po.store_id,quantity = (decimal)po.quantity,in_quantity = (decimal)po.quantity,purchase_time = DateTime.Now,
                    supplier_id = po.supplier_id,

                }).ExecuteCommandAsync();
            }
            return Success(result, result ? "到货成功" : "到货失败");
        }
    }
}
