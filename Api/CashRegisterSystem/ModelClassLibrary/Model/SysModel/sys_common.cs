using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///
    ///</summary>
    [SugarTable("sys_common")]
    public partial class sys_common
    {
           public sys_common(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true)]
           public int id {get;set;}

           /// <summary>
           /// Desc:编码
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string code {get;set;} = null!;

           /// <summary>
           /// Desc:名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string name {get;set;} = null!;

           /// <summary>
           /// Desc:值
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? keymchcode {get;set;}
           public string? keyvalue {get;set;}
           public string? url {get;set;}

    }
}
