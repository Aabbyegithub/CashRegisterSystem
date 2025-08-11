<template>
  <div class="backend-container">
    <!-- 左侧菜单区域 - 支持折叠 -->
    <aside class="backend-sidebar">
      <div class="sidebar-menu">
        <div
          v-for="group in menuGroups"
          :key="group.groupKey"
          class="menu-group"
        >
          <div
            class="group-header"
            @click="toggleGroup(group.groupKey)"
          >
            <img :src="group.icon" :alt="group.groupTitle" class="group-icon" />
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">{{ group.groupTitle }}</h3>
            <img
              src="/src/assets/下拉菜单.png"
              alt="展开/折叠"
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed[group.groupKey], 'hidden-arrow': isCollapsed }"
            />
          </div>
          <ul
            class="menu-list"
            :class="{ 'collapsed-group': groupCollapsed[group.groupKey] }"
          >
            <li
              v-for="item in group.children"
              :key="item.key"
              class="menu-item"
              :class="{ active: $route.name === item.name }"
              @click="handleMenuClick(item.key)"
            >
              <img :src="item.icon" :alt="item.title" class="menu-icon" />
              <span :class="{ 'hidden-text': isCollapsed }">{{ item.title }}</span>
            </li>
          </ul>
        </div>
      </div>
    </aside>

    <!-- 右侧内容区域（路由视图） -->
    <main class="backend-content" :class="{ 'expanded': isCollapsed }">
      <div class="content-header">
        <h2 class="page-title">
          {{ getPageTitle() }}
        </h2>
      </div>
      <div class="content-body">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { getMenuList } from '../../../api/login';

// 模拟接口获取菜单数据
async function fetchMenuData() {
  // 这里模拟接口返回的数据结构，和你原本的菜单结构一致
  return await getMenuList().then((res:any)=>{
    console.log(res.response)
    return res.response
  })
  // return Promise.resolve([
  //   {
  //     groupKey: 'dashboard',
  //     groupTitle: '数据概览',
  //     icon: '/src/assets/数据概览.png',
  //     children: [
  //       {
  //         key: 'dashboard-index',
  //         name: 'DashboardIndex',
  //         title: '核心指标看板',
  //         icon: '/src/assets/首页.png'
  //       }
  //     ]
  //   },
  //   {
  //     groupKey: 'tableManagement',
  //     groupTitle: '桌台管理',
  //     icon: '/src/assets/桌台.png',
  //     children: [
  //       { key: 'table-list', name: 'TableList', title: '桌台列表', icon: '/src/assets/桌台.png' },
  //       { key: 'table-layout', name: 'TableLayout', title: '桌台布局可视化', icon: '/src/assets/桌台布局.png' },
  //       { key: 'transfer-table', name: 'TransferTable', title: '转桌/并桌操作', icon: '/src/assets/桌台.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'queueManagement',
  //     groupTitle: '排队叫号',
  //     icon: '/src/assets/排队叫号.png',
  //     children: [
  //       { key: 'queue-list', name: 'QueueList', title: '排队列表', icon: '/src/assets/排队列表.png' },
  //       { key: 'queue-setting', name: 'QueueSetting', title: '排队规则设置', icon: '/src/assets/排队设置.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'dishManagement',
  //     groupTitle: '菜品管理',
  //     icon: '/src/assets/菜品管理.png',
  //     children: [
  //       { key: 'dish-list', name: 'DishList', title: '菜品列表', icon: '/src/assets/菜品列表.png' },
  //       { key: 'dish-category', name: 'DishCategory', title: '菜品分类', icon: '/src/assets/菜品分类.png' },
  //       { key: 'dish-spec', name: 'DishSpec', title: '菜品规格配置', icon: '/src/assets/菜品规格.png' },
  //       { key: 'set-meal', name: 'SetMeal', title: '套餐管理', icon: '/src/assets/套餐管理.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'orderManagement',
  //     groupTitle: '订单管理',
  //     icon: '/src/assets/订单管理.png',
  //     children: [
  //       { key: 'order-list', name: 'OrderList', title: '订单列表', icon: '/src/assets/订单列表.png' },
  //       { key: 'create-order', name: 'CreateOrder', title: '新建订单', icon: '/src/assets/新建订单.png' },
  //       { key: 'order-detail', name: 'OrderDetail', title: '订单详情', icon: '/src/assets/订单详情.png' },
  //       { key: 'split-bill', name: 'SplitBill', title: '账单分拆', icon: '/src/assets/账单分拆.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'kitchenManagement',
  //     groupTitle: '厨房管理',
  //     icon: '/src/assets/厨房管理.png',
  //     children: [
  //       { key: 'kitchen-board', name: 'KitchenBoard', title: '厨房看板', icon: '/src/assets/厨房看板.png' },
  //       { key: 'out-meal-record', name: 'OutMealRecord', title: '出餐记录表', icon: '/src/assets/出餐记录.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'inventoryManagement',
  //     groupTitle: '库存管理',
  //     icon: '/src/assets/库存管理.png',
  //     children: [
  //       { key: 'material-list', name: 'MaterialList', title: '原材料列表', icon: '/src/assets/原材料列表.png' },
  //       { key: 'loss-record', name: 'LossRecord', title: '损耗记录', icon: '/src/assets/损耗记录.png' },
  //       { key: 'purchase-order', name: 'PurchaseOrder', title: '采购单管理', icon: '/src/assets/采购单.png' },
  //       { key: 'stock-warning', name: 'StockWarning', title: '库存预警', icon: '/src/assets/库存预警.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'memberManagement',
  //     groupTitle: '会员管理',
  //     icon: '/src/assets/会员管理.png',
  //     children: [
  //       { key: 'member-list', name: 'MemberList', title: '会员列表', icon: '/src/assets/会员列表.png' },
  //       { key: 'recharge-record', name: 'RechargeRecord', title: '储值记录', icon: '/src/assets/储值记录.png' },
  //       { key: 'member-rights', name: 'MemberRights', title: '会员权益配置', icon: '/src/assets/会员权益.png' },
  //       { key: 'points-mall', name: 'PointsMall', title: '积分商城', icon: '/src/assets/积分商城.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'promotionManagement',
  //     groupTitle: '促销管理',
  //     icon: '/src/assets/促销管理.png',
  //     children: [
  //       { key: 'promotion-list', name: 'PromotionList', title: '促销活动列表', icon: '/src/assets/促销列表.png' },
  //       { key: 'create-promotion', name: 'CreatePromotion', title: '创建促销活动', icon: '/src/assets/创建促销.png' },
  //       { key: 'coupon-management', name: 'CouponManagement', title: '优惠券管理', icon: '/src/assets/优惠卷管理.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'paymentManagement',
  //     groupTitle: '支付管理',
  //     icon: '/src/assets/支付管理.png',
  //     children: [
  //       { key: 'payment-record', name: 'PaymentRecord', title: '支付记录', icon: '/src/assets/支付记录.png' },
  //       { key: 'invoice-management', name: 'InvoiceManagement', title: '发票管理', icon: '/src/assets/发票管理.png' },
  //       { key: 'account-setting', name: 'AccountSetting', title: '收款账户设置', icon: '/src/assets/账户设置.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'statisticsAnalysis',
  //     groupTitle: '数据分析',
  //     icon: '/src/assets/数据分析.png',
  //     children: [
  //       { key: 'sales-analysis', name: 'SalesAnalysis', title: '销售分析', icon: '/src/assets/销售分析.png' },
  //       { key: 'cost-analysis', name: 'CostAnalysis', title: '成本分析', icon: '/src/assets/成本分析.png' },
  //       { key: 'customer-analysis', name: 'CustomerAnalysis', title: '客流分析', icon: '/src/assets/客流分析.png' },
  //       { key: 'store-comparison', name: 'StoreComparison', title: '门店对比', icon: '/src/assets/门店对比.png' }
  //     ]
  //   },
  //   {
  //     groupKey: 'systemSetting',
  //     groupTitle: '系统设置',
  //     icon: '/src/assets/系统设置.png',
  //     children: [
  //       { key: 'staff-management', name: 'StaffManagement', title: '员工管理', icon: '/src/assets/员工管理.png' },
  //       { key: 'role-permission', name: 'RolePermission', title: '角色权限', icon: '/src/assets/角色权限.png' },
  //       { key: 'store-setting', name: 'StoreSetting', title: '门店设置', icon: '/src/assets/门店设置.png' },
  //       { key: 'data-backup', name: 'DataBackup', title: '数据备份', icon: '/src/assets/数据备份.png' }
  //     ]
  //   }
  // ]);
}

const router = useRouter();
const route = useRoute();

const isCollapsed = ref(false);
const groupCollapsed = ref<Record<string, boolean>>({});
const menuGroups = ref<any[]>([]);

const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

const toggleGroup = (group: string) => {
  if (!isCollapsed.value) {
    groupCollapsed.value[group] = !groupCollapsed.value[group];
  }
};

const handleMenuClick = (key: string) => {
  // 查找菜单项的name
  let menuName = '';
  for (const group of menuGroups.value) {
    const item = group.children.find((c: any) => c.key === key);
    if (item) {
      menuName = item.name;
      break;
    }
  }
  if (menuName) {
    router.push({ path: `/Layout/Backendhome/${menuName}` });
  }
};

const getPageTitle = () => {
  const currentRouteName = route.name as string;
  for (const group of menuGroups.value) {
    const item = group.children.find((c: any) => c.name === currentRouteName);
    if (item) return item.title;
  }
  return '后台管理';
};

onMounted(async () => {
  // 获取菜单数据
  const data = await fetchMenuData();
  menuGroups.value = data;
  // 初始化折叠状态
  data.forEach((g: any) => {
    groupCollapsed.value[g.groupKey] = true;
  });
  // 默认跳转首页
  if (route.path === '/Layout/Backendhome') {
    router.push({ path: `/Layout/Backendhome/DashboardIndex` });
  }
});
</script>

<style scoped>
/* 保持原有样式不变，样式会自动适配新增菜单 */
.backend-container {
 display: flex;
 height: 100%;
 width: 100%;
 transition: all 0.3s ease;
}

.backend-sidebar {
 width: 220px;
 background-color: #2C3E50;
 color: #ECF0F1;
 height: 100%;
 box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
 /* 关键修改：隐藏滚动条但保留滚动功能 */
 overflow-y: auto;
 scrollbar-width: none; /* Firefox 隐藏滚动条 */
 -ms-overflow-style: none; /* IE 和 Edge 隐藏滚动条 */
 transition: width 0.3s ease;
 position: relative;
 display: flex;
 flex-direction: column;
 align-items: center;
}

/* Chrome, Safari 和 Opera 隐藏滚动条 */
.backend-sidebar::-webkit-scrollbar {
 display: none;
}

.backend-sidebar.collapsed {
 width: 60px;
}

.collapse-btn {
  position: absolute;
  top: 10px;
  right: -10px;
  width: 30px;
  height: 30px;
  background-color: #2C3E50;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
  z-index: 10;
}

.collapse-icon {
  width: 30px;
  height: 30px;
  filter: invert(1);
  transition: transform 0.3s ease;
}

.collapse-icon.rotated {
  transform: rotate(180deg);
}

.sidebar-menu {
  padding-top: 40px;
  width: 100%;
}

.menu-group {
  margin-bottom: 10px;
  border-radius: 4px;
  overflow: hidden;
  width: 100%;
}

.group-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 10px;
  cursor: pointer;
  width: 100%;
}

.group-header:hover {
  background-color: #34495E;
}

.group-icon {
  width: 20px;
  height: 20px;
  margin-right: 10px;
  filter: invert(1);
}

.group-title {
  font-size: 14px;
  color: #BDC3C7;
  padding: 10px 0;
  margin: 0;
  transition: opacity 0.3s ease;
  flex: 1;
}

.group-arrow {
  width: 20px;
  height: 20px;
  filter: invert(0.7);
  transition: transform 0.3s ease;
  margin-left: 5px;
}

.group-arrow.rotated {
  transform: rotate(90deg);
}

.group-arrow.hidden-arrow {
  display: none;
}

.menu-list {
  list-style: none;
  padding: 5px 0;
  margin: 0;
  transition: max-height 0.3s ease, padding 0.3s ease;
  max-height: 500px;
  width: 100%;
}

.menu-list.collapsed-group {
  max-height: 0;
  padding: 0;
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  cursor: pointer;
  transition: background-color 0.2s;
  border-radius: 4px;
  margin: 0 5px 4px;
  width: 100%;
}

.menu-item:hover {
  background-color: #34495E;
}

.menu-item.active {
  background-color: #1D99AD;
  border-left: 3px solid #fff;
}

.menu-icon {
  width: 20px;
  height: 20px;
  margin-right: 10px;
  filter: invert(1);
}

.hidden-text {
  opacity: 0;
  width: 0;
  overflow: hidden;
  transition: all 0.3s ease;
}

.backend-content {
  flex: 1;
  padding: 10px;
  overflow-y: auto;
  background-color: #fff;
  transition: margin-left 0.3s ease;
}

.backend-content.expanded {
  margin-left: 0;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

.page-title {
  font-size: 18px;
  color: #333;
  margin: 0;
}

.content-body {
  min-height: calc(100% - 60px);
}

@media (max-width: 768px) {
  .backend-sidebar {
    width: 60px;
  }
  
  .backend-sidebar:not(.collapsed) {
    width: 220px;
  }
  
  .group-title, .menu-item span, .group-arrow {
    opacity: 0;
    width: 0;
    display: none;
  }
  
  .backend-sidebar:not(.collapsed) .group-title,
  .backend-sidebar:not(.collapsed) .menu-item span,
  .backend-sidebar:not(.collapsed) .group-arrow {
    opacity: 1;
    width: auto;
    display: block;
  }
}
</style>