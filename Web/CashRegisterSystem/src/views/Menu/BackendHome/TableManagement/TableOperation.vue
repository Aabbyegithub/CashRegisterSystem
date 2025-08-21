<template>
  <el-card class="table-operation-container" shadow="always">
    <div class="operation-main-layout">
      <!-- 左侧：当前桌台选择 + 可用桌台列表 -->
      <el-card class="left-table-info" shadow="never">
        <!-- 当前桌台选择 -->
        <el-form label-width="0" class="current-table-form">
          <el-form-item>
            <div style="display: flex; align-items: center; gap: 8px;">
            <el-select v-model="selectedSourceTableId" placeholder="请选择当前桌台" style="width:300px" @change="handleSourceTableChange">
              <el-option
                v-for="table in allTables"
                :key="table.tableId"
                :label="`${table.tableNo}（${table.tableType}，${table.capacity}人）`"
                :value="table.tableId"
              />
            </el-select>
            <el-button @click="handleMerge" style="width: 200px;background-color: #EAF7F8;">        
                <template #icon>
                    <img 
                    src="/src/assets/Frame-5.png"  
                    alt="并台" 
                    style="width: 15px; height: 15px;" 
                    >
                    <label style="font-style: normal;font-size: 15px;margin-left: 10px;color: #13899C ;">并台</label>
                </template>
            </el-button>
             <el-button  @click="handleChangeTable" style="width: 200px; background-color: #FFE6E7;margin-left: 0px;">
                <template #icon>
                    <img 
                    src="/src/assets/Frame-6.png"  
                    alt="并台" 
                    style="width: 15px; height: 15px;" 
                    >
                    <label style="font-style: normal;font-size: 15px;margin-left: 10px;color: #FF6768 ;">换桌</label>
                </template>
            </el-button>
            </div>
          </el-form-item>
        </el-form>
        <!-- 当前桌台信息卡片 -->
        <el-card v-if="sourceTable" class="table-info-card target-card" shadow="hover">
          <div class="table-number">{{ sourceTable.tableNo }}</div>
          <div class="table-details">
            <span>{{ sourceTable.tableType }}</span>｜<span>{{ sourceTable.capacity }}人</span>
            <span class="status-tag" :class="statusTextMap[Number(sourceTable.status)]">{{ statusMap[Number(sourceTable.status)] }}</span>
            <span class="detail-item">最低消费：¥{{ sourceTable.minConsumption }}</span>
          </div>
          <div class="order-info" v-if="sourceTable.status === 2 && currentOrder">
            <div class="order-title">当前订单：{{ currentOrder.orderNo }}</div>
            <div class="order-details">
              <div class="detail-item">开单时间：{{ formatDateTime(currentOrder.startTime) }}</div>
              <div class="detail-item">人数：{{ currentOrder.partySize }}人</div>
              <div class="detail-item">金额：¥{{ currentOrder.totalAmount }}</div>
            </div>
          </div>
        </el-card>
        <!-- 可用桌台列表 -->
        <div class="available-table-list">
          <div class="list-title">可用桌台列表</div>
          <div class="table-list-flex">
            <div
              v-for="table in availableTables"
              :key="table.tableId"
              class="table-list-card"
              :class="{'selected': isTableSelected(table.tableId)}"
              @click="handleTableSelect(table.tableId)"
            >
              <div class="table-number">{{ table.tableNo }}</div>
              <div class="table-details">
                <span>{{ table.tableType }}</span>｜<span>{{ table.capacity }}人</span>
              </div>
              <span class="status-tag" :class="statusTextMap[Number(table.status)]">{{ statusMap[Number(table.status)] }}</span>
            </div>
          </div>
        </div>
      </el-card>
      <!-- 右侧：目标桌台信息 + 原因填写 -->
      <el-card class="right-operation-area">
        <div class="target-table-info">
          <div class="info-title">更换后桌台信息</div>
          <div v-if="selectedTargetTables.length === 0" class="empty-info">请在左侧选择目标桌台</div>
          <div v-else class="target-table-list">
            <el-card v-for="table in selectedTargetTables" :key="table.tableId" class="table-info-card target-card" shadow="hover">
              <div class="table-number">{{ table.tableNo }}</div>
              <div class="table-details">
                <span>{{ table.tableType }}</span>｜<span>{{ table.capacity }}人</span>
                <span class="status-tag" :class="statusTextMap[Number(table.status)]">{{ statusMap[Number(table.status)] }}</span>
                <span class="detail-item">最低消费：¥{{ table.minConsumption }}</span>
              </div>
            </el-card>
          </div>
        </div>
        <!-- 原因输入 -->
        <el-form :model="form" ref="formRef" label-width="0" class="reason-form">
          <el-form-item prop="operationReason" :rules="[{ required: true, message: '请输入操作原因', trigger: 'blur' }]">
            <el-input
              type="textarea"
              v-model="operationReason"
              :rows="3"
              placeholder="请输入转桌/并桌原因（如：顾客要求、容量不足等）"
              maxlength="100"
              show-word-limit
            />
          </el-form-item>
        </el-form>
        <!-- 底部操作按钮 -->
        <div class="operation-buttons">
          <el-button @click="closeModal">取消</el-button>
          <el-button type="primary" :loading="loading" :disabled="!canConfirmOperation" @click="handleConfirm">
            {{ selectedTargetTables.length > 1 ? '确认并桌' : '确认换桌' }}
          </el-button>
        </div>
      </el-card>
    </div>
  </el-card>
</template>

<script lang="ts" setup>
import { ref, computed, watch, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
// import { getAvailableTables, getTableOrder, transferTable, mergeTables } from '@/api/table';
// import { formatDateTime } from '@/utils/date';

const props = defineProps({
  visible: Boolean,
  sourceTable: {
    type: Object,
    required: true,
    default: () => ({ tableId: 0, tableNo: '', capacity: 0, tableType: '', status: 1 })
  },
  operationType: {
    type: String,
    default: 'transfer',
    validator: (v: string) => ['transfer', 'merge'].includes(v)
  },
  storeId: Number
});
const emit = defineEmits(['close', 'success']);

// 数据与方法
const allTables = ref<any[]>([]); // 所有桌台（用于当前桌台选择）
const availableTables = ref<any[]>([]); // 可用桌台列表
const selectedSourceTableId = ref<number | null>(null); // 当前桌台ID
const sourceTable = ref<any>(null); // 当前桌台对象
const selectedTargetTableIds = ref<number[]>([]); // 目标桌台ID列表
const selectedTargetTables = computed(() => availableTables.value.filter(t => selectedTargetTableIds.value.includes(t.tableId)));
const operationReason = ref('');
const loading = ref(false);
const formRef = ref();
const form = ref({});
const currentOrder = ref<any>(null);

const statusMap: Record<number, string> = {
  1: '空闲',
  2: '占用',
  3: '预订',
  4: '清洁中'
};
const statusTextMap: Record<number, string> = {
  1: 'available',
  2: 'occupied',
  3: 'reserved',
  4: 'maintenance'
};

const isTableSelected = (tableId: number) => selectedTargetTableIds.value.includes(tableId);

const handleSourceTableChange = (tableId: number) => {
  sourceTable.value = allTables.value.find(t => t.tableId === tableId) || null;
  // 切换当前桌台时清空目标桌台选择
  selectedTargetTableIds.value = [];
  loadTableOrder();
};

const handleChangeTable = () => {
  if (!sourceTable.value) {
    ElMessage.warning('请先选择当前桌台');
    return;
  }
};

const handleMerge = () => {
  if (!sourceTable.value) {
    ElMessage.warning('请先选择当前桌台');
    return;
  }
  if (sourceTable.value.status !== 2) {
    ElMessage.warning('只有占用状态的桌台才能进行并台操作');
    return;
  }
  // 切换到并台模式
  selectedTargetTableIds.value = [];
  loadTableOrder();
};

const handleTableSelect = (tableId: number) => {
  // 单选为换桌，多选为并桌
  if (selectedTargetTableIds.value.includes(tableId)) {
    selectedTargetTableIds.value = selectedTargetTableIds.value.filter(id => id !== tableId);
  } else {
    selectedTargetTableIds.value.push(tableId);
  }
};
const canConfirmOperation = computed(() => {
  return operationReason.value.trim() && selectedTargetTableIds.value.length > 0;
});
const handleConfirm = async () => {
  if (!canConfirmOperation.value) return;
  await formRef.value?.validate();
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
    ElMessage.success(selectedTargetTableIds.value.length > 1 ? '并桌操作成功' : '换桌操作成功');
    emit('success');
    emit('close');
  }, 1200);
};
const closeModal = () => {
  emit('close');
};
const loadTableOrder = () => {
  // mock订单
  if (sourceTable.value && sourceTable.value.status === 2) {
    currentOrder.value = {
      orderNo: '20240601001',
      startTime: '2024-06-01 12:00:00',
      partySize: 3,
      totalAmount: 288.5
    };
  } else {
    currentOrder.value = null;
  }
};
const formatDateTime = (dateStr: string) => dateStr;

// mock数据加载
const loadTables = () => {
  // 模拟更多桌台数据，覆盖不同类型、状态、容量
  allTables.value = [
    { tableId: 1, tableNo: 'A01', tableType: '大厅', capacity: 4, status: 1, minConsumption: 100 },
    { tableId: 2, tableNo: 'A02', tableType: '大厅', capacity: 6, status: 2, minConsumption: 120 },
    { tableId: 3, tableNo: 'B01', tableType: '包间', capacity: 8, status: 1, minConsumption: 200 },
    { tableId: 4, tableNo: 'B02', tableType: '包间', capacity: 10, status: 1, minConsumption: 300 },
    { tableId: 5, tableNo: 'C01', tableType: '卡座', capacity: 2, status: 1, minConsumption: 50 },
    { tableId: 6, tableNo: 'C02', tableType: '卡座', capacity: 2, status: 3, minConsumption: 60 },
    { tableId: 7, tableNo: 'D01', tableType: '大厅', capacity: 4, status: 4, minConsumption: 90 },
    { tableId: 8, tableNo: 'E01', tableType: '包间', capacity: 12, status: 1, minConsumption: 500 },
    { tableId: 9, tableNo: 'F01', tableType: '大厅', capacity: 6, status: 1, minConsumption: 150 },
    { tableId: 10, tableNo: 'G01', tableType: '卡座', capacity: 3, status: 1, minConsumption: 80 }
  ];
  availableTables.value = allTables.value.filter(t => t.status === 1);
  // 默认选第一个桌台
  if (selectedSourceTableId.value === null && allTables.value.length) {
    selectedSourceTableId.value = allTables.value[0].tableId;
    sourceTable.value = allTables.value[0];
    loadTableOrder();
  }
};

onMounted(() => {
  loadTables();
});

watch(() => props.visible, (val) => {
  if (val) {
    loadTables();
    selectedTargetTableIds.value = [];
    operationReason.value = '';
  }
});
</script>

<style scoped>
.table-operation-container {
  width: 100%;
  height: 100%;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  padding: 0;
}
.operation-main-layout {
  display: flex;
  gap: 24px;
  padding: 20px;
  height: 80vh;
}
.left-table-info {
  width: 50%;
  min-width: 220px;
  margin-right: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.right-operation-area{
  width: 50%;
  min-width: 220px;
  margin-right: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.current-table-form {
  margin-bottom: 8px;
}
.available-table-list {
  margin-top: 8px;
  height: 100%;
}
.list-title {
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 8px;
}
.table-list-flex {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  max-height: calc(100vh - 430px);
  overflow-y: auto;
  align-content: flex-start;
  justify-content: flex-start;
}
.table-list-card {
  width: 220px;
  min-height: 90px;
  box-sizing: border-box;
  border-radius: 8px;
  background: #f7fafb;
  border: 1px solid #ebeef5;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.08);
  padding: 16px 12px 12px 16px;
  margin-bottom: 0;
  cursor: pointer;
  transition: box-shadow 0.2s, border-color 0.2s;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.table-list-card.selected {
  border-color: #165DFF;
  box-shadow: 0 0 0 2px #165DFF22;
}
.table-list-card .table-number {
  font-size: 16px;
  font-weight: 600;
  color: #1D2129;
}
.table-list-card .table-details {
  font-size: 13px;
  color: #4E5969;
  margin-top: 4px;
}
.target-table-info {
  margin-bottom: 16px;
}
.info-title {
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 8px;
}
.empty-info {
  color: #86909C;
  font-size: 14px;
  margin-bottom: 8px;
}
.reason-form {
  margin-top: 16px;
}
.operation-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
}
.status-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  margin-top: 4px;
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
.target-table-list {
  display: flex;
  /* flex-direction: column; */
  gap: 12px;
  margin-bottom: 8px;
}
.target-card {
  background: #F5F7FA;
  border-left: 4px solid #165DFF;
  margin-bottom: 0;
}
.target-card .table-number {
  font-size: 16px;
  font-weight: 600;
  color: #165DFF;
}
.target-card .table-details {
  font-size: 13px;
  color: #4E5969;
  margin-top: 4px;
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}
</style>