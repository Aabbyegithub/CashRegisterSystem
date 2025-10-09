using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///供应商表
    ///</summary>
    [SugarTable("sys_supplier")]
    public partial class sys_supplier
    {
           public sys_supplier(){


           }
           /// <summary>
           /// Desc:供应商ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long supplier_id {get;set;}

           /// <summary>
           /// Desc:供应商名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string supplier_name {get;set;} = null!;

           /// <summary>
           /// Desc:联系人
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string contact_person {get;set;} = null!;

           /// <summary>
           /// Desc:联系电话
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string contact_phone {get;set;} = null!;

           /// <summary>
           /// Desc:地址
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? address {get;set;}

           /// <summary>
           /// Desc:状态（1-合作中；0-已停用）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

    }
}
