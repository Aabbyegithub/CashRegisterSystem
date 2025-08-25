
<template>
  <div class="table-management-container">
    <!-- 筛选区域 -->
    <el-form class="filter-bar" :inline="true" @submit.prevent>
      <el-form-item label="门店：">
        <el-select v-model="selectedStore" placeholder="请选择门店" style="min-width:140px;" @change="loadQueueData">
          <el-option value="">全部门店</el-option>
          <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="queueStatus" placeholder="请选择状态" style="min-width:140px;" @change="loadQueueData">
          <el-option value="all">全部状态</el-option>
          <el-option value="waiting">等待中</el-option>
          <el-option value="called">已叫号</el-option>
          <el-option value="seated">已入座</el-option>
          <el-option value="skipped">已过号</el-option>
          <el-option value="cancelled">已取消</el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="人数：">
        <el-select v-model="partySize" placeholder="请选择人数" style="min-width:140px;" @change="loadQueueData">
          <el-option value="">不限</el-option>
          <el-option value="1-2">1-2人</el-option>
          <el-option value="3-4">3-4人</el-option>
          <el-option value="5-6">5-6人</el-option>
          <el-option value="7+">7人以上</el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-input v-model="searchKeyword" placeholder="搜索手机号/姓名..." clearable @keyup.enter="loadQueueData" style="width:200px;" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadQueueData">查询</el-button>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="showAddQueueModal = true">新增排队</el-button>
      </el-form-item>
      <el-form-item>
        <el-button @click="loadQueueData">刷新</el-button>
      </el-form-item>
    </el-form>

    <!-- 统计卡片区 -->
    <div class="stats-container">
      <div class="stat-card">
        <div class="stat-label">当前等待</div>
        <div class="stat-value waiting">{{ stats.waitingCount }}</div>
        <div class="stat-desc">桌台不足，建议分流</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">平均等待时间</div>
        <div class="stat-value time">{{ stats.averageWaitTime }}分钟</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">今日累计排队</div>
        <div class="stat-value total">{{ stats.totalToday }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">过号率</div>
        <div class="stat-value rate">{{ stats.skippedRate }}%</div>
      </div>
    </div>

    <!-- 排队列表区域 -->
    <div class="table-list">
      <el-table :data="queueList" border style="width: 100%;height: 57vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="queueNumber" label="排队号" align="center">
          <template #default="scope">
            <el-tag type="primary">{{ scope.row.queueNumber }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="customerName" label="姓名" align="center" />
        <el-table-column prop="phone" label="手机号" align="center">
          <template #default="scope">
            {{ formatPhone(scope.row.phone) }}
          </template>
        </el-table-column>
        <el-table-column prop="partySize" label="人数" align="center">
          <template #default="scope">
            <el-tag>{{ scope.row.partySize }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="排队时间" align="center">
          <template #default="scope">
            {{ formatDateTime(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="waitTime" label="等待时长" align="center">
          <template #default="scope">
            <span :style="{ color: scope.row.waitTime > 30 ? '#FF4D4F' : '' }">{{ scope.row.waitTime }}分钟</span>
          </template>
        </el-table-column>
        <el-table-column prop="notes" label="备注" align="center">
          <template #default="scope">
            {{ scope.row.notes || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="
              scope.row.status === 'waiting' ? 'success' :
              scope.row.status === 'called' ? 'warning' :
              scope.row.status === 'seated' ? 'info' :
              scope.row.status === 'skipped' ? 'danger' :
              scope.row.status === 'cancelled' ? 'danger' : undefined
            ">
              {{ statusMap[scope.row.status] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="220">
          <template #default="scope">
            <el-button type="primary" size="small" @click="callQueue(scope.row)" :disabled="scope.row.status !== 'waiting'">叫号</el-button>
            <el-button type="success" size="small" @click="assignTable(scope.row)" :disabled="!['waiting', 'called'].includes(scope.row.status)">安排桌台</el-button>
            <el-button type="info" size="small" @click="skipQueue(scope.row)" :disabled="!['waiting', 'called'].includes(scope.row.status)">过号</el-button>
            <el-button type="danger" size="small" @click="cancelQueue(scope.row)" :disabled="!['waiting', 'called'].includes(scope.row.status)">取消</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div v-if="queueList.length === 0" class="empty-row">
        <el-empty description="当前没有排队记录" />
      </div>
    </div>

    <!-- 分页区域 -->
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

    <!-- 新增排队弹窗 -->
    <el-dialog v-model="showAddQueueModal" width="500" title="新增排队">
      <el-form :model="newQueue" label-width="120px">
        <el-form-item label="门店">
          <el-select v-model="newQueue.storeId" placeholder="请选择门店">
            <el-option value="">请选择门店</el-option>
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="newQueue.customerName" placeholder="请输入顾客姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="newQueue.phone" placeholder="请输入顾客手机号" />
        </el-form-item>
        <el-form-item label="用餐人数">
          <el-select v-model="newQueue.partySize" placeholder="请选择人数">
            <el-option value="">请选择人数</el-option>
            <el-option value="1">1人</el-option>
            <el-option value="2">2人</el-option>
            <el-option value="3">3人</el-option>
            <el-option value="4">4人</el-option>
            <el-option value="5">5人</el-option>
            <el-option value="6">6人</el-option>
            <el-option value="7">7人</el-option>
            <el-option value="8">8人以上</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="是否会员">
          <el-radio-group v-model="newQueue.isMember">
            <el-radio :label="'1'">是</el-radio>
            <el-radio :label="'0'">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input type="textarea" v-model="newQueue.notes" placeholder="请输入特殊需求（如靠窗、不要辣等）" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddQueueModal = false">取消</el-button>
        <el-button type="primary" @click="saveNewQueue">确认添加</el-button>
      </template>
    </el-dialog>

    <!-- 安排桌台弹窗 -->
    <el-dialog v-model="showAssignTableModal" width="500" :title="`安排桌台 - ${currentQueue?.queueNumber}`">
      <div class="queue-info">
        <div class="info-item">
          <span class="info-label">顾客：</span>
          <span class="info-value">{{ currentQueue?.customerName }} ({{ formatPhone(currentQueue?.phone) }})</span>
        </div>
        <div class="info-item">
          <span class="info-label">人数：</span>
          <span class="info-value">{{ currentQueue?.partySize }}人</span>
        </div>
        <div class="info-item">
          <span class="info-label">等待时间：</span>
          <span class="info-value">{{ currentQueue?.waitTime }}分钟</span>
        </div>
      </div>
      <div class="available-tables">
        <h4 class="section-title">可选桌台（空闲状态）</h4>
        <el-radio-group v-model="selectedTableId">
          <el-radio v-for="table in availableTables" :key="table.id" :label="table.id" :disabled="table.capacity < (currentQueue?.partySize ?? 0)">
            <div class="table-info">
              <div class="table-name">{{ table.number }}</div>
              <div class="table-desc">
                {{ table.shape === 'round' ? '圆桌' : table.shape === 'square' ? '方桌' : '长桌' }}，
                {{ table.capacity }}人，{{ table.areaName }}
              </div>
            </div>
          </el-radio>
        </el-radio-group>
        <div class="no-tables" v-if="availableTables.length === 0">
          当前没有可用桌台，请稍后再试
        </div>
      </div>
      <template #footer>
        <el-button @click="showAssignTableModal = false">取消</el-button>
        <el-button type="primary" @click="confirmAssignTable" :disabled="!selectedTableId">确认安排</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, watch } from 'vue';
import {
  ElSelect, ElOption, ElInput, ElButton, ElTable, ElTableColumn,
  ElPagination, ElTag, ElDialog, ElForm, ElFormItem, ElRadioGroup, ElRadio, ElEmpty, ElMessage
} from 'element-plus';
// import { formatDateTime as formatDateTimeUtil } from '@/utils/format';
// 引入API请求函数
// import { 
//   fetchQueueList, 
//   fetchQueueStats, 
//   updateQueueStatus, 
//   createQueue, 
//   assignTable as assignTableApi 
// } from '@/api/queue';
// import { fetchStoreList } from '@/api/store';
// import { fetchAvailableTables } from '@/api/table';

// 状态映射，类型安全
const statusMap: Record<QueueItem['status'], string> = {
  waiting: '等待中',
  called: '已叫号',
  seated: '已入座',
  skipped: '已过号',
  cancelled: '已取消'
};

// 门店列表

interface Store {
  id: string;
  name: string;
}
interface QueueItem {
  id: string;
  queueNumber: string;
  customerName: string;
  phone: string;
  partySize:  number;
  createTime: string;
  waitTime: number;
  notes?: string;
  status: string;
}
interface Table {
  id: string;
  number: string;
  shape: string;
  capacity: number;
  areaName: string;
}

const storeList = ref<Store[]>([]);
const selectedStore = ref('');
const queueStatus = ref('all');
const partySize = ref('');
const searchKeyword = ref('');

// 分页参数
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 排队列表数据
const queueList = ref<QueueItem[]>([]);
const stats = ref({
  waitingCount: 0,
  averageWaitTime: 0,
  totalToday: 0,
  skippedRate: 0
});

// 弹窗状态
const showAddQueueModal = ref(false);
const showAssignTableModal = ref(false);
const currentQueue = ref<QueueItem | null>(null);
const availableTables = ref<any[]>([]);
const selectedTableId = ref('');

// 新增排队表单数据
const newQueue = ref({
  storeId: '',
  customerName: '',
  phone: '',
  partySize: '',
  isMember: '0',
  notes: ''
});


// 加载排队数据（模拟）
const loadQueueData = async () => {
  // TODO: 替换为真实接口
  queueList.value = [
    {
      id: '1', queueNumber: 'A001', customerName: '张三', phone: '13812345678', partySize: 3, createTime: '2025-08-22 12:00', waitTime: 15, notes: '靠窗', status: 'waiting'
    },
    {
      id: '2', queueNumber: 'A002', customerName: '李四', phone: '13987654321', partySize: 2, createTime: '2025-08-22 12:10', waitTime: 35, notes: '', status: 'called'
    }
  ];
  total.value = queueList.value.length;
  stats.value = {
    waitingCount: 1,
    averageWaitTime: 25,
    totalToday: 2,
    skippedRate: 0
  };
};

// 加载门店列表（模拟）

// 加载门店列表（模拟）
storeList.value = [
  { id: '1', name: '旗舰店' },
  { id: '2', name: '分店A' }
];

// 重置筛选条件
const handleReset = () => {
  selectedStore.value = '';
  queueStatus.value = 'all';
  partySize.value = '';
  searchKeyword.value = '';
  loadQueueData();
};

// 分页相关
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  loadQueueData();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  loadQueueData();
};

// 加载门店列表
const loadStores = async () => {
//   try {
//     const data = await fetchStoreList();
//     storeList.value = data || [];
//   } catch (error) {
//     console.error('加载门店列表失败:', error);
//     alert('加载门店列表失败，请重试');
//   }
};

// 叫号操作
const callQueue = async (queue: QueueItem) => {
  ElMessage.success(`已呼叫 ${queue.queueNumber} 号，请顾客到前台`);
};

// 安排桌台
const assignTable = async (queue: QueueItem) => {
  currentQueue.value = queue;
  selectedTableId.value = '';
  // 模拟可用桌台
  availableTables.value = [
    { id: 'T01', number: 'T01', shape: 'round', capacity: 4, areaName: '大厅' },
    { id: 'T02', number: 'T02', shape: 'square', capacity: 2, areaName: '包间' }
  ];
  showAssignTableModal.value = true;
};

// 确认安排桌台
const confirmAssignTable = async () => {
  if (!selectedTableId.value || !currentQueue.value) return;
  showAssignTableModal.value = false;
  ElMessage.success(`已为 ${currentQueue.value.queueNumber} 号安排桌台`);
};

// 过号操作
const skipQueue = async (queue: QueueItem) => {
  ElMessage.info(`已将 ${queue.queueNumber} 号标记为过号`);
};

// 取消排队
const cancelQueue = async (queue: QueueItem) => {
  ElMessage.error(`已取消 ${queue.queueNumber} 号的排队`);
};

// 保存新增排队
const saveNewQueue = async () => {
  if (!newQueue.value.storeId || !newQueue.value.customerName || !newQueue.value.phone || !newQueue.value.partySize) {
    ElMessage.warning('请填写必填字段');
    return;
  }
  showAddQueueModal.value = false;
  ElMessage.success('新增排队成功（模拟）');
  // 重置表单
  newQueue.value = {
    storeId: '',
    customerName: '',
    phone: '',
    partySize: '',
    isMember: '0',
    notes: ''
  };
  loadQueueData();
};


// 格式化手机号
const formatPhone = (phone?: string) => {
  if (!phone) return '';
  return phone.replace(/(\d{3})(\d{4})(\d{4})/, '$1****$3');
};
// 格式化日期时间
const formatDateTime = (dateStr?: string) => {
  if (!dateStr) return '';
  return dateStr.replace(' ', '\n');
};

// 监听分页变化

watch(currentPage, loadQueueData);

// 页面加载时初始化
onMounted(() => {
  loadStores();
  loadQueueData();
});
</script>

<style scoped>
.queue-list-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 22px;
  color: #1D2129;
  margin: 0 0 16px 0;
  font-weight: 600;
}

.header-controls {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 16px;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
}

.filter-item {
  display: flex;
  align-items: center;
}

.filter-label {
  color: #4E5969;
  margin-right: 8px;
  font-size: 14px;
  white-space: nowrap;
}

.filter-select {
  padding: 6px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  background-color: #fff;
  font-size: 14px;
  color: #1D2129;
  min-width: 120px;
}

.search-box {
  display: flex;
  align-items: center;
}

.search-input {
  padding: 6px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px 0 0 4px;
  font-size: 14px;
  color: #1D2129;
  width: 200px;
  border-right: none;
}

.search-btn {
  padding: 6px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 0 4px 4px 0;
  background-color: #fff;
  color: #4E5969;
  cursor: pointer;
  border-left: none;
}

.search-btn:hover {
  color: #165DFF;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.btn {
  padding: 6px 16px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.primary-btn {
  background-color: #165DFF;
  color: #fff;
}

.primary-btn:hover {
  background-color: #0E42D2;
}

.refresh-btn {
  background-color: #fff;
  color: #1D2129;
  border: 1px solid #DCDFE6;
}

.refresh-btn:hover {
  background-color: #F5F7FA;
}

.stats-container {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  flex: 1;
  min-width: 180px;
  background-color: #fff;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.stat-label {
  font-size: 14px;
  color: #4E5969;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 4px;
}

.stat-value.waiting {
  color: #FF4D4F;
}

.stat-value.time {
  color: #FAAD14;
}

.stat-value.total {
  color: #52C41A;
}

.stat-value.rate {
  color: #165DFF;
}

.stat-desc {
  font-size: 12px;
  color: #86909C;
}

.queue-table-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  margin-bottom: 16px;
}

.queue-table {
  width: 100%;
  border-collapse: collapse;
}

.table-header {
  padding: 12px 16px;
  text-align: left;
  font-size: 14px;
  color: #4E5969;
  font-weight: 500;
  background-color: #F5F7FA;
  border-bottom: 1px solid #F2F3F5;
}

.table-cell {
  padding: 12px 16px;
  font-size: 14px;
  color: #1D2129;
  border-bottom: 1px solid #F2F3F5;
}

.queue-item:hover {
  background-color: #F5F7FA;
}

.queue-item.waiting {
  background-color: rgba(82, 196, 26, 0.03);
}

.queue-item.called {
  background-color: rgba(250, 173, 20, 0.03);
}

.queue-item.seated {
  background-color: rgba(82, 196, 26, 0.05);
}

.queue-item.skipped, .queue-item.cancelled {
  background-color: rgba(134, 144, 156, 0.05);
  color: #86909C;
}

.queue-number {
  display: inline-block;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: #165DFF;
  color: #fff;
  text-align: center;
  line-height: 32px;
  font-weight: 600;
}

.people-count {
  display: inline-block;
  padding: 2px 8px;
  background-color: #E8F3FF;
  color: #165DFF;
  border-radius: 4px;
  font-size: 12px;
}

.status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-tag.waiting {
  background-color: rgba(82, 196, 26, 0.1);
  color: #52C41A;
}

.status-tag.called {
  background-color: rgba(250, 173, 20, 0.1);
  color: #FAAD14;
}

.status-tag.seated {
  background-color: rgba(82, 196, 26, 0.2);
  color: #238636;
}

.status-tag.skipped {
  background-color: rgba(134, 144, 156, 0.1);
  color: #86909C;
}

.status-tag.cancelled {
  background-color: rgba(255, 77, 79, 0.1);
  color: #FF4D4F;
}

.overtime {
  color: #FF4D4F;
  font-weight: 500;
}

.operation-buttons {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 2px 8px;
  font-size: 12px;
  border-radius: 4px;
}

.call-btn {
  background-color: rgba(250, 173, 20, 0.1);
  color: #FAAD14;
}

.call-btn:hover {
  background-color: rgba(250, 173, 20, 0.2);
}

.assign-btn {
  background-color: rgba(82, 196, 26, 0.1);
  color: #52C41A;
}

.assign-btn:hover {
  background-color: rgba(82, 196, 26, 0.2);
}

.skip-btn {
  background-color: rgba(134, 144, 156, 0.1);
  color: #86909C;
}

.skip-btn:hover {
  background-color: rgba(134, 144, 156, 0.2);
}

.cancel-btn {
  background-color: rgba(255, 77, 79, 0.1);
  color: #FF4D4F;
}

.cancel-btn:hover {
  background-color: rgba(255, 77, 79, 0.2);
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.empty-row .empty-cell {
  padding: 40px 0;
  text-align: center;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #86909C;
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 14px;
}

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  font-size: 14px;
  color: #4E5969;
}

.pagination-info {
  flex: 1;
}

.pagination-controls {
  display: flex;
  gap: 8px;
}

.page-btn {
  padding: 4px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  background-color: #fff;
  color: #1D2129;
  cursor: pointer;
  font-size: 14px;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-btn:hover:not(:disabled) {
  border-color: #165DFF;
  color: #165DFF;
}

/* 弹窗样式 */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-dialog {
  width: 500px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #F2F3F5;
}

.modal-title {
  font-size: 16px;
  color: #1D2129;
  margin: 0;
  font-weight: 600;
}

.modal-close {
  background: none;
  border: none;
  font-size: 18px;
  color: #86909C;
  cursor: pointer;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  background-color: #F5F7FA;
  color: #1D2129;
}

.modal-body {
  padding: 20px;
  max-height: 500px;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 16px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #1D2129;
}

.required {
  color: #FF4D4F;
}

.form-control {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  font-size: 14px;
  color: #1D2129;
}

.form-control:focus {
  outline: none;
  border-color: #165DFF;
}

.radio-group {
  display: flex;
  gap: 16px;
}

.radio-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #1D2129;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #F2F3F5;
}

.modal-btn {
  padding: 8px 16px;
}

.queue-info {
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid #F2F3F5;
}

.info-item {
  margin-bottom: 8px;
  font-size: 14px;
}

.info-label {
  color: #4E5969;
  display: inline-block;
  width: 80px;
}

.info-value {
  color: #1D2129;
}

.section-title {
  font-size: 14px;
  color: #1D2129;
  margin: 0 0 12px 0;
  font-weight: 500;
}

.table-selector {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.table-option {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.table-option:hover {
  border-color: #165DFF;
  background-color: rgba(22, 93, 255, 0.03);
}

.table-option input:checked + .table-info {
  color: #165DFF;
}

.table-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.table-desc {
  font-size: 12px;
  color: #4E5969;
}

.no-tables {
  text-align: center;
  padding: 20px;
  color: #86909C;
  font-size: 14px;
  background-color: #F5F7FA;
  border-radius: 4px;
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .operation-buttons {
    flex-wrap: wrap;
  }
}

/* Element Plus 表格美化 */
.el-table th {
  text-align: center !important;
  font-size: 15px;
  font-weight: 500;
}
.el-table td {
  text-align: center !important;
  font-size: 14px;
}
.el-tag {
  border-radius: 8px !important;
  font-size: 15px !important;
  padding: 4px 14px !important;
}
.el-button {
  border-radius: 8px !important;
  font-size: 14px !important;
  padding: 4px 16px !important;
  margin-right: 6px;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
  padding: 18px 24px 0 0;
  font-size: 15px;
}
.el-dialog__footer {
  display: flex;
  justify-content: flex-end;
  gap: 18px;
}
.el-form-item {
  margin-bottom: 22px !important;
}
.table-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 4px 0 0 0;
}
.table-name {
  font-weight: 600;
  margin-bottom: 2px;
  font-size: 15px;
}
.table-desc {
  font-size: 13px;
  color: #4E5969;
}

@media (max-width: 992px) {
  .filter-bar {
    width: 100%;
  }
  
  .header-controls {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .action-buttons {
    width: 100%;
    justify-content: flex-start;
  }
  
  .stat-card {
    flex: 1 1 45%;
  }
}

@media (max-width: 768px) {
  .queue-table-container {
    overflow-x: auto;
  }
  
  .queue-table {
    min-width: 800px;
  }
  
  .stat-card {
    flex: 1 1 100%;
  }
  
  .modal-dialog {
    width: 90%;
  }
}
</style>
