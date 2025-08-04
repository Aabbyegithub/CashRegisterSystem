<template>
  <div class="queue-list-container">
    <!-- 页面标题和操作区 -->
    <div class="page-header">      
      <div class="header-controls">
        <!-- 筛选器 -->
        <div class="filter-bar">
          <div class="filter-item">
            <label class="filter-label">门店:</label>
            <select v-model="selectedStore" class="filter-select" @change="loadQueueData">
              <option value="">全部门店</option>
              <option v-for="store in storeList" :key="store.id" :value="store.id">{{ store.name }}</option>
            </select>
          </div>
          
          <div class="filter-item">
            <label class="filter-label">状态:</label>
            <select v-model="queueStatus" class="filter-select" @change="loadQueueData">
              <option value="all">全部状态</option>
              <option value="waiting">等待中</option>
              <option value="called">已叫号</option>
              <option value="seated">已入座</option>
              <option value="skipped">已过号</option>
              <option value="cancelled">已取消</option>
            </select>
          </div>
          
          <div class="filter-item">
            <label class="filter-label">人数:</label>
            <select v-model="partySize" class="filter-select" @change="loadQueueData">
              <option value="">不限</option>
              <option value="1-2">1-2人</option>
              <option value="3-4">3-4人</option>
              <option value="5-6">5-6人</option>
              <option value="7+">7人以上</option>
            </select>
          </div>
          
          <div class="search-box">
            <input 
              type="text" 
              v-model="searchKeyword" 
              placeholder="搜索手机号/姓名..." 
              class="search-input"
              @keyup.enter="loadQueueData"
            >
            <button class="search-btn" @click="loadQueueData">
              <i class="fa fa-search"></i>
            </button>
          </div>
        </div>
        
        <!-- 操作按钮 -->
        <div class="action-buttons">
          <button class="btn primary-btn" @click="showAddQueueModal = true">
            <i class="fa fa-plus"></i> 新增排队
          </button>
          <button class="btn refresh-btn" @click="loadQueueData">
            <i class="fa fa-refresh"></i> 刷新
          </button>
        </div>
      </div>
    </div>
    
    <!-- 排队统计 -->
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
    
    <!-- 排队列表 -->
    <div class="queue-table-container">
      <table class="queue-table">
        <thead>
          <tr>
            <th class="table-header">序号</th>
            <th class="table-header">排队号</th>
            <th class="table-header">姓名</th>
            <th class="table-header">手机号</th>
            <th class="table-header">人数</th>
            <th class="table-header">排队时间</th>
            <th class="table-header">等待时长</th>
            <th class="table-header">备注</th>
            <th class="table-header">状态</th>
            <th class="table-header">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in queueList" :key="item.id" :class="['queue-item', item.status]">
            <td class="table-cell">{{ index + 1 }}</td>
            <td class="table-cell">
              <div class="queue-number">{{ item.queueNumber }}</div>
            </td>
            <td class="table-cell">{{ item.customerName }}</td>
            <td class="table-cell">{{ formatPhone(item.phone) }}</td>
            <td class="table-cell">
              <span class="people-count">{{ item.partySize }}</span>
            </td>
            <td class="table-cell">{{ formatDateTime(item.createTime) }}</td>
            <td class="table-cell">
              <span :class="{'overtime': item.waitTime > 30}">{{ item.waitTime }}分钟</span>
            </td>
            <td class="table-cell">{{ item.notes || '-' }}</td>
            <td class="table-cell">
              <span :class="['status-tag', item.status]">
                {{ statusMap[item.status] }}
              </span>
            </td>
            <td class="table-cell">
              <div class="operation-buttons">
                <button 
                  class="btn action-btn call-btn" 
                  @click="callQueue(item)"
                  :disabled="item.status !== 'waiting'"
                >
                  叫号
                </button>
                
                <button 
                  class="btn action-btn assign-btn" 
                  @click="assignTable(item)"
                  :disabled="!['waiting', 'called'].includes(item.status)"
                >
                  安排桌台
                </button>
                
                <button 
                  class="btn action-btn skip-btn" 
                  @click="skipQueue(item)"
                  :disabled="!['waiting', 'called'].includes(item.status)"
                >
                  过号
                </button>
                
                <button 
                  class="btn action-btn cancel-btn" 
                  @click="cancelQueue(item)"
                  :disabled="!['waiting', 'called'].includes(item.status)"
                >
                  取消
                </button>
              </div>
            </td>
          </tr>
          
          <tr v-if="queueList.length === 0" class="empty-row">
            <td colspan="10" class="empty-cell">
              <div class="empty-state">
                <i class="fa fa-inbox"></i>
                <div class="empty-text">当前没有排队记录</div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- 分页 -->
    <div class="pagination" v-if="total > 0">
      <div class="pagination-info">
        共 {{ total }} 条记录，当前第 {{ currentPage }} / {{ totalPages }} 页
      </div>
      <div class="pagination-controls">
        <button 
          class="page-btn" 
          @click="currentPage = 1" 
          :disabled="currentPage === 1"
        >
          首页
        </button>
        <button 
          class="page-btn" 
          @click="currentPage--" 
          :disabled="currentPage === 1"
        >
          上一页
        </button>
        <button 
          class="page-btn" 
          @click="currentPage++" 
          :disabled="currentPage === totalPages"
        >
          下一页
        </button>
        <button 
          class="page-btn" 
          @click="currentPage = totalPages" 
          :disabled="currentPage === totalPages"
        >
          末页
        </button>
      </div>
    </div>
    
    <!-- 新增排队弹窗 -->
    <div class="modal-backdrop" v-if="showAddQueueModal">
      <div class="modal-dialog">
        <div class="modal-header">
          <h3 class="modal-title">新增排队</h3>
          <button class="modal-close" @click="showAddQueueModal = false">
            <i class="fa fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">门店 <span class="required">*</span></label>
            <select v-model="newQueue.storeId" class="form-control" required>
              <option value="">请选择门店</option>
              <option v-for="store in storeList" :key="store.id" :value="store.id">{{ store.name }}</option>
            </select>
          </div>
          
          <div class="form-group">
            <label class="form-label">姓名 <span class="required">*</span></label>
            <input 
              type="text" 
              v-model="newQueue.customerName" 
              class="form-control" 
              placeholder="请输入顾客姓名"
              required
            >
          </div>
          
          <div class="form-group">
            <label class="form-label">手机号 <span class="required">*</span></label>
            <input 
              type="tel" 
              v-model="newQueue.phone" 
              class="form-control" 
              placeholder="请输入顾客手机号"
              required
            >
          </div>
          
          <div class="form-group">
            <label class="form-label">用餐人数 <span class="required">*</span></label>
            <select v-model="newQueue.partySize" class="form-control" required>
              <option value="">请选择人数</option>
              <option value="1">1人</option>
              <option value="2">2人</option>
              <option value="3">3人</option>
              <option value="4">4人</option>
              <option value="5">5人</option>
              <option value="6">6人</option>
              <option value="7">7人</option>
              <option value="8">8人以上</option>
            </select>
          </div>
          
          <div class="form-group">
            <label class="form-label">是否会员</label>
            <div class="radio-group">
              <label class="radio-item">
                <input type="radio" v-model="newQueue.isMember" value="1"> 是
              </label>
              <label class="radio-item">
                <input type="radio" v-model="newQueue.isMember" value="0" checked> 否
              </label>
            </div>
          </div>
          
          <div class="form-group">
            <label class="form-label">备注</label>
            <textarea 
              v-model="newQueue.notes" 
              class="form-control" 
              placeholder="请输入特殊需求（如靠窗、不要辣等）"
              rows="3"
            ></textarea>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="btn modal-btn cancel-btn" @click="showAddQueueModal = false">取消</button>
          <button class="btn modal-btn confirm-btn" @click="saveNewQueue">确认添加</button>
        </div>
      </div>
    </div>
    
    <!-- 安排桌台弹窗 -->
    <div class="modal-backdrop" v-if="showAssignTableModal">
      <div class="modal-dialog">
        <div class="modal-header">
          <h3 class="modal-title">安排桌台 - {{ currentQueue?.queueNumber }}</h3>
          <button class="modal-close" @click="showAssignTableModal = false">
            <i class="fa fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body">
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
            <div class="table-selector">
              <label class="table-option" v-for="table in availableTables" :key="table.id">
                <input 
                  type="radio" 
                  v-model="selectedTableId" 
                  :value="table.id"
                  :disabled="table.capacity < currentQueue.partySize"
                >
                <div class="table-info">
                  <div class="table-name">{{ table.number }}</div>
                  <div class="table-desc">
                    {{ table.shape === 'round' ? '圆桌' : table.shape === 'square' ? '方桌' : '长桌' }}，
                    {{ table.capacity }}人，{{ table.areaName }}
                  </div>
                </div>
              </label>
            </div>
            
            <div class="no-tables" v-if="availableTables.length === 0">
              当前没有可用桌台，请稍后再试
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="btn modal-btn-btn" @click="showAssignTableModal = false">取消</button>
          <button 
            class="btn confirm-btn" 
            @click="confirmAssignTable"
            :disabled="!selectedTableId"
          >
            确认安排
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, watch } from 'vue';
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

// 状态映射
const statusMap = {
  'waiting': '等待中',
  'called': '已叫号',
  'seated': '已入座',
  'skipped': '已过号',
  'cancelled': '已取消'
};

// 门店列表
const storeList = ref([]);
const selectedStore = ref('');
const queueStatus = ref('all');
const partySize = ref('');
const searchKeyword = ref('');

// 分页参数
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const totalPages = computed(() => Math.ceil(total.value / pageSize.value));

// 排队列表数据
const queueList = ref([]);
const stats = ref({
  waitingCount: 0,
  averageWaitTime: 0,
  totalToday: 0,
  skippedRate: 0
});

// 弹窗状态
const showAddQueueModal = ref(false);
const showAssignTableModal = ref(false);
const currentQueue = ref();
const availableTables = ref([]);
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

// 加载排队数据
const loadQueueData = async () => {
//   try {
//     const params = {
//       storeId: selectedStore.value,
//       status: queueStatus.value !== 'all' ? queueStatus.value : '',
//       partySize: partySize.value,
//       keyword: searchKeyword.value,
//       page: currentPage.value,
//       pageSize: pageSize.value
//     };
    
//     const response = await fetchQueueList(params);
//     queueList.value = response.list || [];
//     total.value = response.total || 0;
    
//     // 加载统计数据
//     if (selectedStore.value) {
//       const statsData = await fetchQueueStats({ storeId: selectedStore.value });
//       stats.value = statsData;
//     }
//   } catch (error) {
//     console.error('加载排队列表失败:', error);
//     alert('加载排队列表失败，请重试');
//   }
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
const callQueue = async (queue:any) => {
//   if (confirm(`确定要呼叫 ${queue.queueNumber} 号 ${queue.customerName} 吗？`)) {
//     try {
//       await updateQueueStatus({
//         id: queue.id,
//         status: 'called',
//         operatorId: localStorage.getItem('userId') || ''
//       });
//       loadQueueData();
//       // 可以在这里添加语音叫号功能
//       alert(`已呼叫 ${queue.queueNumber} 号，请顾客到前台`);
//     } catch (error) {
//       console.error('叫号操作失败:', error);
//       alert('叫号操作失败，请重试');
//     }
//   }
};

// 安排桌台
const assignTable = async (queue:any) => {
  currentQueue.value = queue;
  selectedTableId.value = '';
  
//   try {
//     // 加载可用桌台（空闲状态且容量大于等于排队人数）
//     const tables = await fetchAvailableTables({
//       storeId: queue.storeId,
//       minCapacity: queue.partySize
//     });
//     availableTables.value = tables || [];
//     showAssignTableModal.value = true;
//   } catch (error) {
//     console.error('加载可用桌台失败:', error);
//     alert('加载可用桌台失败，请重试');
//   }
};

// 确认安排桌台
const confirmAssignTable = async () => {
  if (!selectedTableId.value || !currentQueue.value) return;
  
//   try {
//     await assignTableApi({
//       queueId: currentQueue.value.id,
//       tableId: selectedTableId.value,
//       operatorId: localStorage.getItem('userId') || ''
//     });
//     showAssignTableModal.value = false;
//     loadQueueData();
//     alert(`已为 ${currentQueue.value.queueNumber} 号安排桌台`);
//   } catch (error) {
//     console.error('安排桌台失败:', error);
//     alert('安排桌台失败，请重试');
//   }
};

// 过号操作
const skipQueue = async (queue:any) => {
//   if (confirm(`确定要将 ${queue.queueNumber} 号标记为过号吗？`)) {
//     try {
//       await updateQueueStatus({
//         id: queue.id,
//         status: 'skipped',
//         reason: '过号未到',
//         operatorId: localStorage.getItem('userId') || ''
//       });
//       loadQueueData();
//     } catch (error) {
//       console.error('过号操作失败:', error);
//       alert('过号操作失败，请重试');
//     }
//   }
};

// 取消排队
const cancelQueue = async (queue:any) => {
//   if (confirm(`确定要取消 ${queue.queueNumber} 号的排队吗？`)) {
//     try {
//       await updateQueueStatus({
//         id: queue.id,
//         status: 'cancelled',
//         reason: '顾客取消',
//         operatorId: localStorage.getItem('userId') || ''
//       });
//       loadQueueData();
//     } catch (error) {
//       console.error('取消排队失败:', error);
//       alert('取消排队失败，请重试');
//     }
//   }
};

// 保存新增排队
const saveNewQueue = async () => {
  // 表单验证
  if (!newQueue.value.storeId || !newQueue.value.customerName || !newQueue.value.phone || !newQueue.value.partySize) {
    alert('请填写必填字段');
    return;
  }
  
//   try {
//     await createQueue({
//       ...newQueue.value,
//       operatorId: localStorage.getItem('userId') || ''
//     });
//     showAddQueueModal.value = false;
//     // 重置表单
//     newQueue.value = {
//       storeId: '',
//       customerName: '',
//       phone: '',
//       partySize: '',
//       isMember: '0',
//       notes: ''
//     };
//     loadQueueData();
//     alert('新增排队成功');
//   } catch (error) {
//     console.error('新增排队失败:', error);
//     alert('新增排队失败，请重试');
//   }
};

// 格式化手机号
const formatPhone = (phone:string) => {
  if (!phone) return '';
  return phone.replace(/(\d{3})(\d{4})(\d{4})/, '$1****$3');
};

// 格式化日期时间
const formatDateTime = (dateStr:string) => {
//   return formatDateTimeUtil(dateStr);
};

// 监听分页变化
watch(currentPage, loadQueueData);

// 页面加载时初始化
onMounted(() => {
  loadStores();
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
