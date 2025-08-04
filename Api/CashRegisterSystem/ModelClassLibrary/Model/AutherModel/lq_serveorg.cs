using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///服务类
    ///</summary>
    [SugarTable("lq_serveorg")]
    public partial class lq_serveorg
    {
           public lq_serveorg(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long Id {get;set;}

           /// <summary>
           /// Desc:服务名称
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? ServeName {get;set;}

           /// <summary>
           /// Desc:创建时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime AddTime {get;set;}

           /// <summary>
           /// Desc:创建人
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long AddUserId {get;set;}

           /// <summary>
           /// Desc:更新人
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int UpUserId {get;set;}

           /// <summary>
           /// Desc:更新时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime UpTime {get;set;}

    }
}
