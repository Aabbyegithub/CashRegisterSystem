using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///菜品信息表
    ///</summary>
    [SugarTable("sys_dish")]
    public partial class sys_dish
    {
           public sys_dish(){


           }
           /// <summary>
           /// Desc:菜品ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long dish_id {get;set;}

           /// <summary>
           /// Desc:所属分类ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long category_id {get;set;}

           /// <summary>
           /// Desc:菜品名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string dish_name {get;set;} = null!;

           /// <summary>
           /// Desc:售价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal price {get;set;}

           /// <summary>
           /// Desc:会员价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal member_price {get;set;}

           /// <summary>
           /// Desc:是否推荐（1-是；0-否）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte is_recommend {get;set;}

           /// <summary>
           /// Desc:是否临时菜品（1-是；0-否）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public byte is_temporary {get;set;}

           /// <summary>
           /// Desc:菜品描述（用料/做法）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? description {get;set;}

           /// <summary>
           /// Desc:菜品图片URL
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? image_url {get;set;}

           /// <summary>
           /// Desc:状态（1-在售；0-下架）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:预估制作时间（分钟）
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int cooking_time {get;set;}

        /// <summary>
        /// Desc:
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>           
        public DateTime created_at { get; set; } = DateTime.Now;

        /// <summary>
        /// Desc:
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>           
        public DateTime updated_at { get; set; } = DateTime.Now;

        /// <summary>
        /// Desc:所属门店ID（支持单店特色菜）
        /// Default:
        /// Nullable:False
        /// </summary>           
        public long? store_id { get; set; }

        /// <summary>
        /// Desc:制作厨房
        /// Default:
        /// Nullable:False
        /// </summary>           
        public int kitchen_id { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(category_id), nameof(sys_dish_category.category_id))]//一对一 
        public sys_dish_category? dish_category { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(kitchen_id), nameof(sys_kitchen.id))]//一对一 
        public sys_kitchen? dish_kitchen { get; set; }


        [Navigate(NavigateType.OneToMany, nameof(dish_id), nameof(sys_dish_spec.dish_id))]//一对一 
        public List<sys_dish_spec>? dish_spec { get; set; }

        [Navigate(NavigateType.OneToMany, nameof(dish_id), nameof(sys_dish_formula.dish_id))]//一对一 
        public List<sys_dish_formula>? dish_formula { get; set; }

    }
}
