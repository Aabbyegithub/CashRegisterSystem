using System;
using System.Linq;
using System.Text;
using ModelClassLibrary.Model;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///菜单管理
    ///</summary>
    [SugarTable("lq_sys_menu")]
    public partial class lq_sys_menu:CommonModelFixts
    {
           public lq_sys_menu(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long id {get;set;}

           /// <summary>
           /// Desc:菜单名称
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? menu_name {get;set;}

           /// <summary>
           /// Desc:菜单编码
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? menu_code {get;set;}

           /// <summary>
           /// Desc:菜单路径
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? menu_path {get;set;}

           /// <summary>
           /// Desc:上级菜单
           /// Default:
           /// Nullable:True
           /// </summary>           
           public int? menu_up {get;set;}

           /// <summary>
           /// Desc:菜单级数
           /// Default:
           /// Nullable:True
           /// </summary>           
           public int? grade {get;set;}

           /// <summary>
           /// Desc:菜单等级
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int sort {get;set;}

           /// <summary>
           /// Desc:图标
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? icon {get;set;}

    }
}
