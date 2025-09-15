<template>
  <div class="inventory-container">
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店：">
        <el-select v-model="searchStore" placeholder="全部门店" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option v-for="s in storeList" :key="s.id" :label="s.name" :value="s.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="原材料名称：">
        <el-input v-model="searchName" placeholder="请输入名称" clearable style="min-width:120px;" />
      </el-form-item>
      <el-form-item label="分类：">
        <el-select v-model="searchCategory" placeholder="全部分类" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="生鲜" label="生鲜" />
          <el-option value="调料" label="调料" />
          <el-option value="粮油" label="粮油" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="searchStatus" placeholder="全部状态" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="1" label="启用" />
          <el-option value="0" label="禁用" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增原材料</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="rawMaterialList" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <!-- <el-table-column prop="material_id" label="ID" align="center" /> -->
      <el-table-column prop="material_name" label="名称" align="center" />
      <el-table-column prop="category" label="分类" align="center" />
      <el-table-column prop="unit" label="单位" align="center" />
      <el-table-column prop="purchase_price" label="采购单价" align="center" />
      <el-table-column prop="warning_threshold" label="预警阈值" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">{{ scope.row.status === 1 ? '启用' : '禁用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="180">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button type="text" class="table-btn-status" @click="toggleStatus(scope.row)">{{ scope.row.status === 1 ? '禁用' : '启用' }}</el-button>
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
    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="showDialog" :title="dialogTitle" width="500">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店">
        <el-select v-model="form.store_id" placeholder="门店特有请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="原材料名称" required>
          <el-input v-model="form.material_name" placeholder="请输入原材料名称" />
        </el-form-item>
        <el-form-item label="分类" required>
          <el-select v-model="form.category" placeholder="请选择分类">
            <el-option value="生鲜" label="生鲜" />
            <el-option value="调料" label="调料" />
            <el-option value="粮油" label="粮油" />
          </el-select>
        </el-form-item>
        <el-form-item label="单位" required>
          <el-input v-model="form.unit" placeholder="如kg/个/升" />
        </el-form-item>
        <el-form-item label="采购单价" required>
          <el-input v-model.number="form.purchase_price" type="number" placeholder="请输入采购单价" />
        </el-form-item>
        <el-form-item label="预警阈值"required>
          <el-input v-model.number="form.warning_threshold" type="number" placeholder="请输入预警阈值" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option value="1" label="启用" />
            <el-option value="0" label="禁用" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleSave" class="Btn-Save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { getStoreList } from '../../../../api/login';
import { getRawMaterialList, addRawMaterial, updateRawMaterial, changeRawMaterialStatus } from '../../../../api/RawMaterial';

interface Store { id: string; name: string; }
interface RawMaterial {
  material_id: number;
  material_name: string;
  category: string;
  unit: string;
  purchase_price: number;
  warning_threshold: number;
  status: number;
  store_id: string;
}
const storeList = ref<Store[]>([]);
const rawMaterialList = ref<RawMaterial[]>([]);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);
const showDialog = ref(false);
const dialogTitle = ref('新增原材料');
const form = ref<RawMaterial | any>({
  material_id: 0,
  material_name: '',
  category: '',
  unit: '',
  purchase_price: 0,
  warning_threshold: 0,
  status: 1,
  store_id: ''
});
const searchStore = ref('');
const searchName = ref('');
const searchCategory = ref('');
const searchStatus = ref('');
async function handleQuery() {
  const data:any = await getRawMaterialList(
    currentPage.value,
    pageSize.value,
    searchStore.value,
    searchName.value,
    searchCategory.value,
    searchStatus.value
  );
  if (data.success && data.response) {
    rawMaterialList.value = data.response.map((item: any) => ({
      material_id: item.material_id,
      material_name: item.material_name,
      category: item.category,
      unit: item.unit,
      purchase_price: item.purchase_price,
      warning_threshold: item.warning_threshold,
      status: item.status,
      store_id: item.store_id?.toString() || ''
    }));
    total.value = data.count || data.response.length;
  } else {
    rawMaterialList.value = [];
    total.value = 0;
  }
}
function handleReset() {
  searchStore.value = '';
  searchName.value = '';
  searchCategory.value = '';
  searchStatus.value = '';
  handleQuery();
}
function handleSizeChange(val: number) {
  pageSize.value = val;
  handleQuery();
}
function handlePageChange(val: number) {
  currentPage.value = val;
  handleQuery();
}
function openAddDialog() {
  dialogTitle.value = '新增原材料';
  form.value = {
    material_id: 0,
    material_name: '',
    category: '',
    unit: '',
    purchase_price: 0,
    warning_threshold: 0,
    status: 1,
    store_id: ''
  };
  showDialog.value = true;
}
function openEditDialog(row: RawMaterial) {
  dialogTitle.value = '编辑原材料';
  form.value = { ...row };
  showDialog.value = true;
}
async function handleSave() {
  if (!form.value.material_name || !form.value.category || !form.value.unit) {
    ElMessage.warning('请填写必填项');
    return;
  }
  let res:any;
  if (form.value.material_id === 0) {
    form.value.store_id = form.value.store_id || 0; // 确保新增时ID为0
    res = await addRawMaterial(form.value);
    if (res.success) {
      ElMessage.success('新增成功');
      showDialog.value = false;
      handleQuery();
    } else {
      ElMessage.error(res.message || '新增失败');
    }
  } else {
    res = await updateRawMaterial(form.value);
    if (res.success) {
      ElMessage.success('编辑成功');
      showDialog.value = false;
      handleQuery();
    } else {
      ElMessage.error(res.message || '编辑失败');
    }
  }
}
async function toggleStatus(row: RawMaterial) {
  const newStatus = row.status === 1 ? 0 : 1;
  const res:any = await changeRawMaterialStatus(row.material_id, newStatus);
  if (res.success) {
    ElMessage.success(`已${newStatus === 1 ? '启用' : '禁用'}`);
    handleQuery();
  } else {
    ElMessage.error(res.message || '操作失败');
  }
}
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
.inventory-container {
  padding: 20px;
  background-color: #fff;
  /* min-height: 100vh; */
}
.filter-bar {
  /* margin-bottom: 20px; */
  margin-top: -20px;
  background-color: #fff;
  padding: 15px;
  border-radius: 5px;
  /* box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); */
}
.custom-table {
  border-radius: 5px;
  overflow: hidden;
}
.custom-table th {
  background-color: #f8f9fa;
  color: #606266;
}
.custom-table td {
  background-color: #fff;
  color: #333;
}
.custom-table .table-btn-edit {
  color: #409eff;
}
.custom-table .table-btn-status {
  color: #67c23a;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.cancel-btn {
  background-color: #f56c6c;
  color: #fff;
}
.Btn-Save {
  background-color: #22A2B6;
  color: #fff;
}
</style>