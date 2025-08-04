using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///原材料表
    ///</summary>
    [SugarTable("sys_raw_material")]
    public partial class sys_raw_material
    {
           public sys_raw_material(){


           }
           /// <summary>
           /// Desc:原材料ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long material_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID（0-通用）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:原材料名称（如"鸡肉"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string material_name {get;set;} = null!;

           /// <summary>
           /// Desc:分类（生鲜/调料/粮油）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string category {get;set;} = null!;

           /// <summary>
           /// Desc:单位（kg/个/升）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string unit {get;set;} = null!;

           /// <summary>
           /// Desc:采购单价
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal purchase_price {get;set;}

           /// <summary>
           /// Desc:低库存预警阈值
           /// Default:0.00
           /// Nullable:False
           /// </summary>           
           public decimal warning_threshold {get;set;}

           /// <summary>
           /// Desc:状态（1-启用；0-禁用）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

    }
}
