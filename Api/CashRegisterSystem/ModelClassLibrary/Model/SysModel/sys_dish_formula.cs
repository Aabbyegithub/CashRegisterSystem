using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///菜品配方表（原材料消耗规则）
    ///</summary>
    [SugarTable("sys_dish_formula")]
    public partial class sys_dish_formula
    {
           public sys_dish_formula(){


           }
           /// <summary>
           /// Desc:配方ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long formula_id {get;set;}

           /// <summary>
           /// Desc:菜品ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long dish_id {get;set;}

           /// <summary>
           /// Desc:规格ID（可空，不同规格消耗不同）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? spec_id {get;set;}

           /// <summary>
           /// Desc:原材料ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long material_id {get;set;}

           /// <summary>
           /// Desc:消耗数量（如"200g"）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal consumption {get;set;}

           /// <summary>
           /// Desc:损耗率（如0.05=5%）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal loss_rate {get;set;}

        [Navigate(NavigateType.OneToOne, nameof(material_id), nameof(sys_raw_material.material_id))]//一对一 
        public sys_raw_material? dish_material { get; set; }

    }
}
