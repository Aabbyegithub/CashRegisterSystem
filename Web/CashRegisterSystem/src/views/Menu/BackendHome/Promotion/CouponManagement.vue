<template>
  <div class="coupon-management-container">
    <!-- 筛选区 -->
    <!-- <el-card class="filter-card"> -->
      <el-form :inline="true" :model="filterForm" class="filter-form">
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
        <el-table-column prop="name" label="优惠券名称" min-width="120"   align="center"/>
        <el-table-column prop="type" label="类型" min-width="100"  align="center"/>
        <el-table-column prop="amount" label="面值/折扣" min-width="100"  align="center"/>
        <el-table-column prop="minAmount" label="最低消费" min-width="100"  align="center"/>
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
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';

// 筛选表单
const filterForm = reactive({
  name: '',
  type: '',
  status: '',
});

// 优惠券列表模拟数据
interface Coupon {
  id: number;
  name: string;
  type: string;
  amount: string;
  minAmount: string;
  total: number;
  received: number;
  used: number;
  validTime: string;
  status: string;
}
const couponList = ref<Coupon[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);

// 弹窗相关
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogFormRef = ref<FormInstance>();
const dialogForm = reactive({
  id: 0,
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
const statusTagType = (status: string) => {
  switch (status) {
    case '未开始': return 'info';
    case '进行中': return 'success';
    case '已结束': return 'warning';
    default: return '';
  }
};

// 查询、重置
const handleQuery = () => {
  // 模拟筛选
  let list = mockCoupons.filter(c => {
    return (
      (!filterForm.name || c.name.includes(filterForm.name)) &&
      (!filterForm.type || c.type === filterForm.type) &&
      (!filterForm.status || c.status === filterForm.status)
    );
  });
  total.value = list.length;
  couponList.value = list.slice((currentPage.value-1)*pageSize.value, currentPage.value*pageSize.value);
};
const handleReset = () => {
  filterForm.name = '';
  filterForm.type = '';
  filterForm.status = '';
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
const openDialog = (type: 'add' | 'edit', row?: Coupon) => {
  dialogTitle.value = type === 'add' ? '新增优惠券' : '编辑优惠券';
  dialogVisible.value = true;
  if (type === 'edit' && row) {
    Object.assign(dialogForm, row);
  } else {
    Object.assign(dialogForm, {
      id: 0,
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
const handleDialogConfirm = () => {
  dialogFormRef.value?.validate((valid) => {
    if (valid) {
      if (dialogForm.id) {
        // 编辑
        const idx = mockCoupons.findIndex(c => c.id === dialogForm.id);
        if (idx > -1) Object.assign(mockCoupons[idx], { ...dialogForm });
        ElMessage.success('编辑成功');
      } else {
        // 新增
        dialogForm.id = Date.now();
        mockCoupons.unshift({ ...dialogForm, received: 0, used: 0 });
        ElMessage.success('新增成功');
      }
      dialogVisible.value = false;
      handleQuery();
    }
  });
};
const handleDelete = (row: Coupon) => {
  ElMessageBox.confirm('确定要删除该优惠券吗？', '提示', { type: 'warning' })
    .then(() => {
      const idx = mockCoupons.findIndex(c => c.id === row.id);
      if (idx > -1) mockCoupons.splice(idx, 1);
      ElMessage.success('删除成功');
      handleQuery();
    });
};

// 模拟数据
const mockCoupons: Coupon[] = [
  {
    id: 1,
    name: '满100减20',
    type: '满减券',
    amount: '20',
    minAmount: '100',
    total: 1000,
    received: 800,
    used: 600,
    validTime: '2025-08-01 ~ 2025-08-31',
    status: '进行中',
  },
  {
    id: 2,
    name: '8折优惠券',
    type: '折扣券',
    amount: '8折',
    minAmount: '50',
    total: 500,
    received: 300,
    used: 200,
    validTime: '2025-09-01 ~ 2025-09-30',
    status: '未开始',
  },
  {
    id: 3,
    name: '50元代金券',
    type: '代金券',
    amount: '50',
    minAmount: '200',
    total: 200,
    received: 180,
    used: 150,
    validTime: '2025-07-01 ~ 2025-07-31',
    status: '已结束',
  },
];

onMounted(() => {
  handleQuery();
});
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
