using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///排队叫号表
    ///</summary>
    [SugarTable("sys_queue")]
    public partial class sys_queue
    {
           public sys_queue(){


           }
           /// <summary>
           /// Desc:排队ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long queue_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:顾客姓名
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string? customer_name {get;set;}

           /// <summary>
           /// Desc:顾客电话
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string? customer_phone {get;set;} 

           /// <summary>
           /// Desc:用餐人数
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public int party_size {get;set;}

           /// <summary>
           /// Desc:排队号（如"A001"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string? queue_no {get;set;}

           /// <summary>
           /// Desc:取号时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime queue_time {get;set;}

           /// <summary>
           /// Desc:状态（1-等待中；2-已叫号；3-过号；4-已入座）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:过号提醒状态（0-未提醒；1-已提醒）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte overtime_remind {get;set;}

           /// <summary>
           /// Desc:入座桌台ID（关联后更新）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? table_id {get;set;}

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
           public string? remark { get;set;}

    }
}
