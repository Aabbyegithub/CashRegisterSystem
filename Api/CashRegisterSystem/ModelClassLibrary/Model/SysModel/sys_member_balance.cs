using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///会员储值记录表
    ///</summary>
    [SugarTable("sys_member_balance")]
    public partial class sys_member_balance
    {
           public sys_member_balance(){


           }
           /// <summary>
           /// Desc:记录ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long balance_id {get;set;}

           /// <summary>
           /// Desc:会员ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long member_id {get;set;}

           /// <summary>
           /// Desc:当前余额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal balance {get;set;}

           /// <summary>
           /// Desc:充值金额
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal recharge_amount {get;set;}

           /// <summary>
           /// Desc:赠送金额（如充500送100）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal give_amount {get;set;}

           /// <summary>
           /// Desc:充值时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime recharge_time {get;set;}

           /// <summary>
           /// Desc:关联支付记录ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long payment_id {get;set;}

           /// <summary>
           /// Desc:操作员工ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long operator_id {get;set;}

    }
}
