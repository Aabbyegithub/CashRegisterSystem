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
      { path: 'OrderDetail',name: 'OrderDetail', component: () => import('../views/Menu/OrderHome/OrderDetail.vue') },
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
