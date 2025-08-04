using System;
using System.Linq;
using System.Text;
using ModelClassLibrary.Model;
using SqlSugar;

namespace MyNamespace
{
    ///<summary>
    ///系统消息通知
    ///</summary>
    [SugarTable("lq_sys_msg")]
    public partial class lq_sys_msg:CommonModelFixts
    {
           public lq_sys_msg(){


           }
           /// <summary>
           /// Desc:
           /// Default:
           /// Nullable:False
           /// </summary>           
        [SugarColumn(IsPrimaryKey = true, IsIdentity = true)]
           public long Id {get;set;}

           /// <summary>
           /// Desc:通知消息
           /// Default:
           /// Nullable:False
           /// </summary>           
           public string Msg {get;set;} = null!;
        /// <summary>
        /// Desc:主题
        /// Default:
        /// Nullable:False
        /// </summary>      
        public string Subject {get;set;} = null!;

           /// <summary>
           /// Desc:是否已通知
           /// Default:b'0'
           /// Nullable:False
           /// </summary>           
           public bool IsRead {get;set;}

    }
}
