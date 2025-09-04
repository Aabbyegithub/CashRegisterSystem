<template>
  <div class="kitchen-dashboard-container">
    <!-- 筛选区 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店：">
        <el-select v-model="selectedStore" placeholder="请选择门店" style="min-width:140px;">
          <el-option value="">全部门店</el-option>
          <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="厨房类型：">
        <el-select v-model="kitchenType" placeholder="全部类型" style="min-width:120px;">
          <el-option value="">全部</el-option>
          <el-option v-for="kitchen in kitchenList" :key="kitchen.id" :label="kitchen.name" :value="kitchen.name" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="status" placeholder="全部状态" style="min-width:120px;">
          <el-option value="">全部</el-option>
          <el-option v-for="(label, value) in statusMap" :key="value" :label="label" :value="value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="fetchOrders">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 统计卡片区 -->
    <div class="stats-container">
      <div class="stat-card" v-for="(count, key) in stats" :key="key">
        <div class="stat-label">{{ statusMap[key] }}</div>
        <div class="stat-value">{{ count }}</div>
      </div>
    </div>

    <!-- 厨房订单卡片区 -->
    <div class="order-card-list">
      <div v-for="order in orders" :key="order.kitchen_id" class="order-card" :class="order.status">
        <div class="order-header">
          <span class="order-table">桌台：{{ order.table_no }}</span>
          <span class="order-type">{{ order.kitchen_type }}</span>
          <span v-if="order.overtime_warn === 1" class="overtime">超时预警</span>
        </div>
        <div class="order-body">
          <div class="order-dish">{{ order.dish_name }} <span v-if="order.spec_name">({{ order.spec_name }})</span></div>
          <div class="order-qty">数量：{{ order.quantity }}</div>
          <div class="order-require">要求：{{ order.cooking_require || '-' }}</div>
        </div>
        <div class="order-footer">
          <span>派单：{{ order.create_time }}</span>
          <el-tag :type="statusTagType(order.status)">{{ statusMap[order.status] }}</el-tag>
        </div>
        <div class="order-actions">
          <el-button v-if="order.status === 1" type="primary" size="small" @click="startCooking(order)">开始制作</el-button>
          <el-button v-if="order.status === 2" type="success" size="small" @click="finishCooking(order)">完成</el-button>
          <el-button v-if="order.status === 3" type="info" size="small" @click="pickOrder(order)">取餐</el-button>
          <!-- <el-button v-if="order.status < 4" type="danger" size="small" @click="cancelOrder(order)">退菜</el-button> -->
        </div>
      </div>
      <div v-if="orders.length === 0" class="empty-row">
        <el-empty description="当前没有厨房订单" />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref,onMounted, onUnmounted } from 'vue';
import { dayjs, ElMessage } from 'element-plus';
import { getKitchenOrderList, getOrderStatusStats, updateOrderStatus } from  '../../../../api/KitchenManage';
import { getStoreList } from '../../../../api/login';
import { getkitchenList } from '../../../../api/dish';

interface Store { id: string; name: string; }
interface KitchenOrder {
  kitchen_id: number;
  item_id: number;
  store_id: number;
  table_no: string;
  dish_name: string;
  spec_name?: string;
  quantity: number;
  cooking_require?: string;
  kitchen_type: string;
  status: number;
  create_time: string;
  finish_time?: string;
  pick_time?: string;
  overtime_warn: number;
  cook_id?: number;
  picker_id?: number;
}

const storeList = ref<Store[]>([]);
const selectedStore = ref('');
const kitchenType = ref('');
const status = ref('');
const kitchenList = ref<any[]>([]);

const statusMap: Record<number | string, string> = {
  1: '待制作',
  2: '制作中',
  3: '已完成',
  4: '已取餐',
  5: '已退菜',
};
const stats = ref({ 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 });

const orders = ref<KitchenOrder[]>([]);

// const filteredOrders = computed(() => {
//   return orders.value.filter(order => {
//     return (
//       (!selectedStore.value || String(order.store_id) === selectedStore.value) &&
//       (!kitchenType.value || order.kitchen_type === kitchenType.value) &&
//       (!status.value || String(order.status) === status.value)
//     );
//   });
// });
let refreshTimer: number | undefined;
onMounted(() => {
  fetchOrders();
  fetchStats();
  fetchStoreList();
  fetchkitchenList()
  refreshTimer = window.setInterval(() => {
    fetchOrders();
    fetchStats();
  }, 60000);
});
onUnmounted(() => {
  if (refreshTimer) clearInterval(refreshTimer);
});
// 查询订单
async function fetchOrders() {
  const res:any = await getKitchenOrderList({
    storeId: selectedStore.value,
    kitchenType: kitchenType.value,
    status: status.value
  });
  if (res.success) {
    orders.value = res.response.map((item:any) => ({
      kitchen_id: item.kitchen_id,
      item_id: item.item_id,
      store_id: item.store_id,
      table_no: item.table_no,
      dish_name: item.dish_name,
      spec_name: item.spec_name,
      quantity: item.quantity,
      cooking_require: item.cooking_require,
      kitchen_type: item.kitchen_type,
      status: item.status,
      create_time: dayjs(item.create_time).format('YYYY-MM-DD HH:mm:ss'),
      finish_time: item.finish_time,
      pick_time: item.pick_time,
      overtime_warn: item.overtime_warn,
      cook_id: item.cook_id,
      picker_id: item.picker_id
    }));
  }
  fetchStats()
}

// 查询统计
async function fetchStats() {
  const res:any = await getOrderStatusStats({
    storeId: selectedStore.value,
    kitchenType: kitchenType.value
  });
  if (res.success) {
    stats.value = res.response;
  }
}

// 更新订单状态
async function updateStatus(order: KitchenOrder, newStatus: number) {
  const res = await updateOrderStatus({
    kitchenOrderId: order.kitchen_id,
    status: newStatus
  });
  if (res.data.success) {
    ElMessage.success('状态已更新');
    fetchOrders();
    fetchStats();
  } else {
    ElMessage.error('状态更新失败');
  }
}

// const handleQuery = () => {
//   // 统计各状态数量
//   const statObj = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
//   filteredOrders.value.forEach(order => {
//     const statusNum = Number(order.status);
//     if (statusNum >= 1 && statusNum <= 5) {
//       statObj[statusNum as 1|2|3|4|5]++;
//     }
//   });
//   stats.value = { ...statObj };
// };

const handleReset = () => {
  selectedStore.value = '';
  kitchenType.value = '';
  status.value = '';
  fetchStats();
};

const statusTagType = (status: number) => {
  switch (status) {
    case 1: return 'warning';
    case 2: return 'primary';
    case 3: return 'success';
    case 4: return 'info';
    case 5: return 'danger';
    default: return '';
  }
};

const startCooking = (order: KitchenOrder) => updateStatus(order, 2);
const finishCooking = (order: KitchenOrder) => updateStatus(order, 3);
const pickOrder = (order: KitchenOrder) => updateStatus(order, 4);

async function fetchStoreList() {
  await getStoreList().then((res:any)=> {
    if (res && res.response) {
      var storedata = res.response.filter((item: any) => item.store_name !== '管理员');
      storeList.value = storedata.map((item: any) => ({
        id: item.store_id,
        name: item.store_name
      }));
    }
  });
}

async function fetchkitchenList(){
 await getkitchenList().then((res: any) => {
    if (res && res.response) {
      kitchenList.value = res.response.map((item: any) => ({
        id: item.id,
        name: item.kitchen_name
      }));
    }
  });
}

</script>

<style scoped>
.kitchen-dashboard-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  margin-bottom: 18px;
}
.stats-container {
  display: flex;
  gap: 16px;
  margin-bottom: 18px;
}
.stat-card {
  flex: 1;
  min-width: 120px;
  background: #fff;
  border-radius: 8px;
  padding: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  text-align: center;
}
.stat-label {
  font-size: 14px;
  color: #4E5969;
  margin-bottom: 6px;
}
.stat-value {
  font-size: 22px;
  font-weight: 600;
  color: #1D2129;
}
.order-card-list {
  display: flex;
  flex-wrap: wrap;
  gap: 18px;
}
.order-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  width: 320px;
  margin-bottom: 18px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  position: relative;
}
.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 15px;
  margin-bottom: 4px;
}
.order-table {
  font-weight: 600;
  color: #165DFF;
}
.order-type {
  color: #22A2B6;
}
.overtime {
  color: #FF4D4F;
  font-weight: 600;
}
.order-body {
  font-size: 15px;
  margin-bottom: 4px;
}
.order-dish {
  font-weight: 600;
}
.order-qty {
  color: #4E5969;
}
.order-require {
  color: #86909C;
}
.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}
.order-actions {
  display: flex;
  gap: 8px;
  margin-top: 6px;
}
.empty-row {
  width: 100%;
  text-align: center;
  padding: 40px 0;
}
</style>
