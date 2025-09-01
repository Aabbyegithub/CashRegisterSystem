using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///厨房订单表（KDS系统同步）
    ///</summary>
    [SugarTable("sys_kitchen_order_backup")]
    public partial class sys_kitchen_order_backup
    {
           public sys_kitchen_order_backup(){


           }
           /// <summary>
           /// Desc:厨房订单ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long kitchen_id {get;set;}

           /// <summary>
           /// Desc:关联订单明细ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long item_id {get;set;}

           /// <summary>
           /// Desc:门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:桌台编号（冗余，方便打印）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string table_no {get;set;} = null!;

           /// <summary>
           /// Desc:菜品名称（冗余）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string dish_name {get;set;} = null!;

           /// <summary>
           /// Desc:规格名称（冗余）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? spec_name {get;set;}

           /// <summary>
           /// Desc:数量
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public int quantity {get;set;}

           /// <summary>
           /// Desc:烹饪要求
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? cooking_require {get;set;}

           /// <summary>
           /// Desc:目标厨房（热菜/凉菜/饮品）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string kitchen_type {get;set;} = null!;

           /// <summary>
           /// Desc:状态（1-待制作；2-制作中；3-已完成；4-已取餐；5-已退菜）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:派单时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime create_time {get;set;}

           /// <summary>
           /// Desc:完成时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? finish_time {get;set;}

           /// <summary>
           /// Desc:取餐时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? pick_time {get;set;}

           /// <summary>
           /// Desc:超时预警（0-未预警；1-已预警）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte overtime_warn {get;set;}

           /// <summary>
           /// Desc:厨师ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? cook_id {get;set;}

           /// <summary>
           /// Desc:取餐员ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? picker_id {get;set;}

    }
}
