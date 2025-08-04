using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.MenuModel.MenuDto
{
    public class MenuDto
    {
        public int id {  get; set; }

        /// <summary>
        /// 名称
        /// </summary>
        public string? name {  get; set; }

        /// <summary>
        /// 路由路径
        /// </summary>
        public string? path { get; set; }
        
        /// <summary>
        ///图标 
        /// </summary>
        public string? icon { get; set; }

        /// <summary>
        /// 子菜单
        /// </summary>
        public List<MenuDto> children { get; set;}
    }
}
