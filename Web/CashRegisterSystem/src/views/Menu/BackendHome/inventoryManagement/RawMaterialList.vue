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
    <el-table :data="filteredList" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="material_id" label="ID" align="center" />
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
    <div v-if="filteredList.length === 0" class="empty-row">
      <el-empty description="暂无原材料记录" />
    </div>
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
        <el-form-item label="原材料名称">
          <el-input v-model="form.material_name" placeholder="请输入原材料名称" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.category" placeholder="请选择分类">
            <el-option value="生鲜" label="生鲜" />
            <el-option value="调料" label="调料" />
            <el-option value="粮油" label="粮油" />
          </el-select>
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="form.unit" placeholder="如kg/个/升" />
        </el-form-item>
        <el-form-item label="采购单价">
          <el-input v-model.number="form.purchase_price" type="number" placeholder="请输入采购单价" />
        </el-form-item>
        <el-form-item label="预警阈值">
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
import { ref, computed } from 'vue';
import { ElMessage } from 'element-plus';

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
const storeList = ref<Store[]>([
  { id: '1', name: '旗舰店' },
  { id: '2', name: '分店A' }
]);
const rawMaterialList = ref<RawMaterial[]>([
  { material_id: 1, material_name: '鸡肉', category: '生鲜', unit: 'kg', purchase_price: 20, warning_threshold: 10, status: 1, store_id: '1' },
  { material_id: 2, material_name: '食盐', category: '调料', unit: 'kg', purchase_price: 2, warning_threshold: 5, status: 1, store_id: '1' },
  { material_id: 3, material_name: '大米', category: '粮油', unit: 'kg', purchase_price: 4, warning_threshold: 20, status: 0, store_id: '2' }
]);
const searchStore = ref('');
const searchName = ref('');
const searchCategory = ref('');
const searchStatus = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
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
const filteredList = computed(() => {
  let result = rawMaterialList.value.filter(m => {
    const matchStore = !searchStore.value || m.store_id === searchStore.value;
    const matchName = !searchName.value || m.material_name.includes(searchName.value);
    const matchCategory = !searchCategory.value || m.category === searchCategory.value;
    const matchStatus = !searchStatus.value || String(m.status) === searchStatus.value;
    return matchStore && matchName && matchCategory && matchStatus;
  });
  total.value = result.length;
  const startIdx = (currentPage.value - 1) * pageSize.value;
  return result.slice(startIdx, startIdx + pageSize.value);
});
function handleQuery() {}
function handleReset() {
  searchStore.value = '';
  searchName.value = '';
  searchCategory.value = '';
  searchStatus.value = '';
}
function handleSizeChange(val: number) {
  pageSize.value = val;
}
function handlePageChange(val: number) {
  currentPage.value = val;
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
function handleSave() {
  if (!form.value.material_name || !form.value.category || !form.value.unit) {
    ElMessage.warning('请填写必填项');
    return;
  }
  if (form.value.material_id === 0) {
    form.value.material_id = Date.now();
    rawMaterialList.value.push({ ...form.value });
    ElMessage.success('新增成功');
  } else {
    const idx = rawMaterialList.value.findIndex(m => m.material_id === form.value.material_id);
    if (idx !== -1) {
      rawMaterialList.value[idx] = { ...form.value };
      ElMessage.success('修改成功');
    }
  }
  showDialog.value = false;
}
function toggleStatus(row: RawMaterial) {
  row.status = row.status === 1 ? 0 : 1;
  ElMessage.success(row.status === 1 ? '已启用' : '已禁用');
}
</script>
<style scoped>
.inventory-container {
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
.Btn-Save {
  background-color: #22a2b6;
  border-color: #22a2b6;
  color: #fff;
  min-width: 90px;
  height: 36px;
}
.cancel-btn {
  background-color: #fff;
  border-color: #6b5d5d;
  color: #000;
  min-width: 90px;
  height: 36px;
  margin-right: 12px;
}
.custom-table >>> .el-table__body tr:hover {
  background: #e6f7fa !important;
}
.table-btn-edit {
  color: #67c23a !important;
  font-weight: 500;
  margin-right: 8px;
}
.table-btn-status {
  color: #f56c6c !important;
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
.empty-row {
  width: 100%;
  text-align: center;
  padding: 40px 0;
}
</style>