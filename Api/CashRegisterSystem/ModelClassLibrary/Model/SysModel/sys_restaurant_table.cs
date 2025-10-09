using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///桌台信息表
    ///</summary>
    [SugarTable("sys_restaurant_table")]
    public partial class sys_restaurant_table
    {
           public sys_restaurant_table(){


           }
           /// <summary>
           /// Desc:桌台ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long table_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:桌台编号（如"1号桌"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string table_no {get;set;} = null!;

           /// <summary>
           /// Desc:可容纳人数
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int capacity {get;set;}

           /// <summary>
           /// Desc:类型（散台/包间/吧台）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int? table_type {get;set;} = null!;

           /// <summary>
           /// Desc:状态（1-空闲；2-占用；3-预订；4-清洁中）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:最低消费（包间专用）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal min_consumption {get;set;}

           /// <summary>
           /// Desc:
           /// Default:CURRENT_TIMESTAMP
           /// Nullable:False
           /// </summary>           
           public DateTime created_at {get;set;}

           /// <summary>
           /// Desc:
           /// Default:CURRENT_TIMESTAMP
           /// Nullable:False
           /// </summary>           
           public DateTime updated_at {get;set;}

        /// <summary>
        /// Desc:订单id
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>   
        public int? order_id {get;set;}

        /// <summary>
        /// Desc:桌台描述
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>  
        public string desc {get;set;}

        /// <summary>
        /// Desc:桌台描述
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>  
        public DateTime? lastUseTime { get; set; }

        public string? qrcode_url { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(order_id), nameof(sys_order.order_id))]//一对一 
        public sys_order? order { get; set; }

    }
}
