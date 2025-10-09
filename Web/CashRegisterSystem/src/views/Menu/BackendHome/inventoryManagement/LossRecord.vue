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
      <el-table-column prop="material_name" label="原材料" align="center" />
      <el-table-column prop="loss_type" label="损耗类型" align="center" />
      <el-table-column prop="quantity" label="损耗数量" align="center" />
      <el-table-column prop="unit" label="单位" align="center" />
      <el-table-column prop="loss_time" label="损耗时间" align="center" />
      <el-table-column prop="operator" label="操作人" align="center" />
      <el-table-column prop="remark" label="备注" align="center" />
      <el-table-column label="操作" align="center" width="180">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openDetailDialog(scope.row)">详情</el-button>
          <el-button type="text" class="table-btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button type="text" class="table-btn-edit" style="color:#ff4d4f;" @click="handleDelete(scope.row)">删除</el-button>
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
    <el-dialog v-model="editDialogVisible" title="编辑损耗记录" width="400px" :close-on-click-modal="false">
      <el-form :model="editForm" label-width="90px">
        <el-form-item label="原材料">
          <el-select v-model="editForm.material_id" placeholder="请选择原材料">
            <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_id" />
          </el-select>
        </el-form-item>
        <el-form-item label="损耗类型">
          <el-select v-model="editForm.loss_type" placeholder="请选择类型">
            <el-option value="报损" label="报损" />
            <el-option value="过期" label="过期" />
            <el-option value="丢失" label="丢失" />
          </el-select>
        </el-form-item>
        <el-form-item label="损耗数量">
          <el-input-number v-model="editForm.quantity" :min="1" :max="99999" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="editForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleEditConfirm">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { getStoreList } from '../../../../api/login';
import { getLossList, getLossDetail, addLoss, updateLoss, delLossDetail } from '../../../../api/InventoryLoss';
import { ElMessage } from 'element-plus';
import { getAllRawMaterialList } from '../../../../api/RawMaterial';

const storeList = ref<any[]>([]);
const materialList = ref([
  { material_id: '101', material_name: '鸡肉', unit: 'kg' },
  { material_id: '102', material_name: '食用油', unit: 'L' },
  { material_id: '103', material_name: '盐', unit: 'kg' },
  { material_id: '104', material_name: '大米', unit: 'kg' }
]);
const lossRecordList = ref<any[]>([]);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);
const searchStore = ref('');
const searchMaterial = ref('');
const searchType = ref('');

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
const editDialogVisible = ref(false);
const editForm = ref({
  loss_id: '',
  material_id: '',
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

async function handleQuery() {
  const data:any = await getLossList(
    currentPage.value,
    pageSize.value,
    searchStore.value,
    searchMaterial.value,
    searchType.value
  );
  if (data.success && data.response) {
    lossRecordList.value = data.response.map((item: any) => ({
      loss_id: item.loss_id,
      material_id: item.material_id,
      material_name: materialList.value.find(m => m.material_id == item.material_id)?.material_name || '',
      loss_type: item.loss_type === 0 ? '报损' : item.loss_type === 1 ? '过期' : '丢失',
      quantity: item.loss_quantity,
      unit: materialList.value.find(m => m.material_id == item.material_id)?.unit || '',
      loss_time: item.loss_time?.replace('T', ' ').slice(0, 16),
      operator: item.staff?.name || '当前用户',
      remark: item.loss_reason || ''
    }));
    total.value = data.count || data.response.length;
  } else {
    lossRecordList.value = [];
    total.value = 0;
  }
}
function handleReset() {
  searchStore.value = '';
  searchMaterial.value = '';
  searchType.value = '';
  currentPage.value = 1;
  handleQuery();
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
function openAddDialog() {
  addForm.value.material_id = '';
  addForm.value.loss_type = '';
  addForm.value.quantity = 1;
  addForm.value.remark = '';
  addDialogVisible.value = true;
}
async function handleAddConfirm() {
  if (!addForm.value.material_id || !addForm.value.loss_type || !addForm.value.quantity) {
    ElMessage.warning('请填写完整信息');
    return;
  }
  // 损耗类型映射
  const typeMap: any = { '报损': 0, '过期': 1, '丢失': 2 };
  const payload = {
    material_id: addForm.value.material_id,
    loss_type: typeMap[addForm.value.loss_type],
    loss_quantity: addForm.value.quantity,
    loss_reason: addForm.value.remark,
    batch_no: '',
    loss_id: 0
  };
  const res:any = await addLoss(payload);
  if (res?.success) {
    ElMessage.success('新增成功');
    addDialogVisible.value = false;
    handleQuery();
  } else {
    ElMessage.error(res?.message || '新增失败');
  }
}
async function openDetailDialog(row: any) {
  const res:any = await getLossDetail(row.loss_id);
  const item = res?.response || row;
  detailForm.value.material_name = materialList.value.find(m => m.material_id == item.material_id)?.material_name || '';
  detailForm.value.loss_type = item.loss_type === 0 ? '报损' : item.loss_type === 1 ? '过期' : '丢失';
  detailForm.value.quantity = item.loss_quantity;
  detailForm.value.remark = item.loss_reason || '';
  detailDialogVisible.value = true;
}
function openEditDialog(row: any) {
  editForm.value = {
    loss_id: row.loss_id,
    material_id: row.material_id,
    loss_type: row.loss_type,
    quantity: row.quantity,
    remark: row.remark
  };
  editDialogVisible.value = true;
}
async function handleEditConfirm() {
  // 损耗类型映射
  const typeMap: any = { '报损': 0, '过期': 1, '丢失': 2 };
  const payload = {
    ...editForm.value,
    loss_id: Number(editForm.value.loss_id),
    loss_type: typeMap[editForm.value.loss_type],
    loss_quantity: editForm.value.quantity,
    loss_reason: editForm.value.remark,
  };
  const res:any = await updateLoss(payload);
  if (res?.success) {
    ElMessage.success('修改成功');
    editDialogVisible.value = false;
    handleQuery();
  } else {
    ElMessage.error(res?.message || '修改失败');
  }
}
async function handleDelete(row: any) {
  if (!row.loss_id) return;
  if (confirm('确定要删除该损耗记录吗？')) {
    const res:any = await delLossDetail(row.loss_id);
    if (res?.success) {
      ElMessage.success('删除成功');
      handleQuery();
    } else {
      ElMessage.error(res?.message || '删除失败');
    }
  }
}

onMounted(() => {
  fetchStoreList();
  handleQuery();
  fetchmaterialList()
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