using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///会员表
    ///</summary>
    [SugarTable("sys_member")]
    public partial class sys_member
    {
           public sys_member(){


           }
           /// <summary>
           /// Desc:会员ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long member_id {get;set;}

           /// <summary>
           /// Desc:会员编号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string? member_no {get;set;}

           /// <summary>
           /// Desc:手机号（登录账号）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string phone {get;set;} = null!;

           /// <summary>
           /// Desc:姓名
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? name {get;set;}

           /// <summary>
           /// Desc:生日
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? birthday {get;set;}

           /// <summary>
           /// Desc:注册时间
           /// Default:CURRENT_TIMESTAMP
           /// Nullable:False
           /// </summary>           
           public DateTime register_time {get;set;}

           /// <summary>
           /// Desc:状态（1-正常；0-冻结）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}

           /// <summary>
           /// Desc:总积分
           /// Default:0
           /// Nullable:False
           /// </summary>           
           public int total_points {get;set;}

           /// <summary>
           /// Desc:推荐人会员ID（老带新用）
           /// Default:
           /// Nullable:True
           /// </summary>           
           public long? referrer_id {get;set;}

        /// <summary>
        /// Desc:账户余额
        /// Default:
        /// Nullable:True
        /// </summary>           
        public decimal? balance { get; set; } = 0;

    }
}
