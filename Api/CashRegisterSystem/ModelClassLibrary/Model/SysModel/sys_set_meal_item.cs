using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///套餐包含菜品表
    ///</summary>
    [SugarTable("sys_set_meal_item")]
    public partial class sys_set_meal_item
    {
        public sys_set_meal_item()
        {


        }
        /// <summary>
        /// Desc:记录ID（主键）
        /// Default:
        /// Nullable:False
        /// </summary>           
        [SugarColumn(IsPrimaryKey = true, IsIdentity = true)]
        public long? item_id { get; set; }

        /// <summary>
        /// Desc:所属套餐ID
        /// Default:
        /// Nullable:False
        /// </summary>           
        public long? meal_id { get; set; }

        /// <summary>
        /// Desc:包含菜品ID
        /// Default:
        /// Nullable:False
        /// </summary>           
        public long dish_id { get; set; }

        /// <summary>
        /// Desc:菜品规格ID（可空）
        /// Default:
        /// Nullable:True
        /// </summary>           
        public long? spec_id { get; set; }

        /// <summary>
        /// Desc:数量
        /// Default:1
        /// Nullable:False
        /// </summary>           
        public int quantity { get; set; }

        /// <summary>
        /// Desc:是否可替换（1-是；0-否）
        /// Default:0
        /// Nullable:False
        /// </summary>           
        public byte is_replaceable { get; set; }

        /// <summary>
        /// Desc:可替换菜品ID（逗号分隔）
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string? replaceable_dishes { get; set; }

        /// <summary>
        /// Desc:套餐组合名称
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string? meal_group { get; set; }


        [Navigate(NavigateType.OneToOne, nameof(dish_id), nameof(sys_dish.dish_id))]//一对一 

        public sys_dish? meal_item_dish { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(spec_id), nameof(sys_dish_spec.spec_id))]//一对一 

        public sys_dish_spec? meal_item_dish_spec { get; set; }

    }
}
