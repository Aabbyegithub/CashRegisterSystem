using System;
using System.Linq;
using System.Text;
using ModelClassLibrary.Model;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///人员菜单权限
    ///</summary>
    [SugarTable("lq_sysuser_menu")]
    public partial class lq_sysuser_menu:CommonModelFixts
    {
           public lq_sysuser_menu(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long id {get;set;}

           /// <summary>
           /// Desc:角色id
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int Roleid {get;set;}

           /// <summary>
           /// Desc:菜单id
           /// Default:
           /// Nullable:False
           /// </summary>           
           public int menuid {get;set;}

    }
}
