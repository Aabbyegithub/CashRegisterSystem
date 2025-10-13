<template>
  <div class="order-management-container">
    <!-- 筛选区域 -->
    <el-form :inline="true" class="filter-bar" @submit.prevent>
      <el-form-item label="门店：">
        <el-select v-model="selectedStore" placeholder="请选择门店" style="min-width:140px;" clearable @change="handchange">
          <el-option value="">全部门店</el-option>
          <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="订单号">
        <el-input v-model="searchOrderNo" placeholder="请输入订单号" class="filter-item" clearable />
      </el-form-item>
      <el-form-item label="桌台号">
        <el-select v-model="searchTableId" placeholder="请选择桌台号" class="filter-item" clearable>
          <el-option v-for="table in tableList" :key="table.id" :label="table.name" :value="table.id" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="filterOrders">查询</el-button>
        <el-button @click="refreshOrders">刷新</el-button>
        <el-button style="background-color: #22A2B6;" @click="ReservationOrders">预定</el-button>
      </el-form-item>
    </el-form>
    <!-- 订单列表区域 -->
    <div class="order-list">
      <el-table
        :data="orders"
        border
        style="width: 100%; height: 68vh;"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column type="index" label="序号" align="center" width="60" />
        <el-table-column prop="order_no" label="订单号" align="center"/>
        <el-table-column prop="table_id" label="桌台号" align="center" />
        <!-- <el-table-column prop="member_id" label="会员号" align="center"/> -->
        <el-table-column prop="order_type" label="类型" align="center">
          <template #default="scope">
            <span>{{ orderTypeText(scope.row.order_type) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 3 ? 'success' : 'info'"> <span>{{ orderTypeText1(scope.row.status) }}</span></el-tag>
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
            <el-button type="primary"  size="small" style="background-color: #22A2B6;" @click="showOrderDetails(scope.row)">详情</el-button>
            <el-button type="warning" size="small" v-if="scope.row.status === 1||scope.row.status === 2" @click="handlePending(scope.row)">挂单</el-button>
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
        <el-descriptions-item label="桌台号">{{ currentOrder.table?.table_no }}</el-descriptions-item>
        <el-descriptions-item label="会员号">{{ currentOrder.member_id }}</el-descriptions-item>
        <el-descriptions-item label="订单类型">{{ orderTypeText(currentOrder.order_type) }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentOrder.status ===3 ? 'success' : 'info'">{{ orderTypeText1(currentOrder.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="总金额">{{ currentOrder.total_amount }}</el-descriptions-item>
        <el-descriptions-item label="优惠金额">{{ currentOrder.discount_amount }}</el-descriptions-item>
        <el-descriptions-item label="服务费">{{ currentOrder.service_fee }}</el-descriptions-item>
        <el-descriptions-item label="应付金额">{{ currentOrder.payable_amount }}</el-descriptions-item>
        <el-descriptions-item label="桌台费">{{ currentOrder.table_fee }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder.start_time }}</el-descriptions-item>
        <el-descriptions-item label="结算时间">{{ currentOrder.pay_time }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentOrder.remark }}</el-descriptions-item>
        <el-descriptions-item label="操作员">{{ currentOrder.staff?.name }}</el-descriptions-item>
      </el-descriptions>
      <div class="dialog-section-title">关联菜品</div>
      <el-table :data="currentOrder.orderitem || []" border style="width: 100%; margin-top: 8px;">
        <el-table-column prop="dish_name" label="菜品名称" >
          <template #default="scope">
            {{ scope.row.dish?.dish_name || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="80" />
        <el-table-column prop="unit_price" label="单价" width="100" />
        <el-table-column prop="total_price" label="金额" width="100" />
        <el-table-column prop="specification" label="要求" width="100" />
      </el-table>
      <div class="dialog-section-title">桌台信息</div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="桌台容量">{{ currentOrder.table?.capacity }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="showDetailsDialog = false">关闭</el-button>
        <el-button v-if="currentOrder.status === 3" @click="handRefundOrder(currentOrder.order_id)">退款</el-button>
        <el-button type="primary" size="small" v-if="currentOrder.status === 1||currentOrder.status === 2 ||currentOrder.status === 5"@click="handlePay(currentOrder.order_id)">去结算</el-button>
      </template>
    </el-dialog>
    <!-- 预定弹窗 -->
    <el-dialog v-model="reservationDialogVisible" title="新增预定" width="400px">
      <el-form :model="reservationForm" :rules="reservationRules" ref="reservationFormRef" label-width="90px">
        <el-form-item label="门店" prop="store_id">
          <el-select v-model="reservationForm.store_id" placeholder="请选择门店" @change="onReservationStoreChange">
            <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="桌台" prop="table_id">
          <el-select v-model="reservationForm.table_id" placeholder="请选择桌台">
            <el-option v-for="table in reservationTableList.filter(a=>a.status == 1)" :key="table.id" :label="table.name" :value="table.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="姓名" prop="reservation_name">
          <el-input v-model="reservationForm.reservation_name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="电话" prop="reservation_phone">
          <el-input v-model="reservationForm.reservation_phone" placeholder="请输入电话" />
        </el-form-item>
        <el-form-item label="预定时间" prop="reservation_time">
          <el-date-picker
            v-model="reservationForm.reservation_time"
            type="datetime"
            placeholder="请选择预定时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="人数" prop="reservation_capacity">
          <el-input v-model.number="reservationForm.reservation_capacity" type="number" min="1" placeholder="请输入人数" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="reservationForm.remark" type="textarea" placeholder="备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reservationDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReservation">确认预定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getStoreList } from '../../../../api/login'
import { getStoreTables } from '../../../../api/TableOperation'
import { dayjs, ElMessage } from 'element-plus';
import { getAllOrderList, handOrder, RefundOrder, reserveOrder } from '../../../../api/order';
import { useRouter } from 'vue-router';

// 假设你有 addReservation、getStoreTables 相关API
// import { addReservation } from '../../../../api/Reservation';
const orders = ref([])
const searchOrderNo = ref('')
const searchTableId = ref('')
const tableList = ref<{ id: string | number, name: string,status:number }[]>([])
const storeList = ref<{ id: string | number, name: string }[]>([])
const selectedStore = ref('')
const router = useRouter();

const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);

async function filterOrders() {
  const res:any = await getAllOrderList({
    page: currentPage.value,
    size: pageSize.value,
    store_Id: selectedStore.value,
    OrdderNo: searchOrderNo.value,
    tableId: searchTableId.value
  });
  if (res && res.success) {
    orders.value = res.response;
    total.value = res.count;
  }
}

function refreshOrders() {
  filterOrders();
}

function handchange (){
   fetchTableList();
}
function handlePay(orderId:any){
 router.push({ path: '/Layout/OrderDetail', query: { order_id: orderId } });
}


function orderTypeText(type: number) {
  switch (type) {
    case 1: return '服务员端';
    case 2: return '扫码点餐';
    case 3: return '触屏点餐';
    case 4: return '外卖平台';
    default: return '其他';
  }
}
function orderTypeText1(type: number) {
  switch (type) {
    case 1: return '待支付'
    case 2: return '已下单'
    case 3: return '已完成'
    case 4: return '已取消'
    case 5: return '挂单'
    case 6: return '预订'
    case 7: return '已并如其他订单'
    case 8: return '退款'
    default: return '其他';
  }
}
const showDetailsDialog = ref(false)
const currentOrder = ref<any>({})
function showOrderDetails(row: any) {
  currentOrder.value = row
  console.log("222",row)
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

onMounted(()=>{
  fetchStoreList();
  filterOrders();
})
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

async function fetchTableList() {
  await getStoreTables(Number(selectedStore.value) ).then((res:any)=> {
    if (res && res.response) {
      tableList.value = res.response.map((item: any) => ({
        id: item.id,
        name: item.name,
        status:item.status
      }));
    }
  });
}

const reservationDialogVisible = ref(false)
const reservationFormRef = ref()
const reservationForm = ref({
  store_id: '',
  table_id: '',
  reservation_name: '',
  reservation_phone: '',
  reservation_time: '',
  reservation_capacity: 1,
  remark: ''
})
const reservationTableList = ref<{ id: string | number, name: string,status:number }[]>([])

const reservationRules = {
  store_id: [{ required: true, message: '请选择门店', trigger: 'change' }],
  table_id: [{ required: true, message: '请选择桌台', trigger: 'change' }],
  reservation_name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  reservation_phone: [
    { required: true, message: '请输入电话', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  reservation_time: [{ required: true, message: '请选择时间', trigger: 'change' }],
  reservation_capacity: [
    { required: true, message: '请输入人数', trigger: 'blur' },
    { type: 'number', min: 1, message: '人数必须大于0', trigger: 'blur' }
  ]
}

// 打开弹窗
function ReservationOrders() {
  reservationDialogVisible.value = true;
  reservationForm.value = {
    store_id: '',
    table_id: '',
    reservation_name: '',
    reservation_phone: '',
    reservation_time: '',
    reservation_capacity: 1,
    remark: ''
  };
  reservationTableList.value = [];
}

// 门店切换时加载桌台
async function onReservationStoreChange(storeId: string | number) {
  if (!storeId) {
    reservationTableList.value = [];
    return;
  }
  await getStoreTables(Number(storeId)).then((res: any) => {
    if (res && res.response) {
      reservationTableList.value = res.response.map((item: any) => ({
        id: item.id,
        name: item.name,
        status:item.status
      }));
    }
  });
}

// 提交预定
async function submitReservation() {
  reservationFormRef.value.validate(async (valid: boolean) => {
    if (!valid) return;
 reservationForm.value.reservation_time = dayjs(reservationForm.value.reservation_time).format('YYYY-MM-DDTHH:mm:ss');
    // 组装数据
    const data = {
      ...reservationForm.value,
      reservation_id: 0, // 新增时为0
      status: 1 // 默认已确认
    };
    const res:any = await reserveOrder(data);
    if (res  && res.success) {
      ElMessage.success('预定成功');
      reservationDialogVisible.value = false;
      filterOrders(); // 可刷新订单列表
    } else {
      ElMessage.error(res?.message || '预定失败');
    }
  });
}

// 在 <script setup> 区域添加挂单方法
async function handlePending(row: any) {
  var res:any = await handOrder(row.order_id);
  if (!res || !res.success) {
    ElMessage.error(res?.message || '挂单失败');
    return;
  }
  ElMessage.success(`订单 ${row.order_no} 已挂单`);
  // 可刷新订单列表或更新状态
  filterOrders();
}

async function handRefundOrder(row: any) {
  var res:any = await RefundOrder(row.order_id);
  if (!res || !res.success) {
    ElMessage.error(res?.message || '退款失败');
    return;
  }
  ElMessage.success(`订单退款成功`);
  // 可刷新订单列表或更新状态
  filterOrders();
}
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