<template>
  <div class="supplier-container">
    <!-- 筛选区 -->
    <div class="filter-bar">
      <el-input v-model="searchName" placeholder="供应商名称" style="width:200px;margin-right:16px;" clearable />
      <el-select v-model="searchStatus" placeholder="状态" style="width:140px;margin-right:16px;" clearable>
        <el-option label="全部" :value="''" />
        <el-option label="合作中" :value="1" />
        <el-option label="已停用" :value="0" />
      </el-select>
      <el-button type="primary" @click="fetchList">查询</el-button>
      <el-button @click="openAddDialog" style="margin-left:auto;">新增供应商</el-button>
    </div>
    <!-- 列表区 -->
    <el-table :data="supplierList" style="margin-top:18px; height: 68vh;" border>
      <el-table-column prop="supplier_name" label="供应商名称" />
      <el-table-column prop="contact_person" label="联系人" />
      <el-table-column prop="contact_phone" label="联系电话" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="status" label="状态">
        <template #default="scope">
          <el-tag :type="scope.row.status===1?'success':'info'">{{ scope.row.status===1?'合作中':'已停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="220">
        <template #default="scope">
          <el-button size="small" @click="openDetailDialog(scope.row)">详情</el-button>
          <el-button size="small" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <!-- 分页 -->
    <el-pagination
      style="margin-top:16px;float:right;"
      :total="total"
      :page-size="pageSize"
      :current-page="currentPage"
      @size-change="handleSizeChange"
      @current-change="handlePageChange"
      :page-sizes="[10,20,30,50]"
      layout="prev, pager, next, ->, sizes, jumper"
    />
    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="editDialogVisible" :title="editMode==='add'?'新增供应商':'编辑供应商'" width="500">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="供应商名称">
          <el-input v-model="editForm.supplier_name" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="editForm.contact_person" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="editForm.contact_phone" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="editForm.address" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="合作中" :value="1" />
            <el-option label="已停用" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleEditConfirm">保存</el-button>
      </template>
    </el-dialog>
    <!-- 详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="供应商详情" width="500">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="供应商名称">{{ detail.supplier_name }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ detail.contact_person }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ detail.contact_phone }}</el-descriptions-item>
        <el-descriptions-item label="地址">{{ detail.address }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detail.status===1?'合作中':'已停用' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailDialogVisible=false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import {
  getSupplierList,
  getSupplierDetail,
  addSupplier,
  updateSupplier,
  deleteSupplier,
  type Supplier
} from '../../../../api/supplier';

const searchName = ref('');
const searchStatus = ref('');
const supplierList = ref<Supplier[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const editDialogVisible = ref(false);
const editMode = ref<'add'|'edit'>('add');
const editForm = ref<Supplier>({
  supplier_id: 0,
  supplier_name: '',
  contact_person: '',
  contact_phone: '',
  address: '',
  status: 1
});
const detailDialogVisible = ref(false);
const detail = ref<Supplier>({
  supplier_id: 0,
  supplier_name: '',
  contact_person: '',
  contact_phone: '',
  address: '',
  status: 1
});

async function fetchList() {
  const params:any = {
    pageIndex: currentPage.value,
    pageSize: pageSize.value,
    name: searchName.value,
    status: searchStatus.value
  };
  const res:any = await getSupplierList(params);
  if(res?.success) {
    supplierList.value = res.response || [];
    total.value = res.count || 0;
  }
}
function handleSizeChange(val:number) {
  pageSize.value = val;
  fetchList();
}
function handlePageChange(val:number) {
  currentPage.value = val;
  fetchList();
}
function openAddDialog() {
  editMode.value = 'add';
  editForm.value = {
    supplier_id: 0,
    supplier_name: '',
    contact_person: '',
    contact_phone: '',
    address: '',
    status: 1
  };
  editDialogVisible.value = true;
}
function openEditDialog(row:Supplier) {
  editMode.value = 'edit';
  editForm.value = { ...row };
  editDialogVisible.value = true;
}
async function handleEditConfirm() {
  if(editMode.value==='add') {
    const res:any = await addSupplier(editForm.value);
    if(res?.success) {
      ElMessage.success('新增成功');
      editDialogVisible.value = false;
      fetchList();
    } else {
      ElMessage.error(res?.message||'新增失败');
    }
  } else {
    const res:any = await updateSupplier(editForm.value);
    if(res?.success) {
      ElMessage.success('编辑成功');
      editDialogVisible.value = false;
      fetchList();
    } else {
      ElMessage.error(res?.message||'编辑失败');
    }
  }
}
function openDetailDialog(row:Supplier) {
  getSupplierDetail(row.supplier_id).then((res:any)=>{
    if(res?.success) {
      detail.value = res.response;
      detailDialogVisible.value = true;
    }
  });
}
async function handleDelete(row:Supplier) {
  const res:any = await deleteSupplier(row.supplier_id);
  if(res?.success) {
    ElMessage.success('删除成功');
    fetchList();
  } else {
    ElMessage.error(res?.message||'删除失败');
  }
}
onMounted(()=>{
  fetchList();
});
</script>

<style scoped>
.supplier-container {
  padding: 20px;
}
.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}
</style>
