using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///菜品规格表
    ///</summary>
    [SugarTable("sys_dish_spec")]
    public partial class sys_dish_spec
    {
           public sys_dish_spec(){


           }
           /// <summary>
           /// Desc:规格ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long spec_id {get;set;}

           /// <summary>
           /// Desc:所属菜品ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long dish_id {get;set;}

           /// <summary>
           /// Desc:规格名称（如"大份/中份/小份"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string spec_name {get;set;} = null!;

           /// <summary>
           /// Desc:规格类型（分量/辣度/做法）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string spec_type {get;set;} = null!;

           /// <summary>
           /// Desc:价格
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal price_diff {get;set;}

           /// <summary>
           /// Desc:排序序号
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int sort_order {get;set;}

        [Navigate(NavigateType.OneToOne, nameof(dish_id), nameof(sys_dish.dish_id))]//一对一 
        public sys_dish? dish { get; set; }

    }
}
