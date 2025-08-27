<template>
  <div class="kitchen-record-container">
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
      <el-form-item label="时间区间：">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" style="min-width:220px;" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 出餐记录列表 -->
    <el-table :data="filteredOrders" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="table_no" label="桌台" align="center" />
      <el-table-column prop="dish_name" label="菜品名称" align="center" />
      <el-table-column prop="spec_name" label="规格" align="center" />
      <el-table-column prop="quantity" label="数量" align="center" />
      <el-table-column prop="cooking_require" label="烹饪要求" align="center" />
      <el-table-column prop="kitchen_type" label="厨房类型" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag :type="statusTagType(scope.row.status)">{{ statusMap[scope.row.status] }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="create_time" label="派单时间" align="center" />
      <el-table-column prop="finish_time" label="完成时间" align="center" />
      <el-table-column prop="pick_time" label="取餐时间" align="center" />
      <el-table-column prop="cook_name" label="厨师" align="center" />
      <el-table-column prop="picker_name" label="取餐员" align="center" />
    </el-table>
    <div v-if="filteredOrders.length === 0" class="empty-row">
      <el-empty description="暂无出餐记录" />
    </div>

    <!-- 分页 -->
    <div class="pagination-bar">
      <el-pagination
        layout="prev, pager, next, ->, sizes, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="currentPage"
        :page-sizes="[10, 20, 30, 40, 50]"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';

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
const dateRange = ref<[Date | null, Date | null] | null>(null);

const statusMap: Record<number | string, string> = {
  1: '待制作',
  2: '制作中',
  3: '已完成',
  4: '已取餐',
  5: '已退菜',
};

const orders = ref<KitchenOrder[]>([
  { kitchen_id: 1, item_id: 101, store_id: 1, table_no: 'A01', dish_name: '宫保鸡丁', spec_name: '大份', quantity: 2, cooking_require: '微辣', kitchen_type: '热菜', status: 1, create_time: '2025-08-22 12:00:00', finish_time: '2025-08-22 12:20:00', pick_time: '2025-08-22 12:25:00', overtime_warn: 0, cook_id: 201, picker_id: 301 },
  { kitchen_id: 2, item_id: 102, store_id: 1, table_no: 'A02', dish_name: '凉拌黄瓜', spec_name: '', quantity: 1, cooking_require: '', kitchen_type: '凉菜', status: 3, create_time: '2025-08-22 12:05:00', finish_time: '2025-08-22 12:15:00', pick_time: '2025-08-22 12:18:00', overtime_warn: 1, cook_id: 202, picker_id: 302 },
  { kitchen_id: 3, item_id: 103, store_id: 2, table_no: 'B01', dish_name: '柠檬水', spec_name: '', quantity: 3, cooking_require: '', kitchen_type: '饮品', status: 4, create_time: '2025-08-22 12:10:00', finish_time: '2025-08-22 12:15:00', pick_time: '2025-08-22 12:16:00', overtime_warn: 0, cook_id: 203, picker_id: 303 },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(orders.value.length);

const filteredOrders = computed(() => {
  let result = orders.value.filter(order => {
    const matchStore = !selectedStore.value || String(order.store_id) === selectedStore.value;
    const matchType = !kitchenType.value || order.kitchen_type === kitchenType.value;
    const matchStatus = !status.value || String(order.status) === status.value;
    let matchDate = true;
    if (dateRange.value && dateRange.value[0] && dateRange.value[1]) {
      const start = new Date(dateRange.value[0]).getTime();
      const end = new Date(dateRange.value[1]).getTime();
      const create = new Date(order.create_time).getTime();
      matchDate = create >= start && create <= end;
    }
    return matchStore && matchType && matchStatus && matchDate;
  });
  total.value = result.length;
  // 分页
  const startIdx = (currentPage.value - 1) * pageSize.value;
  return result.slice(startIdx, startIdx + pageSize.value);
});

const handleQuery = () => {
  // 仅刷新筛选和分页
};
const handleReset = () => {
  selectedStore.value = '';
  kitchenType.value = '';
  status.value = '';
  dateRange.value = null;
  handleQuery();
};
const handleSizeChange = (val: number) => {
  pageSize.value = val;
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
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
</script>

<style scoped>
.kitchen-record-container {
  padding: 20px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  margin-bottom: 18px;
}
.empty-row {
  width: 100%;
  text-align: center;
  padding: 40px 0;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
  padding: 18px 24px 0 0;
  font-size: 15px;
}
</style>
