using System;
using System.Linq;
using System.Text;
using ModelClassLibrary.Model;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///人员角色表
    ///</summary>
    [SugarTable("lq_sys_role")]
    public partial class lq_sys_role:CommonModelFixts
    {
           public lq_sys_role(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long Id {get;set;}

           /// <summary>
           /// Desc:角色编码
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string RoleCode {get;set;} = null!;

           /// <summary>
           /// Desc:角色名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string RoleName {get;set;} = null!;

           /// <summary>
           /// Desc:角色描述
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? RoleDepicted {get;set;}

            /// <summary>
            /// Desc:是否删除 0：删除 1：启用
            /// Default:
            /// Nullable:False
            /// </summary>           
            public int IsDelete { get; set; }

    }
}
