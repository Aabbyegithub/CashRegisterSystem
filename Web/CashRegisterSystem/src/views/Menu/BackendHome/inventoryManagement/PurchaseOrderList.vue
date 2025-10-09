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
      <el-table-column prop="po_no" label="采购单号" align="center" />
           <el-table-column label="门店名称" prop="store_id" align="center">
            <template #default="scope">
             {{ storeList.find(cat => cat.id === scope.row.store_id)?.name || '' }}
            </template>
        </el-table-column>
      <el-table-column prop="supplier_id" label="供应商" align="center" />
      <el-table-column prop="materialname" label="采购物品" align="center" />
      <el-table-column prop="quantity" label="采购数量" align="center" />
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
          <el-select v-model="detailForm.supplier_id" placeholder="请选择供应商">
            <el-option v-for="s in supplierList" :key="s.supplier_id" :label="s.supplier_name" :value="s.supplier_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="采购物品">
          <el-input v-model="detailForm.materialname" disabled />
        </el-form-item>
        <el-form-item label="采购数量">
          <el-input v-model="detailForm.quantity" disabled />
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
        <el-button v-if="detailForm.status == 1" @click="handelSave(detailForm)">确认</el-button>
        <el-button v-if="detailForm.status == 2" @click="handleArrived(detailForm)">到货</el-button>
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
        <el-form-item label="采购物品">
          <el-select v-model="addForm.materialname" filterable allow-create default-first-option placeholder="请选择或输入采购物品">
            <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_name" />
          </el-select>
        </el-form-item>
        <el-form-item label="采购物品">
          <el-input-number v-model="addForm.quantity" :min="1" style="width:100%;" />
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
import { ref, computed, onMounted } from 'vue';
import { getStoreList } from '../../../../api/login';
import { getPurchaseOrderList, getPurchaseOrderDetail, addPurchaseOrder, cancelPurchaseOrder, ArrivedPurchaseOrder, SavePurchaseOrder } from '../../../../api/PurchaseOrder';
import { getAllRawMaterialList } from '../../../../api/RawMaterial';
import { dayjs, ElMessage } from 'element-plus';
import { getAllSupplierList } from '../../../../api/supplier';

const poStatusMap = {
  1: '待确认',
  2: '已确认',
  3: '已到货',
  4: '已取消'
};
const storeList = ref<any[]>([]);
const supplierList = ref<any[]>([]);
const purchaseOrderList = ref<any[]>([]);
const materialList = ref<any[]>([]);
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
  remark: '',
  quantity:1,
  materialname:'',
  supplier_id:''
});
const addDialogVisible = ref(false);
const addForm = ref({
  po_no: '',
  store_id: '',
  supplier_id: '',
  materialname: '',
  expect_arrival_time: '',
  total_amount: 0,
  remark: '',
  quantity:1
});
const filteredList = computed(() => purchaseOrderList.value);

function handleReset() {
  searchStore.value = '';
  searchPoNo.value = '';
  searchSupplier.value = '';
  searchStatus.value = '';
  currentPage.value = 1;
  handleQuery();
}
async function handleQuery() {
  const res:any = await getPurchaseOrderList(
    currentPage.value,
    pageSize.value,
    searchStore.value,
    searchPoNo.value,
    searchSupplier.value,
    searchStatus.value
  );
  if (res?.success && res.response) {
    purchaseOrderList.value = res.response.map((item: any) => ({
      ...item,
      operator_id:item.staff?.name,
      store_name: storeList.value.find(s => s.id == item.store_id)?.name || '',
      supplier_name: supplierList.value.find(s => s.supplier_id == item.supplier_id)?.supplier_name || '',
      order_time: item.order_time?.replace('T', ' ').slice(0, 16),
      expect_arrival_time:dayjs(item.expect_arrival_time).format('YYYY-MM-DD HH:mm'),
      actual_arrival_time:item.actual_arrival_time ? dayjs(item.actual_arrival_time).format('YYYY-MM-DD HH:mm ') : '',
    }));
    total.value = res.count || res.response.length;
  } else {
    purchaseOrderList.value = [];
    total.value = 0;
  }
}
function handleSizeChange(size: number) {
  pageSize.value = size;
  currentPage.value = 1;
  handleQuery();
}
function handlePageChange(page: number) {
  currentPage.value = page;
  handleQuery();
}
async function openDetailDialog(row: any) {
  const res:any = await getPurchaseOrderDetail(row.po_id);
  if (res?.success && res.response) {
    const item = res.response;
    detailForm.value = {
      ...item,
      store_name: storeList.value.find(s => s.id == item.store_id)?.name || '',
      supplier_name: supplierList.value.find(s => s.supplier_id == item.supplier_id)?.supplier_name || '',
      order_time: item.order_time?.replace('T', ' ').slice(0, 16),
      expect_arrival_time: item.expect_arrival_time?.replace('T', ' ').slice(0, 10),
      actual_arrival_time: item.actual_arrival_time?.replace('T', ' ').slice(0, 10),
      operator_name: item.operator_id
    };
    detailDialogVisible.value = true;
  } else {
    ElMessage.error(res?.message || '获取详情失败');
  }
}
function openAddDialog() {
  addForm.value.po_no = '';
  addForm.value.store_id = '';
  addForm.value.supplier_id = '';
  addForm.value.materialname = '';
  addForm.value.expect_arrival_time = '';
  addForm.value.total_amount = 0;
  addForm.value.remark = '';
  addForm.value.quantity =1;
  addDialogVisible.value = true;
}
async function handleAddConfirm() {
  if (!addForm.value.store_id || !addForm.value.supplier_id || !addForm.value.expect_arrival_time) {
    ElMessage.warning('请填写完整信息');
    return;
  }
  const payload = {
    ...addForm.value,
    po_id: 0,
    order_time: new Date().toISOString(),
    actual_arrival_time: '',
    status: 1,
  };
  const res:any = await addPurchaseOrder(payload);
  if (res?.success) {
    ElMessage.success('新增成功');
    addDialogVisible.value = false;
    handleQuery();
  } else {
    ElMessage.error(res?.message || '新增失败');
  }
}
async function cancelOrder(row: any) {
  const res:any = await cancelPurchaseOrder(row.po_id);
  if (res?.success) {
    ElMessage.success('已取消');
    handleQuery();
  } else {
    ElMessage.error(res?.message || '取消失败');
  }
}

async function handelSave(row: any) {
  const res:any = await getPurchaseOrderDetail(row.po_id);
  if (res?.success && res.response) {
    const item = res.response;
    if(item.status != 1){
      ElMessage.warning('当前状态不可操作');
      return;
    }
    const updateRes:any = await SavePurchaseOrder(row.po_id,row.supplier_id);
    if (updateRes?.success) {
      ElMessage.success('采购单已确认');
      detailDialogVisible.value = false;
      handleQuery();
    } else {
      ElMessage.error(updateRes?.message || '操作失败');
    }
  } else {
    ElMessage.error(res?.message || '获取详情失败');
  }
}

async function handleArrived(row: any) {
  const res:any = await getPurchaseOrderDetail(row.po_id);
  if (res?.success && res.response) {
    const item = res.response;
    if(item.status != 2){
      ElMessage.warning('当前状态不可操作');
      return;
    }
    const updateRes:any = await ArrivedPurchaseOrder(row.po_id);
    if (updateRes?.success) {
      ElMessage.success('采购单已到货');
      detailDialogVisible.value = false;
      handleQuery();
    } else {
      ElMessage.error(updateRes?.message || '操作失败');
    }
  } else {
    ElMessage.error(res?.message || '获取详情失败');
  }
}


onMounted(() => {
  fetchStoreList();
  fetchSupplierList();
  fetchMaterialList();
  handleQuery();
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

// TODO: fetchSupplierList 需对接供应商接口
async function fetchSupplierList() {

    await getAllSupplierList().then((res:any)=> {
    if (res && res.response) {
      supplierList.value = res.response.map((item: any) => ({
        supplier_id: item.supplier_id,
        supplier_name: item.supplier_name
      }));
    }
  });
}
async function fetchMaterialList() {
  const res:any = await getAllRawMaterialList();
  if (res?.response) {
    materialList.value = res.response;
  } else {
    materialList.value = [];
  }
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