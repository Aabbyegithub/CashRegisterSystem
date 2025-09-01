using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///订单明细表
    ///</summary>
    [SugarTable("sys_order_item_backup")]
    public partial class sys_order_item_backup
    {
           public sys_order_item_backup(){


           }
           /// <summary>
           /// Desc:明细ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long item_id {get;set;}

           /// <summary>
           /// Desc:所属订单ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long order_id {get;set;}

           /// <summary>
           /// Desc:菜品ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long dish_id {get;set;}

           /// <summary>
           /// Desc:规格ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? spec_id {get;set;}

           /// <summary>
           /// Desc:所属套餐ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? meal_id {get;set;}

           /// <summary>
           /// Desc:数量
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public int quantity {get;set;}

           /// <summary>
           /// Desc:单价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal unit_price {get;set;}

           /// <summary>
           /// Desc:总价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal total_price {get;set;}

           /// <summary>
           /// Desc:烹饪要求（如"微辣"）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? cooking_require {get;set;}

           /// <summary>
           /// Desc:状态（1-待制作；2-制作中；3-已出餐；4-已退菜）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:是否加急（1-是；0-否）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte is_rush {get;set;}

           /// <summary>
           /// Desc:退菜原因（状态为4时填写）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? return_reason {get;set;}

           /// <summary>
           /// Desc:退菜审核员工ID
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? return_audit_id {get;set;}

           /// <summary>
           /// Desc:客户选择规格
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? specification {get;set;}

    }
}
