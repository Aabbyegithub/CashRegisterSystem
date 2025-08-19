using System;
using System.Linq;
using System.Text;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///员工表
    ///</summary>
    [SugarTable("sys_staff")]
    public partial class sys_staff
    {
           public sys_staff(){


           }
           /// <summary>
           /// Desc:员工ID（主键）
           /// Default:
           /// Nullable:False
           /// </summary>           
           [SugarColumn(IsPrimaryKey=true,IsIdentity=true)]
           public long staff_id {get;set;}

           /// <summary>
           /// Desc:所属门店ID（0-总部）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public long store_id {get;set;}

           /// <summary>
           /// Desc:登录账号
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string username {get;set;} = null!;

           /// <summary>
           /// Desc:加密密码
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string password {get;set;} = null!;
           public string? Salt { get;set;} = null!;

           /// <summary>
           /// Desc:姓名
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string name {get;set;} = null!;

           /// <summary>
           /// Desc:手机号
           /// Default:
           /// Nullable:True
           /// </summary>           
           public string? phone {get;set;}

           /// <summary>
           /// Desc:职位（服务员/厨师/店长）
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string position {get;set;} = null!;

           /// <summary>
           /// Desc:状态（1-在职；0-离职）
           /// Default:1
           /// Nullable:False
           /// </summary>           
           public byte status {get;set;}
        public byte IsDelete { get; set; } = 0;

           /// <summary>
           /// Desc:最后登录时间
           /// Default:
           /// Nullable:True
           /// </summary>           
           public DateTime? last_login_time {get;set;}


        [Navigate(NavigateType.OneToOne, nameof(staff_id), nameof(sys_staff_role.staff_id))]//一对一 
        public sys_staff_role? staff_role { get; set; }

        [Navigate(NavigateType.OneToOne, nameof(store_id), nameof(sys_store.store_id))]//一对一 
        public sys_store? store { get; set; }

        [SugarColumn(IsIgnore = true)]
        public long RoleId { get; set; }

    }
}
