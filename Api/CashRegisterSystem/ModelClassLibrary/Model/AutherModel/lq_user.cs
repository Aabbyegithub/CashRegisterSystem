using System;
using System.Linq;
using System.Text;
using ModelClassLibrary.Model;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///用户管理
    ///</summary>
    [SugarTable("lq_user")]
    public partial class lq_user : CommonModelFixts
    {
        public lq_user()
        {


        }
        /// <summary>
        /// Desc:
        /// Default:
        /// Nullable:False
        /// </summary>           
        [SugarColumn(IsPrimaryKey = true, IsIdentity = true)]
        public long Id { get; set; }

        /// <summary>
        /// Desc:用户名
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string User { get; set; }

        /// <summary>
        /// Desc:账户名
        /// Default:
        /// Nullable:False
        /// </summary>           
        public string UserName { get; set; } = null!;

        /// <summary>
        /// Desc:密码
        /// Default:
        /// Nullable:False
        /// </summary>           
        public string PassWord { get; set; } = null!;

        /// <summary>
        /// Desc:邮件
        /// Default:
        /// Nullable:True
        /// </summary>           
        public string? Email { get; set; }
        public string? Phone { get; set; }

        /// <summary>
        /// Desc:是否第一次登陆
        /// Default:
        /// Nullable:True
        /// </summary>           
        public bool IsFirst { get; set; }

        /// <summary>
        /// Desc:是否删除 0：删除 1：启用
        /// Default:
        /// Nullable:False
        /// </summary>           
        public int IsDelete { get; set; }

        /// <summary>
        /// Desc:验证盐值
        /// Default:
        /// Nullable:False
        /// </summary>           
        public string Salt { get; set; } = null!;

        /// <summary>
        /// Desc:角色id
        /// Default:
        /// Nullable:False
        /// </summary>    
        public int? RoleId { get; set; }

    }
}
