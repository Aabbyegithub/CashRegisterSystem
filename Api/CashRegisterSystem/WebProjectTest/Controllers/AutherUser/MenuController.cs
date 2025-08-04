using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ModelClassLibrary.Model.MenuModel.MenuDto;
using MyNamespace;
using WebIServices.IBase;
using WebProjectTest.Common;
using static WebProjectTest.Common.Message;

namespace WebProjectTest.Controllers.AutherUser
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    [Authorize]
    public class MenuController(IRedisCacheService redisCacheService, ISqlHelper dal) : AutherController(redisCacheService)
    {

        /// <summary>
        /// 根据人员获取菜单
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<MenuDto>>> GetMenuListAsync()
        {
            if (RoleId == null)
            {
                return Fail<List<MenuDto>>("人员未分配角色！");
            }
            var menu = await dal.Db.Queryable<lq_sys_menu>()
                .RightJoin<lq_sysuser_menu>((a,b)=>a.id == b.menuid)
                .Where((a,b) =>b.OrgId == OrgId && b.Roleid == RoleId)
                .ToListAsync();
            return Success(RecursionMenu(menu));
        }
        /// <summary>
        /// 获取所有菜单分配人员权限
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public async Task<ApiResponse<List<MenuDto>>> GetMenuAllAsync()
        {
            var menu = await dal.Db.Queryable<lq_sys_menu>()
                .Where(a => a.OrgId == OrgId)
                .ToListAsync();
            return Success(RecursionMenu(menu));
        }
        [HttpPost]
        public async Task<ApiResponse<string>>SaveUserMenuAsync()
        {
            try
            {
                return Success("保存成功！");
            }
            catch (Exception)
            {

                return Fail<string>("保存失败！");
            }
        } 
        /// <summary>
        /// 递归生成菜单
        /// </summary>
        /// <returns></returns>
        private List<MenuDto> RecursionMenu(List<lq_sys_menu> sys_Menus, int grade = 1)
        {
            var MenuList = sys_Menus.Where(a => a.grade == grade).ToList();
            if (MenuList.Count == 0)
            {
                return sys_Menus.OrderBy(a => a.sort)
                .Select(a => new MenuDto()
                {
                    id = (int)a.id,
                    name = a.menu_name,
                    path = a.menu_path==""? a.menu_name :a.menu_path,
                    icon = a.icon,
                    children = []
                }).ToList();
            }
          var Menu = MenuList.OrderBy(a => a.sort)
                .Select(a => new MenuDto()
                {
                    id = (int)a.id,
                    name = a.menu_name,
                    path = a.menu_path==""? a.menu_name :a.menu_path,
                    icon = a.icon,
                    children = []
                }).ToList();
            foreach (var item in Menu)
            {
                var MenuChildren = sys_Menus.Where(a => a.menu_up == item.id).ToList();
                item.children = RecursionMenu(MenuChildren, grade++);
            }
            return Menu;
        }
    }
}
