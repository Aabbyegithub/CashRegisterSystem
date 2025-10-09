using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///门店信息表
    ///</summary>
    [SugarTable("sys_store")]
    public partial class sys_store
    {
        public sys_store()
        {


        }
        /// <summary>
        /// Desc:门店ID（主键）
        /// Default:
        /// Nullable:False
        /// </summary>           
        [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long? store_id {get;set;}

           /// <summary>
           /// Desc:门店名称
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string store_name {get;set;} = null!;

           /// <summary>
           /// Desc:门店地址
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string address {get;set;} = null!;

           /// <summary>
           /// Desc:联系电话
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string phone {get;set;} = null!;

           /// <summary>
           /// Desc:营业时间（如"10:00-22:00"）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string business_hours {get;set;} = null!;

           /// <summary>
           /// Desc:总桌台数
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int total_tables {get;set;}

           /// <summary>
           /// Desc:状态（1-营业中；0-停业）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

        /// <summary>
        /// Desc:创建时间
        /// Default:CURRENT_TIMESTAMP
        /// Nullable:False
        /// </summary>           
        public DateTime created_at { get; set; } = DateTime.Now;

           /// <summary>
           /// Desc:更新时间
           /// Default:CURRENT_TIMESTAMP
           /// Nullable:False
           /// </summary>           
           public DateTime updated_at {get;set;} = DateTime.Now;

        /// <summary>
        /// 门店编码
        /// </summary>

        public string? store_code { get;set;}

    }
}
