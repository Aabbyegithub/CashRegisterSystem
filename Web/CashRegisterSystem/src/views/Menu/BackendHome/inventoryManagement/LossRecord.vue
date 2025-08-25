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
      <el-form-item label="损耗类型：">
        <el-select v-model="searchType" placeholder="全部类型" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="报损" label="报损" />
          <el-option value="过期" label="过期" />
          <el-option value="丢失" label="丢失" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增损耗</el-button>
      </el-form-item>
    </el-form>
    <el-table :data="filteredList" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="loss_id" label="ID" align="center" />
      <el-table-column prop="material_name" label="原材料" align="center" />
      <el-table-column prop="loss_type" label="损耗类型" align="center" />
      <el-table-column prop="quantity" label="损耗数量" align="center" />
      <el-table-column prop="unit" label="单位" align="center" />
      <el-table-column prop="loss_time" label="损耗时间" align="center" />
      <el-table-column prop="operator" label="操作人" align="center" />
      <el-table-column prop="remark" label="备注" align="center" />
      <el-table-column label="操作" align="center" width="120">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openDetailDialog(scope.row)">详情</el-button>
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
    <el-dialog v-model="addDialogVisible" title="新增损耗记录" width="400px" :close-on-click-modal="false">
      <el-form :model="addForm" label-width="90px">
        <el-form-item label="原材料">
          <el-select v-model="addForm.material_id" placeholder="请选择原材料">
            <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="损耗类型">
          <el-select v-model="addForm.loss_type" placeholder="请选择类型">
            <el-option value="报损" label="报损" />
            <el-option value="过期" label="过期" />
            <el-option value="丢失" label="丢失" />
          </el-select>
        </el-form-item>
        <el-form-item label="损耗数量">
          <el-input-number v-model="addForm.quantity" :min="1" :max="99999" style="width: 100%;" />
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
    <el-dialog v-model="detailDialogVisible" title="损耗详情" width="400px" :close-on-click-modal="false">
      <el-form :model="detailForm" label-width="90px">
        <el-form-item label="原材料">
          <el-input v-model="detailForm.material_name" disabled />
        </el-form-item>
        <el-form-item label="损耗类型">
          <el-input v-model="detailForm.loss_type" disabled />
        </el-form-item>
        <el-form-item label="损耗数量">
          <el-input-number v-model="detailForm.quantity" disabled style="width: 100%;" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="detailForm.remark" type="textarea" disabled />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, computed } from 'vue';

const storeList = ref([
  { id: '1', name: '总部' },
  { id: '2', name: '分店A' },
  { id: '3', name: '分店B' }
]);
const materialList = ref([
  { material_id: '101', material_name: '鸡肉', unit: 'kg' },
  { material_id: '102', material_name: '食用油', unit: 'L' },
  { material_id: '103', material_name: '盐', unit: 'kg' },
  { material_id: '104', material_name: '大米', unit: 'kg' }
]);
const lossRecordList = ref([
  { loss_id: 'L001', material_id: '101', material_name: '鸡肉', loss_type: '报损', quantity: 2, unit: 'kg', loss_time: '2025-08-20 10:00', operator: '张三', remark: '运输损坏' },
  { loss_id: 'L002', material_id: '102', material_name: '食用油', loss_type: '过期', quantity: 1, unit: 'L', loss_time: '2025-08-21 09:30', operator: '李四', remark: '超保质期' },
  { loss_id: 'L003', material_id: '104', material_name: '大米', loss_type: '丢失', quantity: 5, unit: 'kg', loss_time: '2025-08-22 14:20', operator: '王五', remark: '仓库丢失' }
]);

const searchStore = ref('');
const searchMaterial = ref('');
const searchType = ref('');

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

const addDialogVisible = ref(false);
const addForm = ref({
  material_id: '',
  loss_type: '',
  quantity: 1,
  remark: ''
});
const detailDialogVisible = ref(false);
const detailForm = ref({
  material_name: '',
  loss_type: '',
  quantity: 1,
  remark: ''
});

const filteredList = computed(() => {
  let list = lossRecordList.value;
  if (searchStore.value) {
    // 可扩展：根据门店筛选（如有门店字段）
  }
  if (searchMaterial.value) {
    list = list.filter(l => l.material_id === searchMaterial.value);
  }
  if (searchType.value) {
    list = list.filter(l => l.loss_type === searchType.value);
  }
  total.value = list.length;
  const start = (currentPage.value - 1) * pageSize.value;
  return list.slice(start, start + pageSize.value);
});

function handleReset() {
  searchStore.value = '';
  searchMaterial.value = '';
  searchType.value = '';
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
function openAddDialog() {
  addForm.value.material_id = '';
  addForm.value.loss_type = '';
  addForm.value.quantity = 1;
  addForm.value.remark = '';
  addDialogVisible.value = true;
}
function handleAddConfirm() {
  // 模拟新增损耗记录
  const material = materialList.value.find(m => m.material_id === addForm.value.material_id);
  lossRecordList.value.unshift({
    loss_id: 'L' + (lossRecordList.value.length + 1).toString().padStart(3, '0'),
    material_id: addForm.value.material_id,
    material_name: material ? material.material_name : '',
    loss_type: addForm.value.loss_type,
    quantity: addForm.value.quantity,
    unit: material ? material.unit : '',
    loss_time: new Date().toLocaleString(),
    operator: '当前用户',
    remark: addForm.value.remark
  });
  addDialogVisible.value = false;
}
function openDetailDialog(row: any) {
  detailForm.value.material_name = row.material_name;
  detailForm.value.loss_type = row.loss_type;
  detailForm.value.quantity = row.quantity;
  detailForm.value.remark = row.remark;
  detailDialogVisible.value = true;
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