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
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column prop="backup_name" label="备份名称" width="200" align="center" />
        <el-table-column prop="backup_time" label="备份时间" align="center" />
        <el-table-column prop="size" label="文件大小" align="center" />
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === '成功' ? 'success' : 'warning'">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" align="center">
          <template #default="scope">
            <el-button type="text" style="color: #165DFF;" @click="viewDetail(scope.row)">明细</el-button>
            <el-button type="text" style="color: #f56c6c;" @click="deleteBackup(scope.row)">删除</el-button>
          </template>
        </el-table-column>
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

    <!-- 明细弹窗 -->
    <el-dialog v-model="showDetailDialog" title="备份明细" width="500">
      <el-descriptions :title="detailData.backup_name" :column="1" border>
        <el-descriptions-item label="备份时间">{{ detailData.backup_time }}</el-descriptions-item>
        <el-descriptions-item label="文件大小">{{ detailData.size }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ detailData.status }}</el-descriptions-item>
        <el-descriptions-item label="文件路径">{{ detailData.path }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ detailData.remark }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button class="cancel-btn" @click="showDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
const backupList = ref([
  { backup_id: 1, backup_name: '自动备份2025-08-01', backup_time: '2025-08-01 02:00', size: '12MB', status: '成功', path: '/backup/20250801.bak', remark: '系统自动备份' },
  { backup_id: 2, backup_name: '手动备份2025-08-05', backup_time: '2025-08-05 15:30', size: '13MB', status: '成功', path: '/backup/20250805.bak', remark: '管理员手动备份' },
  { backup_id: 3, backup_name: '自动备份2025-08-08', backup_time: '2025-08-08 02:00', size: '12.5MB', status: '失败', path: '/backup/20250808.bak', remark: '磁盘空间不足' },
])
const searchKeyword = ref('')
const filteredBackupList = computed(() => {
  if (!searchKeyword.value) return backupList.value
  return backupList.value.filter(b => b.backup_name.includes(searchKeyword.value))
})
const page = ref(1)
const pageSize = ref(10)

function handleBackup() {
  // TODO: 触发备份API
}
function refreshBackupList() {
  // TODO: 刷新备份列表
}
function filterBackupList() {
  page.value = 1
}
function handleSizeChange(val: number) {
  pageSize.value = val
}
function handlePageChange(val: number) {
  page.value = val
}
function deleteBackup(row: any) {
  // TODO: 删除备份API
}
const showDetailDialog = ref(false)
const detailData = reactive({ backup_name: '', backup_time: '', size: '', status: '', path: '', remark: '' })
function viewDetail(row: any) {
  Object.assign(detailData, row)
  showDetailDialog.value = true
}
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