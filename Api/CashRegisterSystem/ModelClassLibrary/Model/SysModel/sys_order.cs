using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///订单主表
    ///</summary>
    [SugarTable("sys_order")]
    public partial class sys_order
    {
           public sys_order(){


           }
           /// <summary>
           /// Desc:订单ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long order_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:桌台ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long table_id {get;set;}

           /// <summary>
           /// Desc:订单编号（唯一）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string order_no {get;set;} = null!;

           /// <summary>
           /// Desc:会员ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? member_id {get;set;}

           /// <summary>
           /// Desc:类型（1-堂食；2-外卖；3-自提）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte order_type {get;set;}

           /// <summary>
           /// Desc:下单方式（1-服务员端；2-扫码点餐；3-触屏点餐；4-外卖平台）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte source_type {get;set;}

           /// <summary>
           /// Desc:状态（1-待支付；2-已下单；3-已完成；4-已取消；5-挂单；6-预订；7-已并如其他订单,8-退款）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:订单总金额
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
           /// Desc:桌台费/包间费
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal table_fee {get;set;}

           /// <summary>
           /// Desc:开单时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime start_time {get;set;}

           /// <summary>
           /// Desc:支付时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? pay_time {get;set;}

           /// <summary>
           /// Desc:结单时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? close_time {get;set;}

           /// <summary>
           /// Desc:订单备注（如"少盐"）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? remark {get;set;}

           /// <summary>
           /// Desc:是否分单（1-是；0-否）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte is_split {get;set;}

           /// <summary>
           /// Desc:操作员工ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long operator_id {get;set;}

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
        /// Desc:用餐人数
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>      
        public int? table_capacity {get;set;}

        /// <summary>
        /// Desc:预订id
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>   
        public int? reservation_id {get;set;}

        /// <summary>
        /// Desc:支付方式
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>   
        public string paymeth {get;set;}
        /// <summary>
        ///是否备份
        /// </summary>
        public int is_backup {get;set;}


        [Navigate(NavigateType.OneToOne, nameof(reservation_id), nameof(sys_reservation.reservation_id))]//一对一 
        public sys_reservation? reservation { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(store_id), nameof(sys_store.store_id))]//一对一 
        public sys_store? store { get; set; }


        [Navigate(NavigateType.OneToOne, nameof(table_id), nameof(sys_restaurant_table.table_id))]//一对一 
        public sys_restaurant_table? table { get; set; }


        [Navigate(NavigateType.OneToMany, nameof(order_id), nameof(sys_order_item.order_id))]//一对多
        public List<sys_order_item>? orderitem { get; set; }

        [SugarColumn(IsIgnore = true)]
        public string TableNo { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(operator_id), nameof(sys_staff.staff_id))]//一对一 
        public sys_staff? Staff { get; set; }

    }
}
