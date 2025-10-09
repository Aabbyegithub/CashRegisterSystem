using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///套餐信息表
    ///</summary>
    [SugarTable("sys_set_meal")]
    public partial class sys_set_meal
    {
           public sys_set_meal(){


           }
           /// <summary>
           /// Desc:套餐ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long meal_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:套餐名称（如"双人套餐"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string meal_name {get;set;} = null!;

           /// <summary>
           /// Desc:套餐售价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal price {get;set;}

           /// <summary>
           /// Desc:原价（单品总价）
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal original_price {get;set;}

           /// <summary>
           /// Desc:套餐描述
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? description {get;set;}

           /// <summary>
           /// Desc:是否固定套餐（1-固定；0-自定义组合）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte is_fixed {get;set;}

           /// <summary>
           /// Desc:状态（1-在售；0-下架）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:生效时间（用于节日套餐）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime start_time {get;set;}

           /// <summary>
           /// Desc:失效时间
           /// Default:
           /// Nullable:False
           /// </summary>           
           public DateTime end_time {get;set;}
           public string? image_url { get;set;}


        [SugarColumn(IsIgnore = true)]
        public List<sys_set_meal_item> meal_item { get; set; }

        [Navigate(NavigateType.OneToMany, nameof(meal_id), nameof(sys_set_meal_item.meal_id))]//一对一 
        public List<sys_set_meal_item>? item { get; set; }

    }
}
