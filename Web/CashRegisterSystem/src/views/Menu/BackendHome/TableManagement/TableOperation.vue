<template>
  <div class="table-operation-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">{{ operationType === 'transfer' ? '转桌操作' : '并桌操作' }}</h2>
      <button class="close-btn" @click="closeModal">
        <i class="fa fa-times"></i>
      </button>
    </div>
    
    <!-- 操作表单 -->
    <div class="operation-form">
      <!-- 源桌台信息 -->
      <div class="form-section">
        <h3 class="section-title">源桌台信息</h3>
        <div class="table-info-card" :class="'status-' + sourceTable.status">
          <div class="table-basic">
            <div class="table-number">{{ sourceTable.tableNo }}</div>
            <div class="table-status">
              <span :class="['status-tag', sourceTable.status]">
                {{ statusMap[sourceTable.status as 1 | 2 | 3 | 4] }}
              </span>
            </div>
          </div>
          <div class="table-details">
            <div class="detail-item">类型：{{ sourceTable.tableType }}</div>
            <div class="detail-item">容量：{{ sourceTable.capacity }}人</div>
            <div class="detail-item">最低消费：¥{{ sourceTable.minConsumption }}</div>
          </div>
          
          <!-- 源桌台订单信息 -->
          <div class="order-info" v-if="sourceTable.status === 2 && currentOrder">
            <div class="order-title">当前订单：{{ currentOrder.orderNo }}</div>
            <div class="order-details">
              <div class="detail-item">开单时间：{{ formatDateTime(currentOrder.startTime) }}</div>
              <div class="detail-item">人数：{{ currentOrder.partySize }}人</div>
              <div class="detail-item">金额：¥{{ currentOrder.totalAmount }}</div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 目标桌台选择（转桌） -->
      <div class="form-section" v-if="operationType === 'transfer'">
        <h3 class="section-title">目标桌台选择</h3>
        <div class="target-table-selector">
          <select v-model="targetTableId" class="table-select" @change="handleTargetTableChange">
            <option value="">请选择目标桌台</option>
            <option 
              v-for="table in availableTables" 
              :key="table.tableId" 
              :value="table.tableId"
              :disabled="table.tableId === sourceTable.tableId"
            >
              {{ table.tableNo }}（{{ table.tableType }}，{{ table.capacity }}人）
            </option>
          </select>
          
          <div v-if="targetTable" class="target-table-preview">
            <div class="preview-title">选中桌台信息：</div>
            <div class="table-info-card" :class="'status-' + statusTextMap[targetTable.status as 1 | 2 | 3 | 4]">
              <div class="table-number">{{ targetTable.tableNo }}</div>
              <div class="table-details">
                <div class="detail-item">类型：{{ targetTable.tableType }}</div>
                <div class="detail-item">容量：{{ targetTable.capacity }}人</div>
                <div class="detail-item">状态：
                  <span :class="['status-tag', statusTextMap[targetTable.status as 1 | 2 | 3 | 4]]">
                    {{ statusMap[targetTable.status as 1 | 2 | 3 | 4] }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 并桌选择（并桌） -->
      <div class="form-section" v-if="operationType === 'merge'">
        <h3 class="section-title">选择合并桌台（可多选）</h3>
        <div class="merge-table-selector">
          <div class="table-checkbox-group">
            <label class="table-checkbox-item" v-for="table in availableTables" :key="table.tableId">
              <input 
                type="checkbox" 
                :value="table.tableId" 
                v-model="selectedMergeTableIds"
                :disabled="table.tableId === sourceTable.tableId || table.status !== 1"
              >
              <span class="table-label">
                {{ table.tableNo }}（{{ table.capacity }}人，{{ table.tableType }}）
              </span>
            </label>
          </div>
          
          <div class="merge-info" v-if="selectedMergeTableIds.length">
            <div class="merge-count">已选择 {{ selectedMergeTableIds.length }} 个桌台</div>
            <div class="total-capacity">合并后总容量：{{ totalMergeCapacity }} 人</div>
          </div>
        </div>
      </div>
      
      <!-- 操作原因 -->
      <div class="form-section">
        <h3 class="section-title">操作原因</h3>
        <textarea 
          v-model="operationReason" 
          class="reason-input" 
          placeholder="请输入转桌/并桌原因（如：顾客要求、容量不足等）"
          rows="3"
        ></textarea>
      </div>
      
      <!-- 操作按钮 -->
      <div class="operation-buttons">
        <button class="btn cancel-btn" @click="closeModal">取消</button>
        <button 
          class="btn confirm-btn" 
          @click="confirmOperation"
          :disabled="!canConfirmOperation || loading"
        >
          <i class="fa fa-spinner fa-spin" v-if="loading"></i>
          {{ operationType === 'transfer' ? '确认转桌' : '确认并桌' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, watch, onMounted } from 'vue';
// import { getAvailableTables, getTableOrder, transferTable, mergeTables } from '@/api/table';
// import { formatDateTime } from '@/utils/date';

// 状态映射（对应表结构中的status字段值）
const statusMap = ref({
  1: '空闲',
  2: '占用',
  3: '预订',
  4: '清洁中'
});

// 状态文本映射（用于CSS类名）
const statusTextMap = ref({
  1: 'available',
  2: 'occupied',
  3: 'reserved',
  4: 'maintenance'
});

// 接收父组件参数
const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  sourceTable: {
    type: Object,
    required: true,
    default: () => ({
      tableId: 0,
      tableNo: '',
      capacity: 0,
      tableType: '',
      status: 1
    })
  },
  operationType: {
    type: String,
    default: 'transfer', // 'transfer' 转桌, 'merge' 并桌
    validator: (value: string) => ['transfer', 'merge'].includes(value)
  },
  storeId: {
    type: Number,
    required: true
  }
});

// 暴露事件
const emit = defineEmits(['close', 'success']);

// 转桌相关变量
const targetTableId = ref('');
const targetTable = ref<any>(null);
const availableTables = ref<any[]>([]);

// 并桌相关变量
const selectedMergeTableIds = ref<number[]>([]);
const totalMergeCapacity = computed(() => {
  const selectedTables = availableTables.value.filter(t => 
    selectedMergeTableIds.value.includes(t.tableId)
  );
  return selectedTables.reduce((sum, table) => sum + table.capacity, props.sourceTable.capacity);
});

// 订单信息
const currentOrder = ref<any>(null);

// 通用变量
const operationReason = ref('');
const loading = ref(false);

// 检查是否可以确认操作
const canConfirmOperation = computed(() => {
  if (!operationReason.value.trim()) return false;
  
  if (props.operationType === 'transfer') {
    return !!targetTableId.value && targetTable.value?.status === 1;
  } else {
    return selectedMergeTableIds.value.length > 0;
  }
});

// 加载可用桌台
const loadAvailableTables = async () => {
//   try {
//     const params = {
//       storeId: props.storeId,
//       status: 1, // 只查询空闲桌台
//       excludeTableId: props.sourceTable.tableId
//     };
    
//     const response = await getAvailableTables(params);
//     availableTables.value = response.data || [];
//   } catch (error) {
//     console.error('加载可用桌台失败:', error);
//     alert('加载可用桌台失败，请重试');
//   }
};

// 获取源桌台当前订单
const loadTableOrder = async () => {
//   if (props.sourceTable.status === 2) { // 占用状态才加载订单
//     try {
//       const response = await getTableOrder({
//         tableId: props.sourceTable.tableId,
//         storeId: props.storeId
//       });
//       currentOrder.value = response.data || null;
//     } catch (error) {
//       console.error('获取桌台订单失败:', error);
//     }
//   }
};

// 处理目标桌台变化（转桌）
const handleTargetTableChange = () => {
  targetTable.value = availableTables.value.find(t => t.tableId === Number(targetTableId.value)) || null;
};

// 确认操作
const confirmOperation = async () => {
  if (!canConfirmOperation.value) return;
  
  loading.value = true;
//   try {
//     if (props.operationType === 'transfer') {
//       // 转桌操作
//       const response = await transferTable({
//         sourceTableId: props.sourceTable.tableId,
//         targetTableId: Number(targetTableId.value),
//         orderId: currentOrder.value?.orderId,
//         reason: operationReason.value,
//         operatorId: localStorage.getItem('userId') || '', // 从本地存储获取操作人ID
//         storeId: props.storeId
//       });
      
//       emit('success', { 
//         type: 'transfer', 
//         result: response.data 
//       });
//       alert('转桌操作成功');
      
//     } else {
//       // 并桌操作
//       const response = await mergeTables({
//         mainTableId: props.sourceTable.tableId,
//         mergeTableIds: selectedMergeTableIds.value,
//         orderId: currentOrder.value?.orderId,
//         reason: operationReason.value,
//         operatorId: localStorage.getItem('userId') || '',
//         storeId: props.storeId
//       });
      
//       emit('success', { 
//         type: 'merge', 
//         result: response.data 
//       });
//       alert('并桌操作成功');
//     }
//   } catch (error: any) {
//     console.error('操作失败:', error);
//     alert(`操作失败：${error.response?.data?.message || '系统错误'}`);
//   } finally {
//     loading.value = false;
//   }
};

// 关闭弹窗
const closeModal = () => {
  emit('close');
};

// 监听props变化
watch(() => props.visible, (newVal) => {
  if (newVal) {
    loadAvailableTables();
    loadTableOrder();
    // 重置表单
    targetTableId.value = '';
    targetTable.value = null;
    selectedMergeTableIds.value = [];
    operationReason.value = '';
  }
});

watch(() => props.operationType, () => {
  if (props.visible) {
    loadAvailableTables();
    selectedMergeTableIds.value = [];
  }
});

// 工具函数：格式化日期时间
const formatDateTime = (dateStr: string) => {
//   return formatDateTime1(dateStr);
};
</script>

<style scoped>
/* 样式保持不变，与原代码一致 */
.table-operation-container {
  width: 600px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #F2F3F5;
  background-color: #F5F7FA;
}

.page-title {
  font-size: 18px;
  color: #1D2129;
  margin: 0;
  font-weight: 600;
}

.close-btn {
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
  transition: all 0.2s;
}

.close-btn:hover {
  background-color: #E8EBF0;
  color: #1D2129;
}

.operation-form {
  padding: 20px;
}

.form-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 16px;
  color: #1D2129;
  margin: 0 0 12px 0;
  font-weight: 500;
  padding-bottom: 8px;
  border-bottom: 1px solid #F2F3F5;
}

.table-info-card {
  background-color: #F5F7FA;
  border-radius: 6px;
  padding: 16px;
  border-left: 4px solid transparent;
}

.table-info-card.status-available {
  border-left-color: #52C41A;
}

.table-info-card.status-occupied {
  border-left-color: #FF4D4F;
}

.table-info-card.status-reserved {
  border-left-color: #FAAD14;
}

.table-info-card.status-maintenance {
  border-left-color: #86909C;
}

.table-basic {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.table-number {
  font-size: 18px;
  font-weight: 600;
  color: #1D2129;
}

.table-details {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 12px;
}

.detail-item {
  font-size: 14px;
  color: #4E5969;
  display: flex;
  align-items: center;
  gap: 4px;
}

.order-info {
  background-color: rgba(22, 93, 255, 0.05);
  border-radius: 4px;
  padding: 12px;
  margin-top: 12px;
}

.order-title {
  font-size: 14px;
  font-weight: 500;
  color: #165DFF;
  margin-bottom: 8px;
}

.order-details {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.target-table-selector, .merge-table-selector {
  background-color: #F5F7FA;
  border-radius: 6px;
  padding: 16px;
}

.table-select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  background-color: #fff;
  font-size: 14px;
  color: #1D2129;
  margin-bottom: 16px;
}

.target-table-preview {
  margin-top: 16px;
}

.preview-title {
  font-size: 14px;
  color: #4E5969;
  margin-bottom: 8px;
  font-weight: 500;
}

.table-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}

.table-checkbox-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background-color: #fff;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.table-checkbox-item:hover {
  border-color: #165DFF;
}

.table-checkbox-item input:checked + .table-label {
  color: #165DFF;
  font-weight: 500;
}

.table-label {
  font-size: 14px;
  color: #4E5969;
}

.merge-info {
  padding: 12px;
  background-color: rgba(22, 93, 255, 0.05);
  border-radius: 4px;
  margin-top: 12px;
}

.merge-count, .total-capacity {
  font-size: 14px;
  color: #165DFF;
  margin-bottom: 4px;
}

.reason-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  font-size: 14px;
  color: #1D2129;
  resize: none;
}

.reason-input:focus {
  outline: none;
  border-color: #165DFF;
}

.operation-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
}

.btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.cancel-btn {
  background-color: #fff;
  color: #1D2129;
  border: 1px solid #DCDFE6;
}

.cancel-btn:hover {
  background-color: #F5F7FA;
}

.confirm-btn {
  background-color: #165DFF;
  color: #fff;
  border: 1px solid #165DFF;
}

.confirm-btn:hover {
  background-color: #0E42D2;
}

.confirm-btn:disabled {
  background-color: #8CC1FF;
  border-color: #8CC1FF;
  cursor: not-allowed;
}

.status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status-tag.available {
  background-color: rgba(82, 196, 26, 0.1);
  color: #52C41A;
}

.status-tag.occupied {
  background-color: rgba(255, 77, 79, 0.1);
  color: #FF4D4F;
}

.status-tag.reserved {
  background-color: rgba(250, 173, 20, 0.1);
  color: #FAAD14;
}

.status-tag.maintenance {
  background-color: rgba(134, 144, 156, 0.1);
  color: #86909C;
}
</style>