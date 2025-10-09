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
          <el-option v-for="(label, value) in statusMap" :key="value" :label="label" :value="value" />
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
import { getAllKitchenOrderList } from '../../../../api/KitchenManage';
import { dayjs } from 'element-plus';
import { getStoreList } from '../../../../api/login';

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
  cook_name?: string;
  picker_name?: string;
}

const storeList = ref<Store[]>([]);
const selectedStore = ref('');
const kitchenType = ref('');
const status = ref('');
const dateRange = ref<[Date | null, Date | null] | null>(null);

const orders = ref<KitchenOrder[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

const statusMap: Record<number | string, string> = {
  1: '待制作',
  2: '制作中',
  3: '已完成',
  4: '已取餐',
  5: '已退菜',
};

const filteredOrders = computed(() => orders.value);

async function fetchOrders() {
  const params: any = {
    storeId: selectedStore.value,
    kitchenType: kitchenType.value,
    status: status.value,
    page: currentPage.value,
    size: pageSize.value
  };
  if (dateRange.value && dateRange.value[0] && dateRange.value[1]) {
    params.StartTime = dateRange.value[0].toISOString();
    params.EndTime = dateRange.value[1].toISOString();
  }
  const res:any = await getAllKitchenOrderList(params);
  if (res.success) {
    orders.value = res.response.map((item:any) => ({
      ...item,
      create_time:dayjs(item.create_time).format('YYYY-MM-DD HH:mm:ss'),
      finish_time: item.finish_time ? dayjs(item.finish_time).format('YYYY-MM-DD HH:mm:ss') : '',
      pick_time: item.pick_time ? dayjs(item.pick_time).format('YYYY-MM-DD HH:mm:ss') : '',
      cook_name: item.cook ? item.cook.name : '',
      picker_name: item.picker ? item.picker.name : ''
    }));
    total.value = res.count; // 如果接口有 total 字段请用 total
  }
}

const handleQuery = () => {
  currentPage.value = 1;
  fetchOrders();
};
const handleReset = () => {
  selectedStore.value = '';
  kitchenType.value = '';
  status.value = '';
  dateRange.value = null;
  currentPage.value = 1;
  fetchOrders();
};
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchOrders();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  fetchOrders();
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


fetchOrders();
fetchStoreList();
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
