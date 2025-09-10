<template>
  <div class="store-management-container">
    <div class="page-header">
      <div class="operation-bar">
        <div class="filter-group">
          <el-input v-model="searchStoreName" placeholder="搜索门店名称" class="search-input" @keyup.enter="fetchStoreList" />
          <el-input v-model="searchaddress" placeholder="搜索门店地址" class="search-input" @keyup.enter="fetchStoreList" />
          <el-input v-model="searchphone" placeholder="搜索门店电话" class="search-input" @keyup.enter="fetchStoreList" />
          <el-button class="search-btn" @click="fetchStoreList">搜索</el-button>
        </div>
        <div class="action-buttons">
          <el-button class="primary-btn" @click="openEditModal()">新增门店</el-button>
          <el-button class="danger-btn" :disabled="!selectedRows.length" @click="handleBatchDelete">批量删除</el-button>
        </div>
      </div>
    </div>
    <div class="store-table-view">
      <div class="table-list">
        <el-table
          :data="storeList"
          border
          style="width: 100%;height: 68vh;"
          :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column label="门店编码" prop="store_code" align="center" />
          <el-table-column label="门店名称" prop="store_name" align="center" />
          <el-table-column label="地址" prop="address" align="center" />
          <el-table-column label="联系电话" prop="phone" align="center" />
          <el-table-column label="营业时间" prop="business_hours" align="center" />
          <el-table-column label="总桌台数" prop="total_tables" align="center" />
          <el-table-column label="状态" prop="status" align="center">
            <template #default="scope">
              <el-tag :type="scope.row.status === 1 ? 'success' : 'info'" @click="toggleStatus(scope.row)">
                {{ scope.row.status === 1 ? '营业中' : '停业' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="创建时间" prop="created_at" align="center" />
          <el-table-column label="操作" align="center" width="180">
            <template #default="scope">
              <el-button type="text" style="color: #67c23a;" @click="openEditModal(scope.row)">编辑</el-button>
              <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div class="pagination-bar">
        <el-pagination
          layout="prev, pager, next, ->, sizes, jumper"
          :total="total"
          :page-size="pageSize"
          :current-page="pageIndex"
          :prev-text="'<'"
          :next-text="'>'"
          :page-sizes="[10, 20, 30, 40, 50]"
          :display-page-count="5"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>
    <!-- 编辑/新增弹窗 -->
    <el-dialog v-model="showEditModal" width="500" :title="editForm.store_id ? '编辑门店' : '新增门店'">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="门店名称">
          <el-input v-model="editForm.store_name" placeholder="请输入门店名称" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="editForm.address" placeholder="请输入门店地址" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="editForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="营业时间">
          <el-input v-model="editForm.business_hours" placeholder="如 10:00-22:00" />
        </el-form-item>
        <el-form-item label="总桌台数">
          <el-input v-model.number="editForm.total_tables" type="number" min="0" placeholder="请输入总桌台数" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="营业中" :value="1" />
            <el-option label="停业" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="closeEditModal">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { addStoreApi, deleteStoreApi, editStoreApi, getStoreList, updateStoreStatusApi } from '../../../../api/storeapi';
import dayjs from 'dayjs';

const storeList = ref<any[]>([]);
const searchStoreName = ref('')
const searchphone = ref('');
const searchaddress= ref('');
const pageIndex = ref(1);
const pageSize = ref(10);
const total = ref(10);
const showEditModal = ref(false);
const editForm = reactive<any>({});
const selectedRows = ref<any[]>([]);

async function fetchStoreList() {
  await getStoreList(searchStoreName.value,searchphone.value,searchaddress.value,pageIndex.value,pageSize.value).then((res: any) => {
    if (res && res.response) {
      storeList.value = res.response.map((item: any) => ({
        store_id: item.store_id,
        store_name: item.store_name,
        address: item.address,
        phone: item.phone,
        business_hours: item.business_hours,
        total_tables: item.total_tables,
        status: item.status,
        created_at:dayjs(item.created_at).format('YYYY-MM-DD HH:mm:ss'),
        store_code:item.store_code
      }));
      total.value = res.count || 0;
    } else {
      ElMessage.error('获取门店列表失败');
    }
  }).catch(() => {
     ElMessage.error('获取门店列表失败');
  });
}

async function handleSave() {
  // TODO: 保存门店信息（新增或编辑）
  if (editForm.store_id) {
    // 编辑
    const idx = storeList.value.findIndex(item => item.store_id === editForm.store_id);
    if (idx > -1) {
      await editStoreApi(editForm.store_id,editForm.store_name, editForm.phone, editForm.address,editForm.business_hours,editForm.total_tables,editForm.status)
      ElMessage.success('编辑成功');
    }
  } else {
    // 新增
    await addStoreApi(editForm.store_name, editForm.phone, editForm.address,editForm.business_hours,editForm.total_tables,editForm.status)
    ElMessage.success('新增成功');
  }
  fetchStoreList();
  closeEditModal();
}

async function handleDelete(store: any) {
  // TODO: 删除门店
  await deleteStoreApi([store.store_id]);
  ElMessage.success('删除成功');
  fetchStoreList();
}

async function handleBatchDelete() {
  // TODO: 批量删除
  const ids = selectedRows.value.map(item => item.store_id);
  await deleteStoreApi(ids);
  ElMessage.success('批量删除成功');
  selectedRows.value = [];
  fetchStoreList();
}

async function toggleStatus(store: any) {
  // TODO: 切换门店状态
  await updateStoreStatusApi(store.store_id, store.status === 1 ? 0 : 1);
  ElMessage.success('状态已切换');
  fetchStoreList();
}

function openEditModal(store?: any) {
  showEditModal.value = true;
  if (store) {
    Object.keys(store).forEach(key => {
      editForm[key] = store[key];
    });
  } else {
    editForm.store_id = '';
    editForm.store_name = '';
    editForm.store_code = '';
    editForm.address = '';
    editForm.phone = '';
    editForm.business_hours = '';
    editForm.total_tables = 0;
    editForm.status = 1;
  }
}

function closeEditModal() {
  showEditModal.value = false;
  Object.keys(editForm).forEach(k => editForm[k] = '');
}

function handleSelectionChange(val: any[]) {
  selectedRows.value = val;
}

function handleSizeChange(val: number) {
  pageSize.value = val;
  fetchStoreList();
}
function handlePageChange(val: number) {
  pageIndex.value = val;
  fetchStoreList();
}

onMounted(() => {
  fetchStoreList();
});
</script>

<style scoped>
/* 可复用员工管理的样式，或根据实际需求调整 */
.store-management-container {
  padding: 10px;
  /* background-color: #F5F7FA; */
  /* min-height: 100%; */
}
.page-header {
  margin-bottom: 24px;
}
.operation-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}
.filter-group {
  display: flex;
  align-items: center;
  gap: 12px;
}
.search-input {
  /* padding: 4px 10px;
  border-radius: 4px;
  border: 1px solid #DCDFE6;
  font-size: 14px; */
}
.search-btn {
  background-color: #22a2b6;
  color: #fff;
  border: none;
  border-radius: 4px;
  padding: 4px 14px;
  font-size: 14px;
  cursor: pointer;
}
.action-buttons {
  display: flex;
  gap: 10px;
}
.primary-btn {
  background-color: #22a2b6;
  color: #fff;
  border: none;
  border-radius: 4px;
  padding: 4px 14px;
  font-size: 14px;
  cursor: pointer;
}
.primary-btn:hover {
  background-color: #0E42D2;
}
.danger-btn {
  background-color: #F53F3F;
  color: #fff;
  border: none;
  border-radius: 4px;
  padding: 4px 14px;
  font-size: 14px;
  cursor: pointer;
}
.danger-btn:disabled {
  background-color: #F5F7FA;
  color: #C9CDD4;
  cursor: not-allowed;
}
.store-table-view {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 0 0 16px 0;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.Btn-Save {
  background-color: #22a2b6;
  border-color: #22a2b6;
}
.cancel-btn {
  background-color: #fff;
  border-color: #6b5d5d;
  color: #000;
  margin-right: 10px;
}
</style>