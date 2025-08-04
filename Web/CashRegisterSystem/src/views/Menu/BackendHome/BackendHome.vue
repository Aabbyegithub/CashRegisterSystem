<template>
  <div class="backend-container">
    <!-- 左侧菜单区域 - 支持折叠 -->
    <aside class="backend-sidebar">
      <!-- 折叠按钮 -->
      <!-- <div class="collapse-btn" @click="toggleCollapse">
        <img 
          src="/src/assets/折叠菜单.png" 
          alt="折叠/展开菜单" 
          class="collapse-icon"
          :class="{ 'rotated': isCollapsed }"
        >
      </div> -->
      
      <div class="sidebar-menu">
        <!-- 1. 数据概览模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('dashboard')"
          >
            <img 
              src="/src/assets/数据概览.png"
              alt="数据概览" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">数据概览</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.dashboard, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.dashboard }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'DashboardIndex' }"
              @click="handleMenuClick('dashboard-index')"
            >
              <img src="/src/assets/首页.png" alt="首页" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">核心指标看板</span>
            </li>
          </ul>
        </div>

        <!-- 2. 桌台管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('tableManagement')"
          >
            <img 
              src="/src/assets/桌台.png"
              alt="桌台管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">桌台管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.tableManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.tableManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'TableList' }"
              @click="handleMenuClick('table-list')"
            >
              <img src="/src/assets/桌台.png" alt="桌台列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">桌台列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'TableLayout' }"
              @click="handleMenuClick('table-layout')"
            >
              <img src="/src/assets/桌台布局.png" alt="桌台布局" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">桌台布局可视化</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'TransferTable' }"
              @click="handleMenuClick('transfer-table')"
            >
              <img src="/src/assets/桌台.png" alt="转桌并桌" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">转桌/并桌操作</span>
            </li>
          </ul>
        </div>

        <!-- 3. 排队叫号模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('queueManagement')"
          >
            <img 
              src="/src/assets/排队叫号.png"
              alt="排队叫号" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">排队叫号</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.queueManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.queueManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'QueueList' }"
              @click="handleMenuClick('queue-list')"
            >
              <img src="/src/assets/排队列表.png" alt="排队列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">排队列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'QueueSetting' }"
              @click="handleMenuClick('queue-setting')"
            >
              <img src="/src/assets/排队设置.png" alt="排队设置" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">排队规则设置</span>
            </li>
          </ul>
        </div>

        <!-- 4. 菜品管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('dishManagement')"
          >
            <img 
              src="/src/assets/菜品管理.png"
              alt="菜品管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">菜品管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.dishManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.dishManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'DishList' }"
              @click="handleMenuClick('dish-list')"
            >
              <img src="/src/assets/菜品列表.png" alt="菜品列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">菜品列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'DishCategory' }"
              @click="handleMenuClick('dish-category')"
            >
              <img src="/src/assets/菜品分类.png" alt="菜品分类" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">菜品分类</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'DishSpec' }"
              @click="handleMenuClick('dish-spec')"
            >
              <img src="/src/assets/菜品规格.png" alt="菜品规格" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">菜品规格配置</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'SetMeal' }"
              @click="handleMenuClick('set-meal')"
            >
              <img src="/src/assets/套餐管理.png" alt="套餐管理" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">套餐管理</span>
            </li>
          </ul>
        </div>

        <!-- 5. 订单管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('orderManagement')"
          >
            <img 
              src="/src/assets/订单管理.png"
              alt="订单管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">订单管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.orderManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.orderManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'OrderList' }"
              @click="handleMenuClick('order-list')"
            >
              <img src="/src/assets/订单列表.png" alt="订单列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">订单列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'CreateOrder' }"
              @click="handleMenuClick('create-order')"
            >
              <img src="/src/assets/新建订单.png" alt="新建订单" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">新建订单</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'OrderDetail' }"
              @click="handleMenuClick('order-detail')"
            >
              <img src="/src/assets/订单详情.png" alt="订单详情" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">订单详情</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'SplitBill' }"
              @click="handleMenuClick('split-bill')"
            >
              <img src="/src/assets/账单分拆.png" alt="账单分拆" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">账单分拆</span>
            </li>
          </ul>
        </div>

        <!-- 6. 厨房管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('kitchenManagement')"
          >
            <img 
              src="/src/assets/厨房管理.png"
              alt="厨房管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">厨房管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.kitchenManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.kitchenManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'KitchenBoard' }"
              @click="handleMenuClick('kitchen-board')"
            >
              <img src="/src/assets/厨房看板.png" alt="厨房看板" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">厨房看板</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'OutMealRecord' }"
              @click="handleMenuClick('out-meal-record')"
            >
              <img src="/src/assets/出餐记录.png" alt="出餐记录" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">出餐记录表</span>
            </li>
          </ul>
        </div>

        <!-- 7. 库存管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('inventoryManagement')"
          >
            <img 
              src="/src/assets/库存管理.png"
              alt="库存管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">库存管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.inventoryManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.inventoryManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'MaterialList' }"
              @click="handleMenuClick('material-list')"
            >
              <img src="/src/assets/原材料列表.png" alt="原材料列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">原材料列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'LossRecord' }"
              @click="handleMenuClick('loss-record')"
            >
              <img src="/src/assets/损耗记录.png" alt="损耗记录" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">损耗记录</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'PurchaseOrder' }"
              @click="handleMenuClick('purchase-order')"
            >
              <img src="/src/assets/采购单.png" alt="采购单" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">采购单管理</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'StockWarning' }"
              @click="handleMenuClick('stock-warning')"
            >
              <img src="/src/assets/库存预警.png" alt="库存预警" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">库存预警</span>
            </li>
          </ul>
        </div>

        <!-- 8. 会员管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('memberManagement')"
          >
            <img 
              src="/src/assets/会员管理.png"
              alt="会员管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">会员管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.memberManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.memberManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'MemberList' }"
              @click="handleMenuClick('member-list')"
            >
              <img src="/src/assets/会员列表.png" alt="会员列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">会员列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'RechargeRecord' }"
              @click="handleMenuClick('recharge-record')"
            >
              <img src="/src/assets/储值记录.png" alt="储值记录" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">储值记录</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'MemberRights' }"
              @click="handleMenuClick('member-rights')"
            >
              <img src="/src/assets/会员权益.png" alt="会员权益" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">会员权益配置</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'PointsMall' }"
              @click="handleMenuClick('points-mall')"
            >
              <img src="/src/assets/积分商城.png" alt="积分商城" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">积分商城</span>
            </li>
          </ul>
        </div>

        <!-- 9. 促销管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('promotionManagement')"
          >
            <img 
              src="/src/assets/促销管理.png"
              alt="促销管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">促销管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.promotionManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.promotionManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'PromotionList' }"
              @click="handleMenuClick('promotion-list')"
            >
              <img src="/src/assets/促销列表.png" alt="促销列表" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">促销活动列表</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'CreatePromotion' }"
              @click="handleMenuClick('create-promotion')"
            >
              <img src="/src/assets/创建促销.png" alt="创建促销" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">创建促销活动</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'CouponManagement' }"
              @click="handleMenuClick('coupon-management')"
            >
              <img src="/src/assets/优惠卷管理.png" alt="优惠券管理" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">优惠券管理</span>
            </li>
          </ul>
        </div>

        <!-- 10. 支付管理模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('paymentManagement')"
          >
            <img 
              src="/src/assets/支付管理.png"
              alt="支付管理" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">支付管理</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.paymentManagement, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.paymentManagement }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'PaymentRecord' }"
              @click="handleMenuClick('payment-record')"
            >
              <img src="/src/assets/支付记录.png" alt="支付记录" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">支付记录</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'InvoiceManagement' }"
              @click="handleMenuClick('invoice-management')"
            >
              <img src="/src/assets/发票管理.png" alt="发票管理" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">发票管理</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'AccountSetting' }"
              @click="handleMenuClick('account-setting')"
            >
              <img src="/src/assets/账户设置.png" alt="账户设置" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">收款账户设置</span>
            </li>
          </ul>
        </div>

        <!-- 11. 数据分析模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('statisticsAnalysis')"
          >
            <img 
              src="/src/assets/数据分析.png"
              alt="数据分析" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">数据分析</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.statisticsAnalysis, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.statisticsAnalysis }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'SalesAnalysis' }"
              @click="handleMenuClick('sales-analysis')"
            >
              <img src="/src/assets/销售分析.png" alt="销售分析" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">销售分析</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'CostAnalysis' }"
              @click="handleMenuClick('cost-analysis')"
            >
              <img src="/src/assets/成本分析.png" alt="成本分析" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">成本分析</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'CustomerAnalysis' }"
              @click="handleMenuClick('customer-analysis')"
            >
              <img src="/src/assets/客流分析.png" alt="客流分析" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">客流分析</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'StoreComparison' }"
              @click="handleMenuClick('store-comparison')"
            >
              <img src="/src/assets/门店对比.png" alt="门店对比" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">门店对比</span>
            </li>
          </ul>
        </div>

        <!-- 12. 系统设置模块 -->
        <div class="menu-group">
          <div 
            class="group-header" 
            @click="toggleGroup('systemSetting')"
          >
            <img 
              src="/src/assets/系统设置.png"
              alt="系统设置" 
              class="group-icon"
            >
            <h3 class="group-title" :class="{ 'hidden-text': isCollapsed }">系统设置</h3>
            <img 
              src="/src/assets/下拉菜单.png" 
              alt="展开/折叠" 
              class="group-arrow"
              :class="{ 'rotated': groupCollapsed.systemSetting, 'hidden-arrow': isCollapsed }"
            >
          </div>
          
          <ul 
            class="menu-list" 
            :class="{ 'collapsed-group': groupCollapsed.systemSetting }"
          >
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'StaffManagement' }"
              @click="handleMenuClick('staff-management')"
            >
              <img src="/src/assets/员工管理.png" alt="员工管理" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">员工管理</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'RolePermission' }"
              @click="handleMenuClick('role-permission')"
            >
              <img src="/src/assets/角色权限.png" alt="角色权限" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">角色权限</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'StoreSetting' }"
              @click="handleMenuClick('store-setting')"
            >
              <img src="/src/assets/门店设置.png" alt="门店设置" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">门店设置</span>
            </li>
            <li 
              class="menu-item" 
              :class="{ active: $route.name === 'DataBackup' }"
              @click="handleMenuClick('data-backup')"
            >
              <img src="/src/assets/数据备份.png" alt="数据备份" class="menu-icon">
              <span :class="{ 'hidden-text': isCollapsed }">数据备份</span>
            </li>
          </ul>
        </div>
      </div>
    </aside>

    <!-- 右侧内容区域（路由视图） -->
    <main class="backend-content" :class="{ 'expanded': isCollapsed }">
      <!-- 内容头部 -->
      <div class="content-header">
        <h2 class="page-title">
          {{ getPageTitle() }}
        </h2>
      </div>

      <!-- 路由视图：动态加载子页面 -->
      <div class="content-body">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script lang="ts" setup>
import { ref ,onMounted} from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// 控制菜单整体折叠状态
const isCollapsed = ref(false);

// 控制各菜单组的折叠状态（按模块对应）
const groupCollapsed = ref({
  dashboard: true,            // 数据概览
  tableManagement: true,      // 桌台管理
  queueManagement: true,      // 排队叫号
  dishManagement: true,       // 菜品管理
  orderManagement: true,      // 订单管理
  kitchenManagement: true,    // 厨房管理
  inventoryManagement: true,  // 库存管理
  memberManagement: true,     // 会员管理
  promotionManagement: true,  // 促销管理
  paymentManagement: true,    // 支付管理
  statisticsAnalysis: true,   // 数据分析
  systemSetting: true         // 系统设置
});

// 切换整体菜单折叠/展开
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

// 切换指定菜单组的折叠/展开
const toggleGroup = (group: keyof typeof groupCollapsed.value) => {
  if (!isCollapsed.value) {
    groupCollapsed.value[group] = !groupCollapsed.value[group];
  }
};

// 定义菜单路由项的类型
interface MenuRouteItem {
  name: string;
  title: string;
}

// 菜单与路由映射关系（严格对应页面结构）
interface MenuRoutes {
  // 数据概览
  'dashboard-index': MenuRouteItem;
  
  // 桌台管理
  'table-list': MenuRouteItem;
  'table-layout': MenuRouteItem;
  'transfer-table': MenuRouteItem;
  
  // 排队叫号
  'queue-list': MenuRouteItem;
  'queue-setting': MenuRouteItem;
  
  // 菜品管理
  'dish-list': MenuRouteItem;
  'dish-category': MenuRouteItem;
  'dish-spec': MenuRouteItem;
  'set-meal': MenuRouteItem;
  
  // 订单管理
  'order-list': MenuRouteItem;
  'create-order': MenuRouteItem;
  'order-detail': MenuRouteItem;
  'split-bill': MenuRouteItem;
  
  // 厨房管理
  'kitchen-board': MenuRouteItem;
  'out-meal-record': MenuRouteItem;
  
  // 库存管理
  'material-list': MenuRouteItem;
  'loss-record': MenuRouteItem;
  'purchase-order': MenuRouteItem;
  'stock-warning': MenuRouteItem;
  
  // 会员管理
  'member-list': MenuRouteItem;
  'recharge-record': MenuRouteItem;
  'member-rights': MenuRouteItem;
  'points-mall': MenuRouteItem;
  
  // 促销管理
  'promotion-list': MenuRouteItem;
  'create-promotion': MenuRouteItem;
  'coupon-management': MenuRouteItem;
  
  // 支付管理
  'payment-record': MenuRouteItem;
  'invoice-management': MenuRouteItem;
  'account-setting': MenuRouteItem;
  
  // 数据分析
  'sales-analysis': MenuRouteItem;
  'cost-analysis': MenuRouteItem;
  'customer-analysis': MenuRouteItem;
  'store-comparison': MenuRouteItem;
  
  // 系统设置
  'staff-management': MenuRouteItem;
  'role-permission': MenuRouteItem;
  'store-setting': MenuRouteItem;
  'data-backup': MenuRouteItem;
}

// 菜单路由映射（对应页面组件name）
const menuRoutes = ref<MenuRoutes>({
  // 数据概览
  'dashboard-index': { name: 'DashboardIndex', title: '核心指标看板' },
  
  // 桌台管理
  'table-list': { name: 'TableList', title: '桌台列表' },
  'table-layout': { name: 'TableLayout', title: '桌台布局可视化' },
  'transfer-table': { name: 'TransferTable', title: '转桌/并桌操作' },
  
  // 排队叫号
  'queue-list': { name: 'QueueList', title: '排队列表' },
  'queue-setting': { name: 'QueueSetting', title: '排队规则设置' },
  
  // 菜品管理
  'dish-list': { name: 'DishList', title: '菜品列表' },
  'dish-category': { name: 'DishCategory', title: '菜品分类' },
  'dish-spec': { name: 'DishSpec', title: '菜品规格配置' },
  'set-meal': { name: 'SetMeal', title: '套餐管理' },
  
  // 订单管理
  'order-list': { name: 'OrderList', title: '订单列表' },
  'create-order': { name: 'CreateOrder', title: '新建订单' },
  'order-detail': { name: 'OrderDetail', title: '订单详情' },
  'split-bill': { name: 'SplitBill', title: '账单分拆' },
  
  // 厨房管理
  'kitchen-board': { name: 'KitchenBoard', title: '厨房看板' },
  'out-meal-record': { name: 'OutMealRecord', title: '出餐记录表' },
  
  // 库存管理
  'material-list': { name: 'MaterialList', title: '原材料列表' },
  'loss-record': { name: 'LossRecord', title: '损耗记录' },
  'purchase-order': { name: 'PurchaseOrder', title: '采购单管理' },
  'stock-warning': { name: 'StockWarning', title: '库存预警' },
  
  // 会员管理
  'member-list': { name: 'MemberList', title: '会员列表' },
  'recharge-record': { name: 'RechargeRecord', title: '储值记录' },
  'member-rights': { name: 'MemberRights', title: '会员权益配置' },
  'points-mall': { name: 'PointsMall', title: '积分商城' },
  
  // 促销管理
  'promotion-list': { name: 'PromotionList', title: '促销活动列表' },
  'create-promotion': { name: 'CreatePromotion', title: '创建促销活动' },
  'coupon-management': { name: 'CouponManagement', title: '优惠券管理' },
  
  // 支付管理
  'payment-record': { name: 'PaymentRecord', title: '支付记录' },
  'invoice-management': { name: 'InvoiceManagement', title: '发票管理' },
  'account-setting': { name: 'AccountSetting', title: '收款账户设置' },
  
  // 数据分析
  'sales-analysis': { name: 'SalesAnalysis', title: '销售分析' },
  'cost-analysis': { name: 'CostAnalysis', title: '成本分析' },
  'customer-analysis': { name: 'CustomerAnalysis', title: '客流分析' },
  'store-comparison': { name: 'StoreComparison', title: '门店对比' },
  
  // 系统设置
  'staff-management': { name: 'StaffManagement', title: '员工管理' },
  'role-permission': { name: 'RolePermission', title: '角色权限' },
  'store-setting': { name: 'StoreSetting', title: '门店设置' },
  'data-backup': { name: 'DataBackup', title: '数据备份' },
});

onMounted(()=>{
  router.push({ path: `/Layout/Backendhome/DashboardIndex` });
})
// 菜单点击事件：跳转路由
const handleMenuClick = (path: keyof MenuRoutes) => {
  router.push({ path: `/Layout/Backendhome/${menuRoutes.value[path].name}` });
};

// 根据当前路由获取页面标题
const getPageTitle = () => {
  const currentRouteName = route.name as MenuRouteItem['name']; 
  const matchedMenu = Object.values(menuRoutes.value).find(
    (item) => item.name === currentRouteName
  );
  return matchedMenu?.title || '后台管理';
};
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