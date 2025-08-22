<template>
  <div class="inventory-container">
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店：">
        <el-select v-model="searchStore" placeholder="全部门店" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option v-for="s in storeList" :key="s.id" :label="s.name" :value="s.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="采购单号：">
        <el-input v-model="searchPoNo" placeholder="采购单号" clearable style="min-width:120px;" />
      </el-form-item>
      <el-form-item label="供应商：">
        <el-select v-model="searchSupplier" placeholder="全部供应商" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option v-for="s in supplierList" :key="s.supplier_id" :label="s.supplier_name" :value="s.supplier_id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="searchStatus" placeholder="全部状态" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="1" label="待确认" />
          <el-option value="2" label="已确认" />
          <el-option value="3" label="已到货" />
          <el-option value="4" label="已取消" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增采购单</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="filteredList" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="po_id" label="ID" align="center" />
      <el-table-column prop="po_no" label="采购单号" align="center" />
      <el-table-column prop="store_id" label="门店" align="center" />
      <el-table-column prop="supplier_id" label="供应商" align="center" />
      <el-table-column prop="order_time" label="下单时间" align="center" />
      <el-table-column prop="expect_arrival_time" label="预计到货" align="center" />
      <el-table-column prop="actual_arrival_time" label="实际到货" align="center" />
      <el-table-column prop="total_amount" label="总金额" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag>{{ poStatusMap[scope.row.status as unknown as keyof typeof poStatusMap] }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="operator_id" label="下单员工" align="center" />
      <el-table-column prop="remark" label="备注" align="center" />
      <el-table-column label="操作" align="center" width="180">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openDetailDialog(scope.row)">详情</el-button>
          <el-button type="text" class="table-btn-status" @click="cancelOrder(scope.row)">取消</el-button>
        </template>
      </el-table-column>
    </el-table>
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
    <el-dialog v-model="detailDialogVisible" title="采购单详情" width="500px" :close-on-click-modal="false">
      <el-form :model="detailForm" label-width="110px">
        <el-form-item label="采购单号">
          <el-input v-model="detailForm.po_no" disabled />
        </el-form-item>
        <el-form-item label="门店">
          <el-input v-model="detailForm.store_name" disabled />
        </el-form-item>
        <el-form-item label="供应商">
          <el-input v-model="detailForm.supplier_name" disabled />
        </el-form-item>
        <el-form-item label="下单时间">
          <el-input v-model="detailForm.order_time" disabled />
        </el-form-item>
        <el-form-item label="预计到货">
          <el-input v-model="detailForm.expect_arrival_time" disabled />
        </el-form-item>
        <el-form-item label="实际到货">
          <el-input v-model="detailForm.actual_arrival_time" disabled />
        </el-form-item>
        <el-form-item label="总金额">
          <el-input v-model="detailForm.total_amount" disabled />
        </el-form-item>
        <el-form-item label="状态">
          <el-input :value="poStatusMap[detailForm.status as unknown as keyof typeof poStatusMap]" disabled />
        </el-form-item>
        <el-form-item label="下单员工">
          <el-input v-model="detailForm.operator_name" disabled />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="detailForm.remark" type="textarea" disabled />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="addDialogVisible" title="新增采购单" width="500px" :close-on-click-modal="false">
      <el-form :model="addForm" label-width="110px">
        <el-form-item label="采购单号">
          <el-input v-model="addForm.po_no" placeholder="自动生成或手动填写" />
        </el-form-item>
        <el-form-item label="门店">
          <el-select v-model="addForm.store_id" placeholder="请选择门店">
            <el-option v-for="s in storeList" :key="s.id" :label="s.name" :value="s.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="供应商">
          <el-select v-model="addForm.supplier_id" placeholder="请选择供应商">
            <el-option v-for="s in supplierList" :key="s.supplier_id" :label="s.supplier_name" :value="s.supplier_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="预计到货">
          <el-date-picker v-model="addForm.expect_arrival_time" type="date" placeholder="选择日期" style="width:100%;" />
        </el-form-item>
        <el-form-item label="总金额">
          <el-input-number v-model="addForm.total_amount" :min="0" style="width:100%;" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="addForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAddConfirm">确认新增</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, computed } from 'vue';

const poStatusMap = {
  1: '待确认',
  2: '已确认',
  3: '已到货',
  4: '已取消'
};
const storeList = ref([
  { id: '1', name: '总部' },
  { id: '2', name: '分店A' },
  { id: '3', name: '分店B' }
]);
const supplierList = ref([
  { supplier_id: '201', supplier_name: '供应商A' },
  { supplier_id: '202', supplier_name: '供应商B' },
  { supplier_id: '203', supplier_name: '供应商C' }
]);
// const operatorList = ref([
//   { operator_id: '301', operator_name: '张三' },
//   { operator_id: '302', operator_name: '李四' }
// ]);
const purchaseOrderList = ref([
  {
    po_id: 'PO001',
    po_no: '20250825001',
    store_id: '1',
    store_name: '总部',
    supplier_id: '201',
    supplier_name: '供应商A',
    order_time: '2025-08-25 09:00',
    expect_arrival_time: '2025-08-28',
    actual_arrival_time: '',
    total_amount: 1200,
    status: 1,
    operator_id: '301',
    operator_name: '张三',
    remark: '急需采购'
  },
  {
    po_id: 'PO002',
    po_no: '20250825002',
    store_id: '2',
    store_name: '分店A',
    supplier_id: '202',
    supplier_name: '供应商B',
    order_time: '2025-08-24 15:30',
    expect_arrival_time: '2025-08-27',
    actual_arrival_time: '2025-08-27',
    total_amount: 800,
    status: 3,
    operator_id: '302',
    operator_name: '李四',
    remark: '常规采购'
  }
]);
const searchStore = ref('');
const searchPoNo = ref('');
const searchSupplier = ref('');
const searchStatus = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const detailDialogVisible = ref(false);
const detailForm = ref({
  po_no: '',
  store_name: '',
  supplier_name: '',
  order_time: '',
  expect_arrival_time: '',
  actual_arrival_time: '',
  total_amount: 0,
  status: 1,
  operator_name: '',
  remark: ''
});
const addDialogVisible = ref(false);
const addForm = ref({
  po_no: '',
  store_id: '',
  supplier_id: '',
  expect_arrival_time: '',
  total_amount: 0,
  remark: ''
});
const filteredList = computed(() => {
  let list = purchaseOrderList.value;
  if (searchStore.value) {
    list = list.filter(po => po.store_id === searchStore.value);
  }
  if (searchPoNo.value) {
    list = list.filter(po => po.po_no.includes(searchPoNo.value));
  }
  if (searchSupplier.value) {
    list = list.filter(po => po.supplier_id === searchSupplier.value);
  }
  if (searchStatus.value) {
    list = list.filter(po => String(po.status) === searchStatus.value);
  }
  total.value = list.length;
  const start = (currentPage.value - 1) * pageSize.value;
  return list.slice(start, start + pageSize.value);
});
function handleReset() {
  searchStore.value = '';
  searchPoNo.value = '';
  searchSupplier.value = '';
  searchStatus.value = '';
  currentPage.value = 1;
}
function handleQuery() {
  currentPage.value = 1;
}
function handleSizeChange(size: number) {
  pageSize.value = size;
  currentPage.value = 1;
}
function handlePageChange(page: number) {
  currentPage.value = page;
}
function openDetailDialog(row: any) {
  Object.assign(detailForm.value, row);
  detailDialogVisible.value = true;
}
function openAddDialog() {
  addForm.value.po_no = '';
  addForm.value.store_id = '';
  addForm.value.supplier_id = '';
  addForm.value.expect_arrival_time = '';
  addForm.value.total_amount = 0;
  addForm.value.remark = '';
  addDialogVisible.value = true;
}
function handleAddConfirm() {
  const store = storeList.value.find(s => s.id === addForm.value.store_id);
  const supplier = supplierList.value.find(s => s.supplier_id === addForm.value.supplier_id);
  purchaseOrderList.value.unshift({
    po_id: 'PO' + (purchaseOrderList.value.length + 1).toString().padStart(3, '0'),
    po_no: addForm.value.po_no || '自动生成',
    store_id: addForm.value.store_id,
    store_name: store ? store.name : '',
    supplier_id: addForm.value.supplier_id,
    supplier_name: supplier ? supplier.supplier_name : '',
    order_time: new Date().toLocaleString(),
    expect_arrival_time: addForm.value.expect_arrival_time,
    actual_arrival_time: '',
    total_amount: addForm.value.total_amount,
    status: 1,
    operator_id: '301',
    operator_name: '张三',
    remark: addForm.value.remark
  });
  addDialogVisible.value = false;
}
function cancelOrder(row: any) {
  row.status = 4;
}
</script>
<style scoped>
.inventory-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #e5e7eb;
  padding: 24px;
}
.filter-bar {
  margin-bottom: 18px;
}
.cancel-btn {
  margin-right: 8px;
}
.Btn-Save {
  background: #22A2B6;
  color: #fff;
}
.table-btn-edit {
  color: #22A2B6;
  font-weight: 500;
}
.table-btn-status {
  color: #F56C6C;
  font-weight: 500;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.el-dialog {
  border-radius: 8px;
}
.el-form-item__label {
  font-weight: 500;
}
.el-tag {
  font-size: 13px;
  padding: 0 12px;
}
</style>