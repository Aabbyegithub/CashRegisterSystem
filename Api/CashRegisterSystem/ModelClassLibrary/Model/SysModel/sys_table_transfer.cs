using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///桌台转桌记录表
    ///</summary>
    [SugarTable("sys_table_transfer")]
    public partial class sys_table_transfer
    {
           public sys_table_transfer(){


           }
           /// <summary>
           /// Desc:记录ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long transfer_id {get;set;}

           /// <summary>
           /// Desc:关联订单ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long order_id {get;set;}

           /// <summary>
           /// Desc:原桌台ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long old_table_id {get;set;}

           /// <summary>
           /// Desc:新桌台ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long new_table_id {get;set;}

           /// <summary>
           /// Desc:转桌时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime transfer_time {get;set;}

           /// <summary>
           /// Desc:操作员工ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long operator_id {get;set;}

           /// <summary>
           /// Desc:转桌原因
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? remark {get;set;}
        /// <summary>
        /// Desc:1:转桌；2并桌
        /// Default:
        /// Nullable:True
        /// </summary>  
        public int type {get;set;}

        //[Navigate(NavigateType.OneToOne, nameof(old_table_id), nameof(sys_restaurant_table.table_id))]//一对一 
        //public sys_restaurant_table? table { get; set; }

        //[Navigate(NavigateType.OneToOne, nameof(new_table_id), nameof(sys_restaurant_table.table_id))]//一对一 
        //public sys_restaurant_table? table { get; set; }

    }
}
