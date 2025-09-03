import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login/Login.vue'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: Login },
  { 
    path: '/Layout', 
    component: () => import('../views/Menu/Layout/Layout.vue'),
    children: [
      { path: 'Orderhome',name: 'Orderhome', component: () => import('../views/Menu/OrderHome/FlatOrderManagement.vue') },
      { path: 'OrderDetail',name: 'OrderDetail', component: () => import('../views/Menu/OrderHome/OrderDetail.vue') , props: (route:any) => ({ order_id: route.query.order_id }) },
      { path: 'Backendhome',name: 'Backendhome',
        component: () => import('../views/Menu/BackendHome/BackendHome.vue'),
        children: [
          {
            path: 'DashboardIndex', 
            name: 'DashboardIndex',
            component: () => import('../views/Menu/BackendHome/Dashboard/DashboardIndex.vue')
          },
          { 
            path: 'TableList', 
            name: 'TableList',
            component: () => import('../views/Menu/BackendHome/TableManagement/TableManage.vue') 
          },
          { 
            path: 'TableLayout', 
            name: 'TableLayout',
            component: () => import('../views/Menu/BackendHome/TableManagement/TableLayout.vue') 
          },
          { 
            path: 'TransferTable', 
            name: 'TransferTable',
            component: () => import('../views/Menu/BackendHome/TableManagement/TableOperation.vue') 
          },
          { 
            path: 'QueueList', 
            name: 'QueueList',
            component: () => import('../views/Menu/BackendHome/RestaurantQueue/RestaurantQueueList.vue') 
          },
          {
            path: 'MemberList',
            name: 'MemberList',
            component: () => import('../views/Menu/BackendHome/MembershipManagement/MemberManagement.vue')
          },
          {
            path: 'RechargeRecord',
            name: 'RechargeRecord',
            component: () => import('../views/Menu/BackendHome/MembershipManagement/MemberBalanceRecord.vue')
          },
          {
            path: 'DishList',
            name: 'DishList',
            component: () => import('../views/Menu/BackendHome/Dish/DishManagement.vue')
          },
          {
            path: 'DishCategory',
            name: 'DishCategory',
            component: () => import('../views/Menu/BackendHome/Dish/DishCategoryManagement.vue')
          },
          {
            path: 'DishSpec',
            name: 'DishSpec',
            component: () => import('../views/Menu/BackendHome/Dish/DishSpecManagement.vue')
          },
          {
            path: 'SetMeal',
            name: 'SetMeal',
            component: () => import('../views/Menu/BackendHome/Dish/SetMealManagement.vue')
          },
          {
            path: 'OrderList',
            name: 'OrderList',
            component: () => import('../views/Menu/BackendHome/Order/OrderManager.vue')
          },
          {
            path: 'KitchenBoard',
            name: 'KitchenBoard',
            component: () => import('../views/Menu/BackendHome/kitchen/KitchenDashboard.vue')
          },
          {
            path: 'OutMealRecord',
            name: 'OutMealRecord',
            component: () => import('../views/Menu/BackendHome/kitchen/KitchenRecord.vue')
          },
          {
            path: 'KitchenManagement',
            name: 'KitchenManagement',
            component: () => import('../views/Menu/BackendHome/kitchen/KitchenManage.vue')
          },
          { 
            path: 'StaffManagement', 
            name: 'StaffManagement',
            component: () => import('../views/Menu/BackendHome/System/StaffManagement.vue') 
          },
          { 
            path: 'RolePermission', 
            name: 'RolePermission',
            component: () => import('../views/Menu/BackendHome/System/RolePermissionManagement.vue') 
          },
          { 
            path: 'StoreSetting', 
            name: 'StoreSetting',
            component: () => import('../views/Menu/BackendHome/System/StoreManagement.vue') 
          },
          { 
            path: 'DataBackup', 
            name: 'DataBackup',
            component: () => import('../views/Menu/BackendHome/System/DataBackupManagement.vue') 
          },
                    { 
            path: 'MaterialList', 
            name: 'MaterialList',
            component: () => import('../views/Menu/BackendHome/inventoryManagement/RawMaterialList.vue') 
          },
                    { 
            path: 'LossRecord', 
            name: 'LossRecord',
            component: () => import('../views/Menu/BackendHome/inventoryManagement/LossRecord.vue') 
          },
                    { 
            path: 'PurchaseOrder', 
            name: 'PurchaseOrder',
            component: () => import('../views/Menu/BackendHome/inventoryManagement/PurchaseOrderList.vue') 
          },
                    { 
            path: 'StockWarning', 
            name: 'StockWarning',
            component: () => import('../views/Menu/BackendHome/inventoryManagement/InventoryWarning.vue') 
          },
                    { 
            path: 'CouponManagement', 
            name: 'CouponManagement',
            component: () => import('../views/Menu/BackendHome/Promotion/CouponManagement.vue') 
          },
                    { 
            path: 'PromotionList', 
            name: 'PromotionList',
            component: () => import('../views/Menu/BackendHome/Promotion/PromotionList.vue') 
          },
                    { 
            path: 'CoreKPIReport', 
            name: 'CoreKPIReport',
            component: () => import('../views/Menu/BackendHome/Report/CoreKPIReport.vue') 
          },
                    { 
            path: 'DishAnalysisReport', 
            name: 'DishAnalysisReport',
            component: () => import('../views/Menu/BackendHome/Report/DishAnalysisReport.vue') 
          },
                    { 
            path: 'OperationDecisionReport', 
            name: 'OperationDecisionReport',
            component: () => import('../views/Menu/BackendHome/Report/OperationDecisionReport.vue') 
          },
          { 
            path: 'TaskManagement', 
            name: 'TaskManagement',
            component: () => import('../views/Menu/BackendHome/System/TimerTaskManagement.vue') 
          },
          { 
            path: 'SupplierManagement', 
            name: 'SupplierManagement',
            component: () => import('../views/Menu/BackendHome/System/SupplierManagement.vue') 
          },
           { 
            path: 'OperationLogManagement', 
            name: 'OperationLogManagement',
            component: () => import('../views/Menu/BackendHome/System/OperationLogManagement.vue') 
          },
        ]
       },
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
