using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///菜品分类表
    ///</summary>
    [SugarTable("sys_dish_category")]
    public partial class sys_dish_category
    {
           public sys_dish_category(){


           }
           /// <summary>
           /// Desc:分类ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long category_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID（支持单店特色分类）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long? store_id {get;set;}

           /// <summary>
           /// Desc:分类名称（热菜/凉菜/主食）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string category_name {get;set;} = null!;

           /// <summary>
           /// Desc:排序序号（小在前）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int sort_order {get;set;}

           /// <summary>
           /// Desc:状态（1-启用；0-禁用）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

    }
}
