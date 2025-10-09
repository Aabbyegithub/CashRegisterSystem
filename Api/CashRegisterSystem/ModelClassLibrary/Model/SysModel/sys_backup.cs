using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///备份记录表
    ///</summary>
    [SugarTable("sys_backup")]
    public partial class sys_backup
    {
           public sys_backup(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
         [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long id {get;set;}

           /// <summary>
           /// Desc:备份名称
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? backup_name {get;set;}

           /// <summary>
           /// Desc:备份时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime backup_time {get;set;}

           /// <summary>
           /// Desc:状态
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int status {get;set;}

           /// <summary>
           /// Desc:备注
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? backup_remark {get;set;}
           public int? backup_sum {get;set;}

    }
}
