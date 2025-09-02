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
using static ModelClassLibrary.Model.Dto.inventoryDto.inventory;

namespace WebServiceClass.Services.InventoryServices
{
    public class InventoryAlertServices : InventoryAlertIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public InventoryAlertServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<ApiPageResponse<List<InventoryAlertDto>>> GetInventoryAlertListAsync(
            int orgId,
            long? storeId,
            long? materialId,
            string? category,
            int pageIndex,
            int pageSize,
            RefAsync<int> totalCount)
        {
            var query = _dal.Db.Queryable<sys_inventory>()
                .LeftJoin<sys_raw_material>((inv, mat) => inv.material_id == mat.material_id)
                .GroupBy((inv, mat) => new
                {
                    mat.material_id,    
                    mat.material_name, 
                    mat.category,      
                    mat.unit,           
                    mat.warning_threshold, 
                    mat.status,        
                    mat.store_id       
                })
             
                .Select((inv, mat) => new InventoryAlertDto
                {
                    material_id = mat.material_id,
                    material_name = mat.material_name,
                    category = mat.category,
                    unit = mat.unit,
                    quantity = SqlFunc.AggregateSum(inv.quantity),    
                    in_quantity = SqlFunc.AggregateSum(inv.in_quantity), 
                    out_quantity = SqlFunc.AggregateSum(inv.out_quantity), 
                    warning_threshold = mat.warning_threshold,
                    status = mat.status,
                    store_id = mat.store_id
                });

            if (storeId.HasValue && storeId.Value > 0)
                query = query.Where(x => x.store_id == storeId.Value);
            if (materialId.HasValue && materialId.Value > 0)
                query = query.Where(x => x.material_id == materialId.Value);
            if (!string.IsNullOrEmpty(category))
                query = query.Where(x => x.category == category);

            var list = await query
                                  .ToPageListAsync(pageIndex, pageSize, totalCount);
            return PageSuccess(list, totalCount);
        }

        public async Task<ApiResponse<bool>> PurchaseMaterialAsync(long materialId, decimal quantity, string remark, int userId,int orgId)
        {
            // 查询原材料信息
            var material = await _dal.Db.Queryable<sys_raw_material>().FirstAsync(x => x.material_id == materialId);
            if (material == null)
                return Fail<bool>("原材料不存在");

            // 生成采购单
            var purchaseOrder = new sys_purchase_order
            {
                po_no = DateTime.Now.ToString("yyyyMMddHHmmssfff"),
                store_id = orgId,
                supplier_id = 0, 
                order_time = DateTime.Now,
                expect_arrival_time = DateTime.Now.AddDays(1),
                actual_arrival_time = null,
                total_amount = material.purchase_price * quantity,
                status = 1, // 待确认
                operator_id = userId, 
                remark = remark,
                materialname =material.material_name,
                quantity =(int) quantity
            };
            var result = await _dal.Db.Insertable(purchaseOrder).ExecuteCommandAsync() > 0;
            return Success(result, result ? "采购单已生成" : "采购失败");
        }
    }
}