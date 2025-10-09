using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///库存损耗表
    ///</summary>
    [SugarTable("sys_inventory_loss")]
    public partial class sys_inventory_loss
    {
           public sys_inventory_loss(){


           }
           /// <summary>
           /// Desc:损耗ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long loss_id {get;set;}

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
           public string? batch_no {get;set;}

           /// <summary>
           /// Desc:损耗数量
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal loss_quantity {get;set;}

           /// <summary>
           /// Desc:类型（1-变质；2-加工损耗；3-其他）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte loss_type {get;set;}

           /// <summary>
           /// Desc:损耗原因
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? loss_reason {get;set;}

           /// <summary>
           /// Desc:登记时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime loss_time {get;set;}
           public DateTime? updatetime { get;set;}

           /// <summary>
           /// Desc:操作员工ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long operator_id {get;set;}
           public long? updateuser_id { get;set;}


        [Navigate(NavigateType.OneToOne, nameof(operator_id), nameof(sys_staff.staff_id))]//一对一 
        public sys_staff? staff { get; set; }

    }
}
