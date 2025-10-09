<template>
  <div class="table-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <el-button type="primary" style="background-color: #22A2B6;" @click="handleBackup">立即备份</el-button>
      <el-button @click="refreshBackupList">刷新</el-button>
      <el-input v-model="searchKeyword" placeholder="搜索备份名称" clearable class="filter-item" @input="filterBackupList" />
    </div>

    <!-- 备份列表区域 -->
    <div class="table-list">
      <el-table
        :data="filteredBackupList"
        border
        style="width: 100%;height: 70vh;"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column prop="backup_name" label="备份名称" width="300" align="center" />
        <el-table-column prop="backup_time" label="备份时间" align="center" width="150" />
        <el-table-column prop="size" label="备份订单数" align="center" width="100"/>
        <el-table-column prop="status" label="状态" align="center" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === '成功' ? 'success' : 'warning'">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备份备注" align="center" />
      </el-table>
    </div>

    <!-- 分页区域 -->
    <div class="pagination-bar">
      <el-pagination
        layout="prev, pager, next, ->, sizes, jumper"
        :total="filteredBackupList.length"
        :page-size="pageSize"
        :current-page="page"
        :prev-text="'<'"
        :next-text="'>'"
        :page-sizes="[10, 20, 30, 40, 50]"
        :display-page-count="5"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { getBackupList, addBackup } from '../../../../api/Backup';
import { dayjs, ElMessage } from 'element-plus';

const backupList = ref<any[]>([]);
const searchKeyword = ref('');
const page = ref(1);
const pageSize = ref(10);
const total = ref(0);
const filteredBackupList = computed(() => {
  if (!searchKeyword.value) return backupList.value.slice((page.value-1)*pageSize.value, page.value*pageSize.value);
  const filtered = backupList.value.filter(b => b.backup_name.includes(searchKeyword.value));
  total.value = filtered.length;
  return filtered.slice((page.value-1)*pageSize.value, page.value*pageSize.value);
});

async function handleBackup() {
  const res:any = await addBackup();
  if (res?.success) {
    ElMessage.success('备份成功');
    await refreshBackupList();
  } else {
    ElMessage.error(res?.message || '备份失败');
  }
}
async function refreshBackupList() {
  const res:any = await getBackupList(page.value, pageSize.value, searchKeyword.value);
  const data =res;
  if (data.success && data.response) {
    backupList.value = data.response.map((item: any) => ({
      backup_id: item.id,
      backup_name: item.backup_name,
      backup_time: dayjs(item.backup_time).format('YYYY-MM-DD HH:mm'),
      size: (item.backup_sum ?? 0) + '条',
      status: item.status === 1 ? '成功' : '失败',
      remark: item.backup_remark,
      path: '',
    }));
    total.value = data.count || data.response.length;
  } else {
    backupList.value = [];
    total.value = 0;
  }
}
function filterBackupList() {
  page.value = 1;
  refreshBackupList();
}
function handleSizeChange(val: number) {
  pageSize.value = val;
  refreshBackupList();
}
function handlePageChange(val: number) {
  page.value = val;
  refreshBackupList();
}

// 页面初始化
refreshBackupList();
</script>

<style scoped>
.table-management-container {
  padding: 24px;
}
.filter-bar {
  display: flex;
  align-items: center;
  gap: 12px;
}
.filter-item {
  width: 200px;
}
.table-list {
  margin-top: 16px;
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
  margin-right: 10px;
}
</style>