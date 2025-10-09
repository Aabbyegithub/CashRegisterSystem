using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///优惠券表
    ///</summary>
    [SugarTable("sys_coupon")]
    public partial class sys_coupon
    {
           public sys_coupon(){


           }
           /// <summary>
           /// Desc:优惠券ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long coupon_id {get;set;}

           /// <summary>
           /// Desc:适用门店ID（0-全门店）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:优惠券编号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string coupon_no {get;set;} = null!;

           /// <summary>
           /// Desc:优惠券名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string coupon_name {get;set;} = null!;

           /// <summary>
           /// Desc:类型（1-满减券；2-折扣券；3-单品券）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte type {get;set;}

        /// <summary>
        /// Desc:面值（满减金额/折扣率）
        /// Default:0.00
        /// Nullable:False
        /// </summary>           
        public decimal value { get; set; } = 0;

           /// <summary>
           /// Desc:最低消费（满减券用）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal min_consumption {get;set;}

           /// <summary>
           /// Desc:生效时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime valid_start {get;set;}

           /// <summary>
           /// Desc:失效时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime valid_end {get;set;}

           /// <summary>
           /// Desc:状态（1-可用；0-未开始 2过期）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:适用菜品ID（逗号分隔，空为全菜品）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? applicable_dishes {get;set;}

        public int? total{get;set;}
        public int received { get; set; } = 0;
        public int used { get; set; } = 0;

    }
}
