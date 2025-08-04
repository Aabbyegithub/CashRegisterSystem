using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///库存表
    ///</summary>
    [SugarTable("sys_inventory")]
    public partial class sys_inventory
    {
           public sys_inventory(){


           }
           /// <summary>
           /// Desc:库存ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long inventory_id {get;set;}

           /// <summary>
           /// Desc:门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:原材料ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long material_id {get;set;}

           /// <summary>
           /// Desc:批次号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string batch_no {get;set;} = null!;

           /// <summary>
           /// Desc:当前库存数量
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal quantity {get;set;}

           /// <summary>
           /// Desc:入库数量
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal in_quantity {get;set;}

           /// <summary>
           /// Desc:出库数量
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal out_quantity {get;set;}

           /// <summary>
           /// Desc:采购日期
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime purchase_time {get;set;}

           /// <summary>
           /// Desc:保质期到期日
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime expiry_date {get;set;}

           /// <summary>
           /// Desc:供应商ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long supplier_id {get;set;}

           /// <summary>
           /// Desc:锁定数量（已下单未出库）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal lock_quantity {get;set;}

           /// <summary>
           /// Desc:最后更新时间
           /// Default:CURRENT_TIMESTAMP
           /// Nullable:False
           /// </summary>           
           public DateTime updated_at {get;set;}

    }
}
