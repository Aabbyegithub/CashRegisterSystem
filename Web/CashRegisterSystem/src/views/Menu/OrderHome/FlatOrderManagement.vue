<template>
  <div class="order-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <label>所属桌码：</label>
      <el-select
        v-model="selectedCode"
        placeholder="所属桌码"
        class="filter-item"
      >
        <el-option
          v-for="option in codeOptions"
          :key="option.value"
          :label="option.label"
          :value="option.value"
        />
    </el-select>
      <label>订单编号：</label>
      <el-input
        v-model="orderNo"
        placeholder="订单编号"
        class="filter-item"
        clearable
      />
      <el-button @click="handleReset" style="margin-left: auto;">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
    </div>

    <!-- 订单列表区域 -->
    <div class="order-list">
      <div
        v-for="(order, index) in orderList"
        :key="index"
        class="order-card"
        @click="handleModify(order)"
      >
        <!-- 新增容器包裹桌号和状态，实现同行显示 -->
        <div class="table-status-wrapper">
          <div class="table-info">桌号{{ order.tableNo }}</div>
          <div 
            class="status-tag" 
            :class="{ 
              'status-pending': order.status === '待支付', 
              'status-settled': order.status === '已结清' 
            }"
          >
            {{ order.status }}
          </div>
        </div>
        <div class="detail-item">订单单号： {{ order.order_no }}</div>
        <div class="detail-item">就餐人数： {{ order.peopleCount }} 人</div>
        <div class="detail-item">下单时间： {{ order.orderTime }}</div>
        <div class="detail-item">消费金额： {{ order.amount }} 元</div>
        <div class="detail-item">用餐时间： {{ order.diningTime }}</div>
        <div class="operation-btns">
          <el-button
            v-if="order.status === '待支付'"
            type="text"style="color:#666;"
            @click="handleModify(order)"
          >收款</el-button>
          <!-- <el-button type="text" style="color:#666;" @click.stop="handleDelete(order)">删除</el-button> -->
        </div>
      </div>
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
  </div>
</template>

<script lang="ts" setup>
// 脚本逻辑保持不变（与之前完全一致）
import { ref, onMounted } from 'vue';
import { ElSelect, ElInput, ElButton, ElPagination, ElMessage, dayjs } from 'element-plus';
import type { Options } from 'element-plus';
import { useRouter } from 'vue-router'
import { getFlatOrderList, getTableList } from '../../../api/FlatOrderManagement';
const router = useRouter()
const selectedType = ref<string>('全部');
const selectedCode = ref<string>('全部');
const orderNo = ref<string>('');

const codeOptions = ref<Options[]>( [
  { label: '全部', value: '全部' },
]);

interface Order {
  order_id: number;
  order_no: string;
  tableNo: string;
  status: '待支付' | '已结清';
  peopleCount: number;
  orderTime: string;
  amount: number;
  diningTime: string;
}
const orderList = ref<Order[]>([]);

const total = ref(20);
const pageSize = ref(10);
const currentPage = ref(1);

const getOrderList = async () => {
  await getFlatOrderList(
    selectedCode.value === '全部' ? '' : selectedCode.value,
    orderNo.value,
    currentPage.value,
    pageSize.value
  ).then((res:any) => {
    if (res.start === 200) {
      orderList.value = res.response.map((item: any) => ({
        order_id: item.order_id,
        order_no: item.order_no,
        tableNo: item.table?.table_no,
        status: '待支付',
        peopleCount: item.table_capacity,
        orderTime: dayjs(item.start_time).format('YYYY-MM-DD HH:mm:ss'),
        amount: item.total_amount,
        diningTime: dayjs(item.start_time).format('YYYY-MM-DD HH:mm:ss'),
      }));
      total.value = res.count;
    } else {
      ElMessage.error(res.msg);
    }
  }).catch((error) => {
    ElMessage.error('获取订单列表失败，请稍后重试');
    console.error(error);
  });
};

async function gettableList() {
  await getTableList().then((res: any) => {
      codeOptions.value.push(...res.response.map((item: any) => ({
        label: item.name,
        value: item.id
      })));
  }).catch((error) => {
    ElMessage.error('获取桌台列表失败，请稍后重试');
    console.error(error);
  });
}
onMounted(async () => {await gettableList();await getOrderList();  });
const handleQuery = () => { currentPage.value = 1; getOrderList(); };
const handleReset = () => {
  selectedType.value = '全部';
  selectedCode.value = '全部';
  orderNo.value = '';
  handleQuery();
};
const handleSizeChange = (val: number) => { pageSize.value = val; getOrderList(); };
const handlePageChange = (val: number) => { currentPage.value = val; getOrderList(); };
const handleModify = (order: Order) => { 
 console.log('修改订单', order);
  router.push({ path: '/Layout/OrderDetail', query: { order_id: order.order_id } });
};
const handleDelete = (order: Order) => { console.log('删除订单', order); };

</script>

<style scoped>
/* 仅新增和修改以下样式，其他样式保持不变 */
.table-status-wrapper {
  display: flex;
  align-items: center;
  gap: 10px; /* 桌号和状态之间的间距 */
  margin-bottom: 8px; /* 替代原桌号的margin-bottom */
}

.table-info {
  margin-bottom: 0; /* 取消原桌号的底部间距 */
  width: 100px; /* 确保桌号宽度一致 */
}

/* 其他原有样式保持不变 */
.order-management-container {
  padding: 20px;
  height: 100%;
}
.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}
.filter-item {
  margin-right: 10px;
  width: 180px;
}
.order-list {
  display: flex;
  flex-wrap: wrap;
  column-gap: 20px; /* 水平间距保持20px */
  row-gap: 15px;
  height: 77vh; /* 减去顶部导航栏的高度 */
  overflow-y: auto;
}
.order-card {
  width: 320px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding-top: 15px; 
  padding-left: 15px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  border-color: #fde2e2;
  background-color: #f7fafb;
  height: 250px;
  cursor: pointer;
}
.table-info {
  font-size: 16px;
  font-weight: bold;
}
.status-tag {
  color: #fff;
  padding: 2px 6px;
  border-radius: 4px;
  display: inline-block;
  margin-bottom: 8px;
  height: 40px;
  width: 86px;
  text-align: center;
  line-height: 35px;
  margin-left: auto;
}
.status-pending {
  background-image: url(/src/assets/Group\ 1355.png);
}
.status-settled {
  background-image: url(/src/assets/Group\ 1321316123.png);
}
.detail-item {
  margin-bottom: 4px;
  color: #606266;
}
.operation-btns {
  margin-top: 10px;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
/* .el-pagination {
  display: flex;
} */
/* .el-pagination .btn-prev {
  margin-right: -3000px;
}*/
.pagination-wrap {
  text-align: right;
  margin-top: auto;
  padding: 20px;
} 
</style>