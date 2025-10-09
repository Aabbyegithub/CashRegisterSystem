using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///预订信息表
    ///</summary>
    [SugarTable("sys_reservation")]
    public partial class sys_reservation
    {
           public sys_reservation(){


           }
           /// <summary>
           /// Desc:预订ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long reservation_id {get;set;}

           /// <summary>
           /// Desc:门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:预订桌台ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long table_id {get;set;}

           /// <summary>
           /// Desc:预订编号（唯一）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string? reservation_no {get;set;} 

           /// <summary>
           /// Desc:预订人姓名
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string reservation_name {get;set;} = null!;

           /// <summary>
           /// Desc:预订人电话
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string reservation_phone {get;set;} = null!;

           /// <summary>
           /// Desc:预订时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime reservation_time {get;set;}

           /// <summary>
           /// Desc:预订人数
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int reservation_capacity {get;set;}

           /// <summary>
           /// Desc:状态（1-已确认；2-已取消；3-已到店；4-已过期）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:预订备注
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? remark {get;set;}

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

    }
}
