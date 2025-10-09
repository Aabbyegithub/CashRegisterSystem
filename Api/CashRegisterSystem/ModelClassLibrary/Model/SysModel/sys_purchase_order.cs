using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///采购单表
    ///</summary>
    [SugarTable("sys_purchase_order")]
    public partial class sys_purchase_order
    {
           public sys_purchase_order(){


           }
           /// <summary>
           /// Desc:采购单ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long po_id {get;set;}

           /// <summary>
           /// Desc:门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:采购单号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string po_no {get;set;} = null!;

           /// <summary>
           /// Desc:供应商ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long supplier_id {get;set;}

           /// <summary>
           /// Desc:下单时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime order_time {get;set;}

           /// <summary>
           /// Desc:预计到货时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime expect_arrival_time {get;set;}

           /// <summary>
           /// Desc:实际到货时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? actual_arrival_time {get;set;}

           /// <summary>
           /// Desc:采购总金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal total_amount {get;set;}

           /// <summary>
           /// Desc:状态（1-待确认；2-已确认；3-已到货；4-已取消）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:下单员工ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long operator_id {get;set;}

           /// <summary>
           /// Desc:备注
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? remark {get;set;}
           public string? materialname {get;set;}
           public int? quantity {get;set;}

        [Navigate(NavigateType.OneToOne, nameof(operator_id), nameof(sys_staff.staff_id))]//一对一 
        public sys_staff? staff { get; set; }

    }
}
