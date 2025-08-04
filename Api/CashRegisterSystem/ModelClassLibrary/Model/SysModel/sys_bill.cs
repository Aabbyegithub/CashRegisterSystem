using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///账单表
    ///</summary>
    [SugarTable("sys_bill")]
    public partial class sys_bill
    {
           public sys_bill(){


           }
           /// <summary>
           /// Desc:账单ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long bill_id {get;set;}

           /// <summary>
           /// Desc:主订单ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long order_id {get;set;}

           /// <summary>
           /// Desc:账单编号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string bill_no {get;set;} = null!;

           /// <summary>
           /// Desc:父账单ID（分单时用，主单为0）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public long parent_bill_id {get;set;}

           /// <summary>
           /// Desc:总金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal total_amount {get;set;}

           /// <summary>
           /// Desc:优惠金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal discount_amount {get;set;}

           /// <summary>
           /// Desc:服务费
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal service_fee {get;set;}

           /// <summary>
           /// Desc:应付金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal payable_amount {get;set;}

           /// <summary>
           /// Desc:已付金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal paid_amount {get;set;}

           /// <summary>
           /// Desc:类型（1-正常账单；2-分单账单；3-宴会账单）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte bill_type {get;set;}

           /// <summary>
           /// Desc:打印状态（0-未打印；1-已打印）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte print_status {get;set;}

           /// <summary>
           /// Desc:结账时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime close_time {get;set;}

           /// <summary>
           /// Desc:发票状态（0-未开；1-已开电子发票）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte invoice_status {get;set;}

           /// <summary>
           /// Desc:电子发票号码（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? invoice_no {get;set;}

    }
}
