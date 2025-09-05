using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///促销活动表
    ///</summary>
    [SugarTable("sys_promotion")]
    public partial class sys_promotion
    {
           public sys_promotion(){


           }
           /// <summary>
           /// Desc:活动ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long promotion_id {get;set;}

           /// <summary>
           /// Desc:门店ID（0-全门店）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:活动名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string promotion_name {get;set;} = null!;

           /// <summary>
           /// Desc:类型（1-时段优惠；2-节日套餐；3-满减；4-老带新）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte type {get;set;}

           /// <summary>
           /// Desc:开始时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime start_time {get;set;}

           /// <summary>
           /// Desc:结束时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime end_time {get;set;}

           /// <summary>
           /// Desc:活动规则（如{"满减":[{"满200":"减30"},...]}）
           /// Default:
           /// Nullable:False
           /// </summary>
           [SugarColumn(IsJson=true)]           
           public object rule {get;set;}

           /// <summary>
           /// Desc:适用范围（菜品/套餐ID，逗号分隔）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? applicable_scope {get;set;}

           public decimal? min_consumption {get;set;}
           public decimal? value {get;set;}

           /// <summary>
           /// Desc:状态（1-可用；0-未开始 2过期）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

    }
}
