using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///厨房管理表
    ///</summary>
    [SugarTable("sys_kitchen")]
    public partial class sys_kitchen
    {
           public sys_kitchen(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true)]
           public int id {get;set;}

           /// <summary>
           /// Desc:厨房名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string kitchen_name {get;set;} = null!;

           /// <summary>
           /// Desc:厨房类型
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string kitchen_type {get;set;} = null!;

           /// <summary>
           /// Desc:描述
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? kitchen_description {get;set;}

           /// <summary>
           /// Desc:所属门店
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

    }
}
