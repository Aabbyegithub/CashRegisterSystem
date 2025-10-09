<template>
  <div class="coupon-management-container">
    <!-- 筛选区 -->
    <!-- <el-card class="filter-card"> -->
      <el-form :inline="true" :model="filterForm" class="filter-form">
      <el-form-item label="门店">
          <el-select v-model="selectedStore" class="store-select" placeholder="请选择门店"style="min-width: 120px;">
            <el-option value="">全部门店</el-option>
            <el-option v-for="store in storeList" :key="store.id" :value="store.id":label="store.name">{{ store.name }}</el-option>
          </el-select>
      </el-form-item>
        <el-form-item label="优惠券名称">
          <el-input v-model="filterForm.name" placeholder="请输入优惠券名称" clearable />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="filterForm.type" placeholder="请选择类型" clearable style="width: 150px;">
            <el-option label="全部" value="" />
            <el-option label="满减券" value="满减券" />
            <el-option label="折扣券" value="折扣券" />
            <el-option label="代金券" value="代金券" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filterForm.status" placeholder="请选择状态" clearable style="width: 150px;">
            <el-option label="全部" value="" />
            <el-option label="未开始" value="未开始" />
            <el-option label="进行中" value="进行中" />
            <el-option label="已结束" value="已结束" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="margin-left:auto;">
          <el-button type="success" @click="openDialog('add')">新增优惠券</el-button>
        </el-form-item>
      </el-form>
    <!-- </el-card> -->

    <!-- 表格区 -->
    <div class="table-card">
      <el-table :data="couponList" border stripe style="width: 100%;height: 65vh;">
        <el-table-column label="门店名称" prop="store_id" align="center">
            <template #default="scope">
             {{ storeList.find(cat => cat.id === scope.row.store_id)?.name || '' }}
            </template>
        </el-table-column>
        <el-table-column prop="coupon_name" label="优惠券名称" min-width="120"   align="center"/>
        <el-table-column prop="type" label="类型" min-width="100"  align="center"/>
        <el-table-column prop="value" label="面值/折扣" min-width="100"  align="center"/>
        <el-table-column prop="min_consumption" label="最低消费" min-width="100"  align="center"/>
        <el-table-column prop="total" label="发放数量" min-width="100"  align="center"/>
        <el-table-column prop="received" label="已领取" min-width="100"  align="center"/>
        <el-table-column prop="used" label="已使用" min-width="100"  align="center"/>
        <el-table-column prop="validTime" label="有效期" min-width="180"  align="center"/>
        <el-table-column prop="status" label="状态" min-width="100"  align="center">
          <template #default="scope">
            <el-tag :type="statusTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="180"  align="center">
          <template #default="scope">
            <el-button type="primary" size="small" @click="openDialog('edit', scope.row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination
          layout="prev, pager, next, ->, sizes, jumper"
          :total="total"
          :page-size="pageSize"
          :current-page="currentPage"
          :page-sizes="[10, 20, 30, 50]"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" :close-on-click-modal="false">
      <el-form :model="dialogForm" :rules="dialogRules" ref="dialogFormRef" label-width="100px">
        <el-form-item label="门店">
          <el-select v-model="dialogForm.store_id" placeholder="请选择门店">
              <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="优惠券名称" prop="name">
          <el-input v-model="dialogForm.name" placeholder="请输入名称" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="dialogForm.type" placeholder="请选择类型">
            <el-option label="满减券" value="满减券" />
            <el-option label="折扣券" value="折扣券" />
            <el-option label="代金券" value="代金券" />
          </el-select>
        </el-form-item>
        <el-form-item label="面值/折扣" prop="amount">
          <el-input v-model="dialogForm.amount" placeholder="请输入面值或折扣" />
        </el-form-item>
        <el-form-item label="最低消费" prop="minAmount">
          <el-input v-model="dialogForm.minAmount" placeholder="请输入最低消费金额" />
        </el-form-item>
        <el-form-item label="发放数量" prop="total">
          <el-input v-model="dialogForm.total" placeholder="请输入发放数量" />
        </el-form-item>
        <el-form-item label="有效期" prop="validTime">
          <el-date-picker v-model="dialogForm.validTime" type="daterange" start-placeholder="开始日期" end-placeholder="结束日期" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="dialogForm.status" placeholder="请选择状态">
            <el-option label="未开始" value="未开始" />
            <el-option label="进行中" value="进行中" />
            <el-option label="已结束" value="已结束" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleDialogConfirm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { dayjs, ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { getStoreList } from '../../../../api/login';
import { getCouponList, getCouponById, addCoupon, updateCoupon, deleteCoupon } from '../../../../api/Coupon';

// 筛选表单
const filterForm = reactive({
  name: '',
  type: '',
  status: '',
});

// 优惠券列表
interface Coupon {
  coupon_id: number;
  store_id: number;
  coupon_no: string;
  coupon_name: string;
  type: string | number;
  value: number;
  min_consumption: number;
  valid_start: string;
  valid_end: string;
  status: string | number;
  applicable_dishes: string;
  total?: number;
  received?: number;
  used?: number;
}
const couponList = ref<Coupon[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const selectedStore = ref('');
const storeList = ref<{ id: string; name: string }[]>([]);
// 弹窗相关
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogFormRef = ref<FormInstance>();
const dialogForm = reactive({
  coupon_id: 0,
  store_id: '',
  coupon_no: '',
  name: '',
  type: '',
  amount: '',
  minAmount: '',
  total: 0,
  validTime: '',
  status: '',
});
const dialogRules = reactive<FormRules>({
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
  amount: [{ required: true, message: '请输入面值/折扣', trigger: 'blur' }],
  minAmount: [{ required: true, message: '请输入最低消费', trigger: 'blur' }],
  total: [{ required: true, message: '请输入发放数量', trigger: 'blur' }],
  validTime: [{ required: true, message: '请选择有效期', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
});

// 状态标签类型
const statusTagType = (status: string | number) => {
  switch (status) {
    case 0:
    case '未开始': return 'info';
    case 1:
    case '进行中': return 'success';
    case 2:
    case '已结束': return 'warning';
    default: return '';
  }
};

// 查询、重置
const handleQuery = async () => {
  const typeMap: any = { '满减券': 0, '折扣券': 1, '代金券': 2, '': '' };
  const statusMap: any = { '未开始': 0, '进行中': 1, '已结束': 2, '': '' };
  const res = await getCouponList(
    currentPage.value,
    pageSize.value,
    selectedStore.value,
    filterForm.name,
    typeMap[filterForm.type],
    statusMap[filterForm.status]
  );
  const data:any = res
  if (data.success && data.response) {
    couponList.value = data.response.map((item: any) => ({
      coupon_id: item.coupon_id,
      store_id: item.store_id,
      coupon_no: item.coupon_no,
      coupon_name: item.coupon_name,
      type: ['满减券', '折扣券', '代金券'][item.type] ?? item.type,
      value: item.value,
      min_consumption: item.min_consumption,
      valid_start: dayjs(item.valid_start).format('YYYY-MM-DD'),
      valid_end: dayjs(item.valid_end).format('YYYY-MM-DD'),
      validTime: `${dayjs(item.valid_start).format('YYYY-MM-DD')} ~ ${dayjs(item.valid_end).format('YYYY-MM-DD')}`,
      status: ['未开始', '进行中', '已结束'][item.status] ?? item.status,
      applicable_dishes: item.applicable_dishes,
      total: item.total,
      received: item.received ?? 0,
      used: item.used ?? 0,
    }));
    total.value = data.count || data.response.length;
  } else {
    couponList.value = [];
    total.value = 0;
  }
};
const handleReset = () => {
  filterForm.name = '';
  filterForm.type = '';
  filterForm.status = '';
  selectedStore.value = '';
  currentPage.value = 1;
  handleQuery();
};

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  handleQuery();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  handleQuery();
};

// 新增/编辑弹窗
const openDialog = async (type: 'add' | 'edit', row?: Coupon) => {
  dialogTitle.value = type === 'add' ? '新增优惠券' : '编辑优惠券';
  dialogVisible.value = true;
  if (type === 'edit' && row) {
    // 获取详情
    const res:any = await getCouponById(row.coupon_id);
    const item = res.response || row;
    Object.assign(dialogForm, {
      coupon_id: item.coupon_id,
      store_id: item.store_id,
      coupon_no: item.coupon_no,
      name: item.coupon_name,
      type: ['满减券', '折扣券', '代金券'][item.type] ?? item.type,
      amount: item.value,
      minAmount: item.min_consumption,
      total: item.total ?? 0,
      validTime: [item.valid_start?.slice(0, 10), item.valid_end?.slice(0, 10)],
      status: ['未开始', '进行中', '已结束'][item.status] ?? item.status,
    });
  } else {
    Object.assign(dialogForm, {
      coupon_id: 0,
      store_id:  '',
      coupon_no: '',
      name: '',
      type: '',
      amount: '',
      minAmount: '',
      total: 0,
      validTime: '',
      status: '',
    });
  }
};
const handleDialogConfirm = async () => {
  dialogFormRef.value?.validate(async (valid) => {
    if (valid) {
      const typeMap: any = { '满减券': 0, '折扣券': 1, '代金券': 2 };
      const statusMap: any = { '未开始': 0, '进行中': 1, '已结束': 2 };
      const payload = {
        coupon_id: dialogForm.coupon_id,
        store_id: dialogForm.store_id  || 0,
        coupon_no: dialogForm.coupon_no || '',
        coupon_name: dialogForm.name,
        type: typeMap[dialogForm.type] ?? '',
        value: Number(dialogForm.amount),
        min_consumption: Number(dialogForm.minAmount),
        valid_start: Array.isArray(dialogForm.validTime) ? dayjs(dialogForm.validTime[0]).format('YYYY-MM-DDT00:00:00') : '',
        valid_end: Array.isArray(dialogForm.validTime) ? dayjs(dialogForm.validTime[1]).add(1, 'day').format('YYYY-MM-DDT00:00:00') : '',
        status: statusMap[dialogForm.status] ?? '',
        applicable_dishes: '',
        total:dialogForm.total,

      };
      let res:any;
      if (dialogForm.coupon_id) {
        res = await updateCoupon(payload);
        if (res?.success) ElMessage.success('编辑成功');
      } else {
        res = await addCoupon(payload);
        if (res?.success) ElMessage.success('新增成功');
      }
      dialogVisible.value = false;
      handleQuery();
    }
  });
};
const handleDelete = async (row: Coupon) => {
  ElMessageBox.confirm('确定要删除该优惠券吗？', '提示', { type: 'warning' })
    .then(async () => {
      const res:any = await deleteCoupon(row.coupon_id);
      if (res?.success) ElMessage.success('删除成功');
      handleQuery();
    });
};

// 初始化
onMounted(() => {
  handleQuery();
  fetchStoreList();
});

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
.coupon-management-container {
  padding: 24px;
  background: #fff;
height: 100%;
}
.filter-card {
  margin-bottom: 18px;
  /* box-shadow: 0 2px 8px 0 rgba(0,0,0,0.04); */
}
.filter-form {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  margin-bottom: 18px;
}
.table-card {
      background: #fff;
  border-radius: 8px;
  margin-bottom: 18px;
  /* box-shadow: 0 2px 8px 0 rgba(0,0,0,0.04); */
}
.pagination-bar {
  display: flex;
  justify-content: flex-end;
  padding: 16px 0 0 0;
}
</style>
