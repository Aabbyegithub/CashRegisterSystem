
<template>
  <div class="order-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <label>订单号/桌台号/会员号：</label>
      <el-input v-model="searchOrderNo" placeholder="请输入关键词" class="filter-item" clearable />
      <el-button @click="filterOrders" style="margin-left: auto;">查询</el-button>
      <el-button @click="refreshOrders">刷新</el-button>
    </div>
    <!-- 订单列表区域 -->
    <div class="order-list">
      <el-table
        :data="orders"
        border
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column type="index" label="序号" align="center" width="60" />
        <el-table-column prop="order_no" label="订单号" align="center"/>
        <el-table-column prop="table_id" label="桌台号" align="center" />
        <el-table-column prop="member_id" label="会员号" align="center"/>
        <el-table-column prop="order_type" label="类型" align="center">
          <template #default="scope">
            <span>{{ orderTypeText(scope.row.order_type) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">{{ scope.row.status === 1 ? '已结算' : '未结算' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="total_amount" label="总金额" align="center" />
        <el-table-column prop="discount_amount" label="优惠金额" align="center" />
        <el-table-column prop="service_fee" label="服务费" align="center" />
        <el-table-column prop="payable_amount" label="应付金额" align="center" />
        <el-table-column prop="table_fee" label="桌台费" align="center" />
        <el-table-column prop="start_time" label="下单时间" align="center" />
        <el-table-column prop="pay_time" label="结算时间" align="center" />
        <el-table-column prop="operator_id" label="操作员" align="center" />
        <el-table-column label="操作" align="center" width="180">
          <template #default="scope">
            <el-button type="text" style="color: #22A2B6;" @click="showOrderDetails(scope.row)">详情</el-button>
            <el-button type="primary" size="small" v-if="scope.row.status === 0">去结算</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    <!-- 分页区域 -->
    <div class="pagination-bar">
      <el-pagination
        layout="prev, pager, next, ->, sizes, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="currentPage"
        :prev-text="'<'"
        :next-text="'>'"
        :page-sizes="[10, 20, 30, 40, 50]"
        :display-page-count="5"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>
    <!-- 订单详情弹窗 -->
    <el-dialog v-model="showDetailsDialog" title="订单详情" width="700px">
      <div class="dialog-section-title">订单信息</div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder.order_no }}</el-descriptions-item>
        <el-descriptions-item label="桌台号">{{ currentOrder.table_id }}</el-descriptions-item>
        <el-descriptions-item label="会员号">{{ currentOrder.member_id }}</el-descriptions-item>
        <el-descriptions-item label="订单类型">{{ orderTypeText(currentOrder.order_type) }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentOrder.status === 1 ? 'success' : 'info'">{{ currentOrder.status === 1 ? '已结算' : '未结算' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="总金额">{{ currentOrder.total_amount }}</el-descriptions-item>
        <el-descriptions-item label="优惠金额">{{ currentOrder.discount_amount }}</el-descriptions-item>
        <el-descriptions-item label="服务费">{{ currentOrder.service_fee }}</el-descriptions-item>
        <el-descriptions-item label="应付金额">{{ currentOrder.payable_amount }}</el-descriptions-item>
        <el-descriptions-item label="桌台费">{{ currentOrder.table_fee }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder.start_time }}</el-descriptions-item>
        <el-descriptions-item label="结算时间">{{ currentOrder.pay_time }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentOrder.remark }}</el-descriptions-item>
        <el-descriptions-item label="操作员">{{ currentOrder.operator_id }}</el-descriptions-item>
      </el-descriptions>
      <div class="dialog-section-title">关联菜品</div>
      <el-table :data="currentOrder.dishes || []" border style="width: 100%; margin-top: 8px;">
        <el-table-column prop="dish_name" label="菜品名称" />
        <el-table-column prop="quantity" label="数量" width="80" />
        <el-table-column prop="price" label="单价" width="100" />
        <el-table-column prop="amount" label="金额" width="100" />
      </el-table>
      <div class="dialog-section-title">桌台信息</div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="桌台容量">{{ currentOrder.table_capacity }}</el-descriptions-item>
        <!-- 可扩展更多桌台信息 -->
      </el-descriptions>
      <template #footer>
        <el-button @click="showDetailsDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const orders = ref([])
const searchOrderNo = ref('')
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
function refreshOrders() {
  // TODO: 调用订单列表API
}
function filterOrders() {

}

function orderTypeText(type: number) {
  switch (type) {
    case 0: return '堂食';
    case 1: return '外卖';
    default: return '其他';
  }
}
const showDetailsDialog = ref(false)
const currentOrder = ref<any>({})
function showOrderDetails(row: any) {
  currentOrder.value = row
  showDetailsDialog.value = true
}

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  filterOrders();
};

const handlePageChange = (val: number) => {
  currentPage.value = val;
  filterOrders();
};
</script>

<style scoped>

.order-management-container {
  padding: 20px;
  height: calc(100vh - 140px);
}
.page-title {
  font-size: 22px;
  font-weight: bold;
  margin-bottom: 18px;
}
.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}
.filter-item {
  margin-right: 20px;
  width: 180px;
}
.order-list {
  margin-bottom: 20px;
  height: 83%;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.dialog-section-title {
  margin-top: 18px;
  font-weight: bold;
  font-size: 16px;
  color: #22A2B6;
}
</style>