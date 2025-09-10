<template>
  <div class="table-management-container">

        <!-- 统计卡片区 -->
    <div class="stats-container">
      <div class="stat-card stat-waiting">
        <div class="stat-content">
          <div class="stat-label">当前等待</div>
          <div class="stat-value waiting">{{ stats.waitingCount }}</div>
          <div class="stat-desc">桌台不足 建议分流</div>
        </div>
      </div>
      <div class="stat-card stat-time">
        <div class="stat-content">
          <div class="stat-label">平均等待时间</div>
          <div class="stat-value time">{{ stats.averageWaitTime }}<span class="stat-unit">分钟</span></div>
        </div>
      </div>
      <div class="stat-card stat-total">
        <div class="stat-content">
          <div class="stat-label">今日累计排队</div>
          <div class="stat-value total">{{ stats.totalToday }}</div>
        </div>
      </div>
      <div class="stat-card stat-rate">
        <div class="stat-content">
          <div class="stat-label">过号率</div>
          <div class="stat-value rate">{{ stats.skippedRate }}<span class="stat-unit">%</span></div>
        </div>
      </div>
    </div>
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
          <el-option value="">全部状态</el-option>
          <el-option value="1">等待中</el-option>
          <el-option value="2">已叫号</el-option>
          <el-option value="4">已入座</el-option>
          <el-option value="3">已过号</el-option>
          <el-option value="5">已取消</el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="人数：">
        <el-input v-model="partySize" placeholder="请输入用餐人数" style="width:130px;" @keyup.enter="loadQueueData" />
      </el-form-item>
      <el-form-item>
        <el-input v-model="searchKeyword" placeholder="搜索手机号/姓名..." clearable @keyup.enter="loadQueueData" style="width:200px;" />
      </el-form-item>
      <el-form-item class="action-buttons">
        <el-button type="primary" style="background-color: #22A2B6;" @click="loadQueueData">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button @click="showAddQueueModal = true">新增排队</el-button>
      </el-form-item>
    </el-form>

    <!-- 排队列表区域 -->
    <div class="table-list">
      <el-table :data="queueList" border style="width: 100%;height: 48vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="queue_no" label="排队号" align="center" width="100" >
          <!-- <template #default="scope">
            <el-tag type="primary">{{ scope.row.queue_no }}</el-tag>
          </template> -->
        </el-table-column>
        <!-- <el-table-column prop="customerName" label="姓名" align="center" />
        <el-table-column prop="phone" label="手机号" align="center">
          <template #default="scope">
            {{ formatPhone(scope.row.phone) }}
          </template>
        </el-table-column> -->
        <el-table-column prop="party_size" label="用餐人数" align="center" width="100" >
          <!-- <template #default="scope">
            <el-tag>{{ scope.row.party_size }}</el-tag>
          </template> -->
        </el-table-column>
        <el-table-column prop="createTime" label="排队时间" align="center">
          <template #default="scope">
            {{ dayjs(scope.row.createTime).format('YYYY-MM-DD HH:mm') }}
          </template>
        </el-table-column>
        <el-table-column prop="waitTime" label="等待时长" align="center">
          <template #default="scope">
            <span :style="{ color: scope.row.waitTime > 30 ? '#FF4D4F' : '' }">{{ scope.row.waitTime }}分钟</span>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" align="center">
          <template #default="scope">
            {{ scope.row.remark || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag
              effect="plain"
              :type="scope.row.status === 1 ? 'info'
                : scope.row.status === 2 ? 'info'
                : scope.row.status === 4 ? 'success'
                : scope.row.status === 3 ? 'danger'
                : scope.row.status === 5 ? 'danger'
                : undefined"
              class="custom-status-tag"
            >
              {{ statusMap[scope.row.status] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="250">
          <template #default="scope">
            <span
              class="table-action call"
              @click="callQueue1(scope.row)"
              :style="{ color: scope.row.status === 1 ? '#22A2B6' : '#ccc', cursor: scope.row.status === 1 ? 'pointer' : 'not-allowed' }"
              :aria-disabled="scope.row.status !== 1"
            >叫号</span>
            <span class="table-action-divider">|</span>
            <span
              class="table-action skip"
              @click="skipQueue1(scope.row)"
              :style="{ color: [1,2].includes(scope.row.status) ? '#22A2B6' : '#ccc', cursor: [1,2].includes(scope.row.status) ? 'pointer' : 'not-allowed' }"
              :aria-disabled="![1,2].includes(scope.row.status)"
            >过号</span>
            <span class="table-action-divider">|</span>
            <span
              class="table-action cancel"
              @click="cancelQueue1(scope.row)"
              :style="{ color: [1,2].includes(scope.row.status) ? '#22A2B6' : '#ccc', cursor: [1,2].includes(scope.row.status) ? 'pointer' : 'not-allowed' }"
              :aria-disabled="![1,2].includes(scope.row.status)"
            >删除</span>
          </template>
        </el-table-column>
      </el-table>
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
      <el-form :model="newQueue" :rules="addQueueRules" ref="addQueueFormRef" label-width="120px">
        <el-form-item label="门店" prop="storeId" required>
          <el-select v-model="newQueue.storeId" placeholder="请选择门店">
            <el-option value="">请选择门店</el-option>
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="姓名" prop="customerName" required>
          <el-input v-model="newQueue.customerName" placeholder="请输入顾客姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone" required>
          <el-input v-model="newQueue.phone" placeholder="请输入顾客手机号" />
        </el-form-item>
        <el-form-item label="用餐人数" prop="partySize" required>
          <el-input v-model.number="newQueue.partySize" type="number" min="1" placeholder="请输入用餐人数" />
        </el-form-item>
        <!-- <el-form-item label="是否会员">
          <el-radio-group v-model="newQueue.isMember">
            <el-radio :label="'1'">是</el-radio>
            <el-radio :label="'0'">否</el-radio>
          </el-radio-group>
        </el-form-item> -->
        <el-form-item label="备注">
          <el-input type="textarea" v-model="newQueue.notes" placeholder="请输入特殊需求（如靠窗、不要辣等）" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddQueueModal = false">取消</el-button>
        <el-button type="primary" @click="handleAddQueue">确认添加</el-button>
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
import { ref, onMounted, watch, onUnmounted } from 'vue';
import {
  ElSelect, ElOption, ElInput, ElButton, ElTable, ElTableColumn,
  ElPagination, ElTag, ElDialog, ElForm, ElFormItem, ElRadioGroup, ElRadio, ElEmpty, ElMessage,
} from 'element-plus';
import { getStoreList } from '../../../../api/login';
import {
  getQueuePageList,
  getQueueStats,
  addQueue,
  callQueue,
  skipQueue,
  cancelQueue
} from '../../../../api/queue';
import dayjs from 'dayjs';

// 状态映射，类型安全
const statusMap: Record<any['status'], string> = {
  1: '等待中',
  2: '已叫号',
  4: '已入座',
  3: '已过号',
  5: '已取消'
};

// 门店列表

interface Store {
  id: string;
  name: string;
}
// interface QueueItem {
//   queue_id: string;
//   queueNumber: string;
//   customerName: string;
//   phone: string;
//   partySize:  number;
//   createTime: string;
//   waitTime: number;
//   notes?: string;
//   status: string;
// }

const storeList = ref<Store[]>([]);
const selectedStore = ref('');
const queueStatus = ref('');
const partySize = ref('');
const searchKeyword = ref('');

// 分页参数
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 排队列表数据
const queueList = ref<any[]>([]);
const stats = ref({
  waitingCount: 0,
  averageWaitTime: 0,
  totalToday: 0,
  skippedRate: 0
});

// 弹窗状态
const showAddQueueModal = ref(false);
const showAssignTableModal = ref(false);
const currentQueue = ref<any | null>(null);
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

const addQueueFormRef = ref();
const addQueueRules = {
  storeId: [{ required: true, message: '请选择门店', trigger: 'change' }],
  customerName: [{ required: true, message: '请输入顾客姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
};

// 加载排队数据
const loadQueueData = async () => {
  const res:any = await getQueuePageList({
    page: currentPage.value,
    size: pageSize.value,
    storeId: selectedStore.value,
    status: queueStatus.value,
    partySize: partySize.value,
    keyword: searchKeyword.value
  });
  if (res.success) {
    queueList.value = res.response;
    queueList.value.forEach(item => {
      const waitMinutes = Math.floor((Date.now() - new Date(item.queue_time).getTime()) / 60000);
      item.waitTime = waitMinutes >= 0 ? waitMinutes : 0;
    });
    total.value = res.count;
  }
  const statsRes:any = await getQueueStats({ storeId: selectedStore.value });
  if (statsRes.success) {
    stats.value = statsRes.response;
  }
};

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



// 叫号操作
const callQueue1 = async (queue: any) => {
  console.log(queue);
  if (queue.status !== 1) return;
  const res:any = await callQueue({ queueId: queue.queue_id });
  if (res.success) {
    ElMessage.success('已叫号');
    loadQueueData();
  } else {
    ElMessage.error(res.message || '叫号失败');
  }
};

// 安排桌台
const assignTable = async (queue: any) => {
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
const skipQueue1 = async (queue: any) => {
  if (![1,2].includes(queue.status)) return;
  const res:any = await skipQueue({ queueId: queue.queue_id });
  if (res.success) {
    ElMessage.success('已过号');
    loadQueueData();
  } else {
    ElMessage.error(res.message || '过号失败');
  }
};

// 取消排队
const cancelQueue1 = async (queue: any) => {
  if (![1,2].includes(queue.status)) return;
  const res:any = await cancelQueue({ queueId: queue.queue_id });
  if (res.success) {
    ElMessage.success('已取消');
    loadQueueData();
  } else {
    ElMessage.error(res.message || '取消失败');
  }
};

// 保存新增排队
const handleAddQueue = () => {
  addQueueFormRef.value?.validate(async (valid: boolean) => {
    if (!valid) return;
    const res:any = await addQueue({
      store_id: newQueue.value.storeId,
      customer_name: newQueue.value.customerName,
      customer_phone: newQueue.value.phone,
      party_size: Number(newQueue.value.partySize),
      status: 1,
      remark: newQueue.value.notes || ''
    });
    if (res.success) {
      ElMessage.success('新增排队成功');
      showAddQueueModal.value = false;
      loadQueueData();
    } else {
      ElMessage.error(res.message || '新增失败');
    }
  });
};

// 格式化手机号
const formatPhone = (phone?: string) => {
  if (!phone) return '';
  return phone.replace(/(\d{3})(\d{4})(\d{4})/, '$1****$3');
};


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
let refreshTimer: number | undefined;
// 页面加载时初始化
onMounted(() => {
  fetchStoreList();
  loadQueueData();
    refreshTimer = window.setInterval(() => {
    loadQueueData();
  }, 30000);
});

onUnmounted(() => {
  if (refreshTimer) clearInterval(refreshTimer);
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
  justify-content: flex-end;
  gap: 8px;
  /* width: 100%; */
  margin-left: auto;
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
  gap: 18px;
  margin-bottom: 18px;
}
.stat-card {
  position: relative;
  flex: 1;
  min-width: 180px;
  height: 110px;
  background: #fff;
  border-radius: 12px;
  border: 1.5px dashed #bfc7d1;
  box-shadow: none;
  padding: 18px 18px 12px 24px;
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  overflow: hidden;
    background-repeat: no-repeat;
  background-size: cover;      /* 保证图片铺满卡片且不超出 */
  background-position: center; /* 图片居中显示 */
}
.stat-content {
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  height: 100%;
}
.stat-label {
  font-size: 16px;
  color: #222;
  margin-bottom: 2px;
  font-weight: 500;
}
.stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 2px;
  margin-top: 2px;
  letter-spacing: 1px;
}
.stat-value.waiting { color: #165dff; }
.stat-value.time { color: #faad14; }
.stat-value.total { color: #ff4d4f; }
.stat-value.rate { color: #22a2b6; }
.stat-unit {
  font-size: 16px;
  font-weight: normal;
  margin-left: 2px;
  color: #faad14;
}
.stat-desc {
  font-size: 13px;
  color: #888;
  margin-top: 2px;
}
.stat-bg-img {
  position: absolute;
  top: 16px;
  right: 18px;
  width: 54px;
  height: 54px;
  background-repeat: no-repeat;
  background-size: contain;
  background-position: center;
  border: 1.5px dashed #bfc7d1;
  border-radius: 8px;
  z-index: 1;
}
.stat-card.stat-waiting { background-image: url('/src/assets/等待.png'); }
.stat-card.stat-time { background-image: url('/src/assets/等待时间.png');}
.stat-card.stat-total { background-image: url('/src/assets/排队.png'); }
.stat-card.stat-rate { background-image: url('/src/assets/过号率.png');}

@media (max-width: 1200px) {
  .stats-container {
    flex-wrap: wrap;
  }
  .stat-card {
    flex: 1 1 45%;
  }
}
@media (max-width: 768px) {
  .stats-container {
    flex-direction: column;
    gap: 12px;
  }
  .stat-card {
    min-width: 100%;
    height: auto;
  }
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
.el-table {
  /* border: 1.5px dashed #bfc7d1 !important; */
  border-radius: 8px !important;
  background: #fff !important;
  box-shadow: none !important;
}

.el-table th {
  background: #f8f9fa !important;
  color: #222 !important;
  font-size: 16px !important;
  font-weight: 600 !important;
  border-bottom: 1.5px dashed #bfc7d1 !important;
  height: 48px !important;
}

.el-table td {
  font-size: 15px !important;
  color: #222 !important;
  border-bottom: 1px solid #f0f3fa !important;
  height: 44px !important;
}

.el-table__body tr {
  height: 48px !important;
}

.el-table__header tr {
  height: 48px !important;
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
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    width: 100%;
   margin-left: auto;
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
    width: 90%
  }
}
.table-action {
  font-size: 15px;
  color: #22A2B6;
  cursor: pointer;
  padding: 0 6px;
  transition: color 0.2s;
  background: none;
  border: none;
  outline: none;
}
.table-action:hover {
  color: #165dff;
  text-decoration: underline;
}
.table-action[disabled] {
  color: #ccc !important;
  cursor: not-allowed !important;
  text-decoration: none;
}
.table-action-divider {
  color: #bbb;
  margin: 0 2px;
}

.custom-status-tag {
  border-radius: 8px !important;
  font-size: 16px !important;
  padding: 4px 18px !important;
  font-weight: 500;
  background: #fff !important;
  border-width: 2px !important;
}
.el-tag--plain.el-tag--success {
  color: #22b26b !important;
  border-color: #22b26b !important;
  background: #E2FFE3 !important;
}
.el-tag--plain.el-tag--info {
  color: #409eff !important;
  border-color: #409eff !important;
  background: #E5E9FF !important;
}
.el-tag--plain.el-tag--danger {
  color: #ff4d4f !important;
  border-color: #ff4d4f !important;
  background: #FFEFED !important;
}
</style>
