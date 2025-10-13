using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///支付记录表
    ///</summary>
    [SugarTable("sys_payment")]
    public partial class sys_payment
    {
           public sys_payment(){


           }
           /// <summary>
           /// Desc:支付ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long payment_id {get;set;}

           /// <summary>
           /// Desc:关联订单ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long order_id {get;set;}

           /// <summary>
           /// Desc:支付流水号（唯一）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string payment_no {get;set;} = null!;

           /// <summary>
           /// Desc:会员ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? member_id {get;set;}

           /// <summary>
           /// Desc:支付金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal pay_amount {get;set;}

           /// <summary>
           /// Desc:支付方式（1-微信；2-支付宝；3-现金；4-储值卡；5-优惠券）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte pay_type {get;set;}

           /// <summary>
           /// Desc:第三方平台（如"美团"，自付时为空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? third_platform {get;set;}

           /// <summary>
           /// Desc:第三方订单号（外卖平台用）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? third_order_no {get;set;}

           /// <summary>
           /// Desc:状态（1-待支付；2-支付成功；3-支付失败;4-退款中；5退款成功；6；退款失败）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:支付/退款时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? pay_time {get;set;}

           /// <summary>
           /// Desc:优惠券ID（可空）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? coupon_id {get;set;}

           /// <summary>
           /// Desc:收款账户ID（公司账户）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_account_id {get;set;}

           /// <summary>
           /// Desc:备注
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? remark {get;set;}
        /// <summary>
        /// 支付/退款返回单号
        /// </summary>
           public string? transaction_id {get;set;}

        /// <summary>
        /// 退款返回信息
        /// </summary>
           public string? response_data {get;set;}
        /// <summary>
        /// 退款失败原因
        /// </summary>
           public string? fail_reason {get;set;}

    }
}
