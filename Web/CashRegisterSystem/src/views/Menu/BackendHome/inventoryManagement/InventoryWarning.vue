<template>
  <div class="inventory-container">
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店：">
        <el-select v-model="searchStore" placeholder="全部门店" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option v-for="s in storeList" :key="s.id" :label="s.name" :value="s.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="原材料：">
        <el-select v-model="searchMaterial" placeholder="全部原材料" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_id" />
        </el-select>
      </el-form-item>
      <el-form-item label="分类：">
        <el-select v-model="searchCategory" placeholder="全部分类" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="生鲜" label="生鲜" />
          <el-option value="调料" label="调料" />
          <el-option value="粮油" label="粮油" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="filteredList" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="material_name" label="名称" align="center" />
      <el-table-column prop="category" label="分类" align="center" />
      <el-table-column prop="unit" label="单位" align="center" />
      <el-table-column prop="quantity" label="当前库存" align="center" />
      <el-table-column prop="in_quantity" label="总入库数量" align="center" />
      <el-table-column prop="out_quantity" label="出库数量" align="center" />
      <el-table-column prop="warning_threshold" label="预警阈值" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag :type="scope.row.quantity < scope.row.warning_threshold ? 'danger' : 'success'">
            {{ scope.row.quantity < scope.row.warning_threshold ? '预警' : '正常' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="120">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openPurchaseDialog(scope.row)">采购</el-button>
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
    <el-dialog v-model="purchaseDialogVisible" title="采购原材料" width="400px" :close-on-click-modal="false">
      <el-form :model="purchaseForm" label-width="90px">
        <el-form-item label="原材料">
          <el-input v-model="purchaseForm.material_name" disabled />
        </el-form-item>
        <el-form-item label="采购数量">
          <el-input-number v-model="purchaseForm.purchase_quantity" :min="1" :max="99999" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="purchaseForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="purchaseDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handlePurchaseConfirm">确认采购</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { getStoreList } from '../../../../api/login';
import { getAllRawMaterialList, getInventoryAlertList, PurchaseMaterial } from '../../../../api/RawMaterial';
import { ElMessage } from 'element-plus';
// 模拟门店、原材料、分类数据
const storeList = ref<any[]>([]);
const materialList = ref([
  { material_id: '101', material_name: '鸡肉', category: '生鲜', unit: 'kg', quantity: 8, warning_threshold: 10 },
  { material_id: '102', material_name: '食用油', category: '粮油', unit: 'L', quantity: 25, warning_threshold: 20 },
  { material_id: '103', material_name: '盐', category: '调料', unit: 'kg', quantity: 3, warning_threshold: 5 },
  { material_id: '104', material_name: '大米', category: '粮油', unit: 'kg', quantity: 50, warning_threshold: 30 }
]);

// 筛选条件
const searchStore = ref('');
const searchMaterial = ref('');
const searchCategory = ref('');

// 分页
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 采购弹窗
const purchaseDialogVisible = ref(false);
const purchaseForm = ref({
  material_id: '',
  material_name: '',
  purchase_quantity: 1,
  remark: ''
});
const filteredList = ref<any[]>([]);
async function handleQuery() {
  const data:any = await getInventoryAlertList(
    currentPage.value,
    pageSize.value,
    searchStore.value,
    searchMaterial.value,
    searchCategory.value,
  );
  if (data.success && data.response) {
    filteredList.value = data.response.map((item: any) => ({
      material_id: item.material_id,
      material_name: item.material_name,
      category: item.category,
      unit: item.unit,
      purchase_price: item.purchase_price,
      warning_threshold: item.warning_threshold,
      quantity: item.quantity,
      in_quantity: item.in_quantity,
      out_quantity: item.out_quantity,
      status: item.quantity < item.warning_threshold ? '预警' : '正常',
      store_id: item.store_id?.toString() || ''
    }));
    total.value = data.count || data.response.length;
  } else {
    filteredList.value = [];
    total.value = 0;
  }
}

function handleReset() {
  searchStore.value = '';
  searchMaterial.value = '';
  searchCategory.value = '';
  currentPage.value = 1;
}
function handleSizeChange(size: number) {
  pageSize.value = size;
  currentPage.value = 1;
}
function handlePageChange(page: number) {
  currentPage.value = page;
}

function openPurchaseDialog(row: any) {
  purchaseForm.value.material_id = row.material_id;
  purchaseForm.value.material_name = row.material_name;
  purchaseForm.value.purchase_quantity = 1;
  purchaseForm.value.remark = '';
  purchaseDialogVisible.value = true;
}
async function handlePurchaseConfirm() {
  // 模拟采购逻辑，可扩展为接口调用
  purchaseDialogVisible.value = false;
 var res:any = await PurchaseMaterial(purchaseForm.value.material_id, purchaseForm.value.purchase_quantity,purchaseForm.value.remark);
 if(res && res.success){
  ElMessage.success('采购单申请成功');
  handleQuery();
 }
}

onMounted(() => {
  fetchStoreList();
  handleQuery();
  fetchmaterialList();
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

async function fetchmaterialList() {
  await getAllRawMaterialList().then((res:any)=> {
    if (res && res.response) {
      materialList.value = res.response.map((item: any) => ({
        material_id: item.material_id,
        material_name: item.material_name,
        unit: item.unit
      }));
    }
  });
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