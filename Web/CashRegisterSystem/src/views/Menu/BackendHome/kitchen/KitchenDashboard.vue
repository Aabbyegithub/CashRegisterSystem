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
          <el-option value="热菜">热菜</el-option>
          <el-option value="凉菜">凉菜</el-option>
          <el-option value="饮品">饮品</el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="status" placeholder="全部状态" style="min-width:120px;">
          <el-option value="">全部</el-option>
          <el-option value="1">待制作</el-option>
          <el-option value="2">制作中</el-option>
          <el-option value="3">已完成</el-option>
          <el-option value="4">已取餐</el-option>
          <el-option value="5">已退菜</el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">查询</el-button>
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
      <div v-for="order in filteredOrders" :key="order.kitchen_id" class="order-card" :class="order.status">
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
          <el-button v-if="order.status < 4" type="danger" size="small" @click="cancelOrder(order)">退菜</el-button>
        </div>
      </div>
      <div v-if="filteredOrders.length === 0" class="empty-row">
        <el-empty description="当前没有厨房订单" />
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { ElMessage } from 'element-plus';

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

const storeList = ref<Store[]>([
  { id: '1', name: '旗舰店' },
  { id: '2', name: '分店A' }
]);
const selectedStore = ref('');
const kitchenType = ref('');
const status = ref('');

const statusMap: Record<number | string, string> = {
  1: '待制作',
  2: '制作中',
  3: '已完成',
  4: '已取餐',
  5: '已退菜',
};
const stats = ref({ 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 });

const orders = ref<KitchenOrder[]>([
  { kitchen_id: 1, item_id: 101, store_id: 1, table_no: 'A01', dish_name: '宫保鸡丁', spec_name: '大份', quantity: 2, cooking_require: '微辣', kitchen_type: '热菜', status: 1, create_time: '2025-08-22 12:00:00', overtime_warn: 0 },
  { kitchen_id: 2, item_id: 102, store_id: 1, table_no: 'A02', dish_name: '凉拌黄瓜', spec_name: '', quantity: 1, cooking_require: '', kitchen_type: '凉菜', status: 2, create_time: '2025-08-22 12:05:00', overtime_warn: 1 },
  { kitchen_id: 3, item_id: 103, store_id: 2, table_no: 'B01', dish_name: '柠檬水', spec_name: '', quantity: 3, cooking_require: '', kitchen_type: '饮品', status: 3, create_time: '2025-08-22 12:10:00', overtime_warn: 0 },
]);

const filteredOrders = computed(() => {
  return orders.value.filter(order => {
    return (
      (!selectedStore.value || String(order.store_id) === selectedStore.value) &&
      (!kitchenType.value || order.kitchen_type === kitchenType.value) &&
      (!status.value || String(order.status) === status.value)
    );
  });
});

const handleQuery = () => {
  // 统计各状态数量
  const statObj = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  filteredOrders.value.forEach(order => {
    const statusNum = Number(order.status);
    if (statusNum >= 1 && statusNum <= 5) {
      statObj[statusNum as 1|2|3|4|5]++;
    }
  });
  stats.value = { ...statObj };
};

const handleReset = () => {
  selectedStore.value = '';
  kitchenType.value = '';
  status.value = '';
  handleQuery();
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

const startCooking = (order: KitchenOrder) => {
  order.status = 2;
  ElMessage.success('已开始制作');
  handleQuery();
};
const finishCooking = (order: KitchenOrder) => {
  order.status = 3;
  order.finish_time = new Date().toISOString();
  ElMessage.success('已完成制作');
  handleQuery();
};
const pickOrder = (order: KitchenOrder) => {
  order.status = 4;
  order.pick_time = new Date().toISOString();
  ElMessage.success('已取餐');
  handleQuery();
};
const cancelOrder = (order: KitchenOrder) => {
  order.status = 5;
  ElMessage.error('已退菜');
  handleQuery();
};

// 初始化统计
handleQuery();
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
