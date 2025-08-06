<template>
  <div class="member-management-container">
    <div class="page-header">
      <div class="operation-bar">
        <div class="filter-group">
          <el-input v-model="searchKeyword" placeholder="手机号/姓名/会员编号" class="search-input" @keyup.enter="fetchMemberList" clearable />
          <el-button type="primary" @click="fetchMemberList">搜索</el-button>
        </div>
        <div class="action-buttons">
          <el-button type="primary" @click="openEditModal()">新增会员</el-button>
          <el-button type="danger" :disabled="!selectedRows.length" @click="handleBatchDelete">批量删除</el-button>
        </div>
      </div>
    </div>
    <div class="member-table-view">
      <el-table
        :data="pagedMemberList"
        border
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="会员编号" prop="member_no" align="center" />
        <el-table-column label="手机号" prop="phone" align="center" />
        <el-table-column label="姓名" prop="name" align="center" />
        <el-table-column label="生日" prop="birthday" align="center" :formatter="(row: { birthday: any; }) => row.birthday || '--'" />
        <el-table-column label="注册时间" prop="register_time" align="center" :formatter="(row: { register_time: any; }) => row.register_time || '--'" />
        <el-table-column label="状态" prop="status" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'" @click="toggleStatus(scope.row)" style="cursor:pointer;">
              {{ scope.row.status === 1 ? '正常' : '冻结' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="积分" prop="total_points" align="center" />
        <el-table-column label="推荐人" prop="referrer_id" align="center" :formatter="formatReferrer" />
        <el-table-column label="操作" align="center" width="180">
          <template #default="scope">
            <el-button type="text" style="color: #67c23a;" @click="openEditModal(scope.row)">编辑</el-button>
            <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination
          layout="prev, pager, next, ->, sizes, jumper"
          :total="memberList.length"
          :page-size="pageSize"
          :current-page="pageIndex"
          :page-sizes="[10, 20, 30, 40, 50]"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>
    <!-- 编辑/新增弹窗 -->
    <el-dialog v-model="showEditModal" width="500" :title="editForm.member_id ? '编辑会员' : '新增会员'">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="手机号">
          <el-input v-model="editForm.phone" placeholder="请输入手机号" :disabled="!!editForm.member_id" />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker v-model="editForm.birthday" type="date" placeholder="请选择生日" style="width:100%;" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editForm.status">
            <el-option label="正常" :value="1" />
            <el-option label="冻结" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="推荐人ID">
          <el-input v-model="editForm.referrer_id" placeholder="可选，推荐人会员ID" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeEditModal">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { ElMessage } from 'element-plus';

const memberList = ref<any[]>([]);
const searchKeyword = ref('');
const pageIndex = ref(1);
const pageSize = ref(10);
const showEditModal = ref(false);
const editForm = reactive<any>({});
const selectedRows = ref<any[]>([]);

const pagedMemberList = computed(() => {
  let filtered = memberList.value.filter((member: any) => {
    const keyword = searchKeyword.value.trim();
    return (
      !keyword ||
      member.phone?.includes(keyword) ||
      member.name?.includes(keyword) ||
      member.member_no?.includes(keyword)
    );
  });
  const start = (pageIndex.value - 1) * pageSize.value;
  return filtered.slice(start, start + pageSize.value);
});

function fetchMemberList() {
  // TODO: 这里调用API获取会员列表，示例用假数据
  memberList.value = [
    {
      member_id: 1,
      member_no: 'M20230801001',
      phone: '13800000001',
      name: '张三',
      birthday: '1990-01-01',
      register_time: '2024-08-01 10:00:00',
      status: 1,
      total_points: 100,
      referrer_id: null
    },
    {
      member_id: 2,
      member_no: 'M20230801002',
      phone: '13900000002',
      name: '李四',
      birthday: '1992-05-10',
      register_time: '2024-08-02 09:00:00',
      status: 0,
      total_points: 50,
      referrer_id: 1
    }
  ];
}

function handleSave() {
  // TODO: 保存会员信息（新增或编辑）
  if (editForm.member_id) {
    // 编辑
    const idx = memberList.value.findIndex(item => item.member_id === editForm.member_id);
    if (idx > -1) {
      memberList.value[idx] = { ...editForm };
      ElMessage.success('编辑成功');
    }
  } else {
    // 新增
    editForm.member_id = Date.now();
    editForm.member_no = 'M' + Date.now();
    editForm.register_time = new Date().toISOString().slice(0, 19).replace('T', ' ');
    editForm.total_points = 0;
    memberList.value.push({ ...editForm });
    ElMessage.success('新增成功');
  }
  fetchMemberList();
  closeEditModal();
}

function handleDelete(member: any) {
  // TODO: 删除会员
  memberList.value = memberList.value.filter(item => item.member_id !== member.member_id);
  ElMessage.success('删除成功');
  fetchMemberList();
}

function handleBatchDelete() {
  // TODO: 批量删除
  const ids = selectedRows.value.map(item => item.member_id);
  memberList.value = memberList.value.filter(item => !ids.includes(item.member_id));
  ElMessage.success('批量删除成功');
  selectedRows.value = [];
  fetchMemberList();
}

function toggleStatus(member: any) {
  // TODO: 切换会员状态
  member.status = member.status === 1 ? 0 : 1;
  ElMessage.success('状态已切换');
}

function openEditModal(member?: any) {
  showEditModal.value = true;
  if (member) {
    Object.keys(member).forEach(key => {
      editForm[key] = member[key];
    });
  } else {
    editForm.member_id = '';
    editForm.member_no = '';
    editForm.phone = '';
    editForm.name = '';
    editForm.birthday = '';
    editForm.status = 1;
    editForm.referrer_id = '';
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
  fetchMemberList();
}
function handlePageChange(val: number) {
  pageIndex.value = val;
  fetchMemberList();
}

function formatReferrer(row: any) {
  return row.referrer_id ? `ID:${row.referrer_id}` : '--';
}

onMounted(() => {
  fetchMemberList();
});
</script>

<style scoped>
.member-management-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
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
  width: 220px;
}
.action-buttons {
  display: flex;
  gap: 10px;
}
.member-table-view {
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
</style>