<template>
  <div class="table-layout-container">
    <!-- 页面标题和操作区 -->
    <div class="page-header">
      <h2 class="page-title">桌台布局可视化</h2>
      
      <div class="operation-bar">
        <div class="filter-group">
          <label class="filter-label">门店:</label>
          <select v-model="selectedStore" class="store-select" @change="loadTableData">
            <option value="">请选择门店</option>
            <option v-for="store in storeList" :key="store.id" :value="store.id">{{ store.name }}</option>
          </select>
        </div>
        
        <div class="view-controls">
          <button class="view-btn" :class="{ active: viewMode === 'layout' }" @click="viewMode = 'layout'">
            <i class="fa fa-th-large"></i> 布局视图
          </button>
          <button class="view-btn" :class="{ active: viewMode === 'list' }" @click="viewMode = 'list'">
            <i class="fa fa-list"></i> 列表视图
          </button>
        </div>
        
        <div class="action-buttons">
          <button class="refresh-btn" @click="loadTableData">
            <i class="fa fa-refresh"></i> 刷新
          </button>
          <button class="edit-btn">
            <i class="fa fa-pencil"></i> 编辑布局
          </button>
        </div>
      </div>
    </div>
    
    <!-- 桌台状态图例 -->
    <div class="table-legend">
      <div class="legend-item">
        <div class="legend-color available"></div>
        <span class="legend-text">空闲</span>
      </div>
      <div class="legend-item">
        <div class="legend-color occupied"></div>
        <span class="legend-text">占用</span>
      </div>
      <div class="legend-item">
        <div class="legend-color reserved"></div>
        <span class="legend-text">已预订</span>
      </div>
      <div class="legend-item">
        <div class="legend-color maintenance"></div>
        <span class="legend-text">维护中</span>
      </div>
      <div class="legend-item">
        <div class="legend-text total">总桌台: {{ tableStats.total }}</div>
      </div>
      <div class="legend-item">
        <div class="legend-text occupied">占用: {{ tableStats.occupied }}</div>
      </div>
      <div class="legend-item">
        <div class="legend-text available">空闲: {{ tableStats.available }}</div>
      </div>
    </div>
    
    <!-- 布局视图 -->
    <div class="restaurant-layout" v-if="viewMode === 'layout' && selectedStore">
      <!-- 餐厅区域 -->
      <div class="restaurant-area" :style="{ width: restaurantWidth + 'px', height: restaurantHeight + 'px' }">
        <!-- 入口 -->
        <div class="restaurant-entrance" :style="{ left: entrancePosition.x + 'px', top: entrancePosition.y + 'px' }">
          <div class="entrance-text">入口</div>
        </div>
        
        <!-- 吧台 -->
        <div class="bar-counter" v-if="barExists" :style="{ 
          left: barPosition.x + 'px', 
          top: barPosition.y + 'px',
          width: barSize.width + 'px',
          height: barSize.height + 'px'
        }">
          <div class="bar-text">吧台</div>
        </div>
        
        <!-- 桌台 -->
        <div 
          v-for="table in tableList" 
          :key="table.id"
          :class="['table-item', 'table-' + table.shape, table.status]"
          :style="{ 
            left: table.position.x + 'px', 
            top: table.position.y + 'px',
            width: table.size.width + 'px',
            height: table.size.height + 'px',
            zIndex: table.status === 'occupied' ? 2 : 1
          }"
          @click="handleTableClick(table)"
        >
          <div class="table-number">{{ table.number }}</div>
          <div class="table-capacity">
            <i class="fa fa-user"></i> {{ table.capacity }}人
          </div>
          
          <!-- 占用状态显示当前订单信息 -->
          <div class="table-order-info" v-if="table.status === 'occupied' && table.currentOrder">
            <div class="order-number">订单: {{ table.currentOrder.orderNumber }}</div>
            <div class="order-time">已就座: {{ table.currentOrder.seatTime }}</div>
            <div class="order-amount">金额: ¥{{ table.currentOrder.amount }}</div>
          </div>
          
          <!-- 预订状态显示预订信息 -->
          <div class="table-reserve-info" v-if="table.status === 'reserved' && table.reservation">
            <div class="reserve-customer">{{ table.reservation.customerName }}</div>
            <div class="reserve-time">预订: {{ table.reservation.reserveTime }}</div>
          </div>
        </div>
        
        <!-- 服务员 -->
        <div 
          v-for="waiter in waiters" 
          :key="waiter.id"
          class="waiter-icon"
          :style="{ 
            left: waiter.position.x + 'px', 
            top: waiter.position.y + 'px'
          }"
        >
          <i class="fa fa-user-circle"></i>
          <div class="waiter-name">{{ waiter.name }}</div>
        </div>
      </div>
    </div>
    
    <!-- 列表视图 -->
    <div class="table-list-view" v-if="viewMode === 'list' && selectedStore">
      <div class="table-list-header">
        <div class="list-column">桌台编号</div>
        <div class="list-column">类型</div>
        <div class="list-column">容量</div>
        <div class="list-column">状态</div>
        <div class="list-column">当前订单/预订</div>
        <div class="list-column">操作</div>
      </div>
      
      <div class="table-list-body">
        <div 
          v-for="table in tableList" 
          :key="table.id"
          class="table-list-item"
          @click="handleTableClick(table)"
        >
          <div class="list-column">{{ table.number }}</div>
          <div class="list-column">
            <span class="shape-tag">{{ table.shape === 'round' ? '圆桌' : table.shape === 'square' ? '方桌' : '长桌' }}</span>
          </div>
          <div class="list-column">{{ table.capacity }}人</div>
          <div class="list-column">
            <span :class="['status-tag', table.status]">
              {{ table.status === 'available' ? '空闲' : 
                 table.status === 'occupied' ? '占用' : 
                 table.status === 'reserved' ? '已预订' : '维护中' }}
            </span>
          </div>
          <div class="list-column">
            <template v-if="table.status === 'occupied' && table.currentOrder">
              {{ table.currentOrder.orderNumber }}
            </template>
            <template v-if="table.status === 'reserved' && table.reservation">
              {{ table.reservation.customerName }} ({{ table.reservation.reserveTime }})
            </template>
            <template v-else>--</template>
          </div>
          <div class="list-column">
            <button class="action-btn view-details" @click.stop="showTableDetails(table)">详情</button>
            <button class="action-btn manage-order" @click.stop="manageTableOrder(table)">
              {{ table.status === 'available' ? '开单' : '管理订单' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 桌台详情弹窗 -->
    <div class="modal-backdrop" v-if="showDetailModal">
      <div class="modal-dialog">
        <div class="modal-header">
          <h3 class="modal-title">{{ currentTable?.number }} 桌详情</h3>
          <button class="modal-close" @click="showDetailModal = false">
            <i class="fa fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body">
          <div class="detail-section">
            <h4 class="section-title">基本信息</h4>
            <div class="detail-item">
              <span class="detail-label">桌台编号:</span>
              <span class="detail-value">{{ currentTable?.number }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">桌台类型:</span>
              <span class="detail-value">{{ currentTable?.shape === 'round' ? '圆桌' : currentTable?.shape === 'square' ? '方桌' : '长桌' }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">容纳人数:</span>
              <span class="detail-value">{{ currentTable?.capacity }}人</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">当前状态:</span>
              <span class="detail-value">
                <span :class="['status-tag', currentTable?.status]">
                  {{ currentTable?.status === 'available' ? '空闲' : 
                     currentTable?.status === 'occupied' ? '占用' : 
                     currentTable?.status === 'reserved' ? '已预订' : '维护中' }}
                </span>
              </span>
            </div>
            <div class="detail-item">
              <span class="detail-label">所属区域:</span>
              <span class="detail-value">{{ currentTable?.areaName || '大厅' }}</span>
            </div>
          </div>
          
          <div class="detail-section" v-if="currentTable?.status === 'occupied' && currentTable?.currentOrder">
            <h4 class="section-title">当前订单信息</h4>
            <div class="detail-item">
              <span class="detail-label">订单编号:</span>
              <span class="detail-value">{{ currentTable.currentOrder.orderNumber }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">开单时间:</span>
              <span class="detail-value">{{ currentTable.currentOrder.seatTime }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">用餐人数:</span>
              <span class="detail-value">{{ currentTable.currentOrder.customerCount }}人</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">消费金额:</span>
              <span class="detail-value">¥{{ currentTable.currentOrder.amount }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">服务员:</span>
              <span class="detail-value">{{ currentTable.currentOrder.waiterName }}</span>
            </div>
          </div>
          
          <div class="detail-section" v-if="currentTable?.status === 'reserved' && currentTable?.reservation">
            <h4 class="section-title">预订信息</h4>
            <div class="detail-item">
              <span class="detail-label">预订人:</span>
              <span class="detail-value">{{ currentTable.reservation.customerName }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">联系电话:</span>
              <span class="detail-value">{{ currentTable.reservation.phone }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">预订时间:</span>
              <span class="detail-value">{{ currentTable.reservation.reserveTime }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">预订人数:</span>
              <span class="detail-value">{{ currentTable.reservation.customerCount }}人</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">备注:</span>
              <span class="detail-value">{{ currentTable.reservation.notes || '无' }}</span>
            </div>
          </div>
          
          <div class="detail-section">
            <h4 class="section-title">今日使用记录</h4>
            <div class="usage-record-list">
              <div class="record-item header">
                <div class="record-col">时间</div>
                <div class="record-col">订单号</div>
                <div class="record-col">消费金额</div>
                <div class="record-col">状态</div>
              </div>
              
              <div class="record-item" v-for="record in currentTable?.usageRecords || []" :key="record.id">
                <div class="record-col">{{ record.time }}</div>
                <div class="record-col">{{ record.orderNumber }}</div>
                <div class="record-col">¥{{ record.amount }}</div>
                <div class="record-col">{{ record.status }}</div>
              </div>
              
              <div class="no-record" v-if="!(currentTable?.usageRecords && currentTable.usageRecords.length)">
                今日暂无使用记录
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="btn cancel-btn" @click="showDetailModal = false">关闭</button>
          <button class="btn primary-btn" @click="manageTableOrder(currentTable)">
            {{ currentTable?.status === 'available' ? '开单' : '管理订单' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, reactive, toRefs } from 'vue';

// 门店列表
const storeList = ref([
  { id: 1, name: '旗舰店' },
  { id: 2, name: '分店一' },
  { id: 3, name: '分店二' }
]);

// 选中的门店
const selectedStore = ref();

// 视图模式：布局视图/列表视图
const viewMode = ref('layout');

// 餐厅布局尺寸
const restaurantWidth = ref(1000);
const restaurantHeight = ref(600);

// 入口位置
const entrancePosition = ref({ x: 450, y: 550 });

// 吧台设置
const barExists = ref(true);
const barPosition = ref({ x: 100, y: 100 });
const barSize = ref({ width: 200, height: 50 });

// 服务员位置
const waiters = ref([
  { id: 1, name: '张服务员', position: { x: 300, y: 200 } },
  { id: 2, name: '李服务员', position: { x: 700, y: 300 } }
]);

// 桌台列表数据
const tableList = ref([
      {
        id: 1,
        number: '1',
        shape: 'round',
        capacity: 4,
        position: { x: 200, y: 200 },
        size: { width: 80, height: 80 },
        status: 'occupied',
        areaName: '大厅',
        currentOrder: {
          orderNumber: 'ORD20230615001',
          seatTime: '18:30',
          amount: 256.00,
          customerCount: 4,
          waiterName: '张服务员'
        },
        usageRecords: [
          { id: 1, time: '18:30', orderNumber: 'ORD20230615001', amount: 256.00, status: '在用' }
        ]
      },
      {
        id: 2,
        number: '2',
        shape: 'square',
        capacity: 2,
        position: { x: 350, y: 200 },
        size: { width: 60, height: 60 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 3,
        number: '3',
        shape: 'square',
        capacity: 2,
        position: { x: 450, y: 200 },
        size: { width: 60, height: 60 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 4,
        number: '4',
        shape: 'round',
        capacity: 6,
        position: { x: 600, y: 200 },
        size: { width: 100, height: 100 },
        status: 'reserved',
        areaName: '大厅',
        reservation: {
          customerName: '王先生',
          phone: '138****5678',
          reserveTime: '20:00',
          customerCount: 6,
          notes: '需要靠窗位置'
        },
        usageRecords: []
      },
      {
        id: 5,
        number: '5',
        shape: 'rectangle',
        capacity: 8,
        position: { x: 200, y: 350 },
        size: { width: 120, height: 60 },
        status: 'occupied',
        areaName: '大厅',
        currentOrder: {
          orderNumber: 'ORD20230615002',
          seatTime: '19:15',
          amount: 420.00,
          customerCount: 6,
          waiterName: '李服务员'
        },
        usageRecords: [
          { id: 2, time: '19:15', orderNumber: 'ORD20230615002', amount: 420.00, status: '在用' }
        ]
      },
      {
        id: 6,
        number: '6',
        shape: 'round',
        capacity: 4,
        position: { x: 400, y: 350 },
        size: { width: 80, height: 80 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 7,
        number: '7',
        shape: 'round',
        capacity: 4,
        position: { x: 600, y: 350 },
        size: { width: 80, height: 80 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 8,
        number: '包间A',
        shape: 'rectangle',
        capacity: 10,
        position: { x: 200, y: 500 },
        size: { width: 150, height: 100 },
        status: 'maintenance',
        areaName: '包间',
        usageRecords: []
      },
      {
        id: 9,
        number: '包间B',
        shape: 'rectangle',
        capacity: 8,
        position: { x: 400, y: 500 },
        size: { width: 120, height: 100 },
        status: 'occupied',
        areaName: '包间',
        currentOrder: {
          orderNumber: 'ORD20230615003',
          seatTime: '17:45',
          amount: 680.00,
          customerCount: 8,
          waiterName: '张服务员'
        },
        usageRecords: [
          { id: 3, time: '17:45', orderNumber: 'ORD20230615003', amount: 680.00, status: '在用' }
        ]
      },
      {
        id: 10,
        number: '吧台1',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 120, y: 120 },
        size: { width: 40, height: 40 },
        status: 'available',
        areaName: '吧台',
        usageRecords: []
      },
      {
        id: 11,
        number: '吧台2',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 170, y: 120 },
        size: { width: 40, height: 40 },
        status: 'available',
        areaName: '吧台',
        usageRecords: []
      },
      {
        id: 12,
        number: '吧台3',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 220, y: 120 },
        size: { width: 40, height: 40 },
        status: 'occupied',
        areaName: '吧台',
        currentOrder: {
          orderNumber: 'ORD20230615004',
          seatTime: '19:30',
          amount: 58.00,
          customerCount: 1,
          waiterName: '李服务员'
        },
        usageRecords: [
          { id: 4, time: '19:30', orderNumber: 'ORD20230615004', amount: 58.00, status: '在用' }
        ]
      }
    ]);

// 桌台统计数据
const tableStats = reactive({
  total: 0,
  available: 0,
  occupied: 0,
  reserved: 0,
  maintenance: 0
});

// 详情弹窗状态
const showDetailModal = ref(false);
const currentTable = ref();

// 加载桌台数据
const loadTableData = () => {
  if (!selectedStore.value) return;
  
  // 模拟API请求加载数据
  // 实际项目中这里会调用后端接口获取数据
//   setTimeout(() => {
    // 模拟桌台数据
    tableList.value = [
      {
        id: 1,
        number: '1',
        shape: 'round',
        capacity: 4,
        position: { x: 200, y: 200 },
        size: { width: 80, height: 80 },
        status: 'occupied',
        areaName: '大厅',
        currentOrder: {
          orderNumber: 'ORD20230615001',
          seatTime: '18:30',
          amount: 256.00,
          customerCount: 4,
          waiterName: '张服务员'
        },
        usageRecords: [
          { id: 1, time: '18:30', orderNumber: 'ORD20230615001', amount: 256.00, status: '在用' }
        ]
      },
      {
        id: 2,
        number: '2',
        shape: 'square',
        capacity: 2,
        position: { x: 350, y: 200 },
        size: { width: 60, height: 60 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 3,
        number: '3',
        shape: 'square',
        capacity: 2,
        position: { x: 450, y: 200 },
        size: { width: 60, height: 60 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 4,
        number: '4',
        shape: 'round',
        capacity: 6,
        position: { x: 600, y: 200 },
        size: { width: 100, height: 100 },
        status: 'reserved',
        areaName: '大厅',
        reservation: {
          customerName: '王先生',
          phone: '138****5678',
          reserveTime: '20:00',
          customerCount: 6,
          notes: '需要靠窗位置'
        },
        usageRecords: []
      },
      {
        id: 5,
        number: '5',
        shape: 'rectangle',
        capacity: 8,
        position: { x: 200, y: 350 },
        size: { width: 120, height: 60 },
        status: 'occupied',
        areaName: '大厅',
        currentOrder: {
          orderNumber: 'ORD20230615002',
          seatTime: '19:15',
          amount: 420.00,
          customerCount: 6,
          waiterName: '李服务员'
        },
        usageRecords: [
          { id: 2, time: '19:15', orderNumber: 'ORD20230615002', amount: 420.00, status: '在用' }
        ]
      },
      {
        id: 6,
        number: '6',
        shape: 'round',
        capacity: 4,
        position: { x: 400, y: 350 },
        size: { width: 80, height: 80 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 7,
        number: '7',
        shape: 'round',
        capacity: 4,
        position: { x: 600, y: 350 },
        size: { width: 80, height: 80 },
        status: 'available',
        areaName: '大厅',
        usageRecords: []
      },
      {
        id: 8,
        number: '包间A',
        shape: 'rectangle',
        capacity: 10,
        position: { x: 200, y: 500 },
        size: { width: 150, height: 100 },
        status: 'maintenance',
        areaName: '包间',
        usageRecords: []
      },
      {
        id: 9,
        number: '包间B',
        shape: 'rectangle',
        capacity: 8,
        position: { x: 400, y: 500 },
        size: { width: 120, height: 100 },
        status: 'occupied',
        areaName: '包间',
        currentOrder: {
          orderNumber: 'ORD20230615003',
          seatTime: '17:45',
          amount: 680.00,
          customerCount: 8,
          waiterName: '张服务员'
        },
        usageRecords: [
          { id: 3, time: '17:45', orderNumber: 'ORD20230615003', amount: 680.00, status: '在用' }
        ]
      },
      {
        id: 10,
        number: '吧台1',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 120, y: 120 },
        size: { width: 40, height: 40 },
        status: 'available',
        areaName: '吧台',
        usageRecords: []
      },
      {
        id: 11,
        number: '吧台2',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 170, y: 120 },
        size: { width: 40, height: 40 },
        status: 'available',
        areaName: '吧台',
        usageRecords: []
      },
      {
        id: 12,
        number: '吧台3',
        shape: 'rectangle',
        capacity: 1,
        position: { x: 220, y: 120 },
        size: { width: 40, height: 40 },
        status: 'occupied',
        areaName: '吧台',
        currentOrder: {
          orderNumber: 'ORD20230615004',
          seatTime: '19:30',
          amount: 58.00,
          customerCount: 1,
          waiterName: '李服务员'
        },
        usageRecords: [
          { id: 4, time: '19:30', orderNumber: 'ORD20230615004', amount: 58.00, status: '在用' }
        ]
      }
    ];
    
    // 更新统计数据
    updateTableStats();
//   }, 500);
};

// 更新桌台统计数据
const updateTableStats = () => {
  tableStats.total = tableList.value.length;
  tableStats.available = tableList.value.filter(t => t.status === 'available').length;
  tableStats.occupied = tableList.value.filter(t => t.status === 'occupied').length;
  tableStats.reserved = tableList.value.filter(t => t.status === 'reserved').length;
  tableStats.maintenance = tableList.value.filter(t => t.status === 'maintenance').length;
};

// 点击桌台
const handleTableClick = (table:any) => {
  // 可以在这里处理桌台点击事件，例如显示快速操作菜单
  console.log('点击了桌台:', table);
};

// 显示桌台详情
const showTableDetails = (table:any) => {
  currentTable.value = table;
  showDetailModal.value = true;
};

// 管理桌台订单
const manageTableOrder = (table:any) => {
  if (!table) return;
  
  // 根据桌台状态跳转到不同页面
  if (table.status === 'available' || table.status === 'reserved') {
    // 空闲或已预订状态，跳转到开单页面
    console.log(`跳转到${table.number}桌开单页面`);
    // router.push(`/create-order?tableId=${table.id}`);
  } else if (table.status === 'occupied') {
    // 占用状态，跳转到订单详情页面
    console.log(`跳转到${table.number}桌订单详情页面`);
    // router.push(`/order-detail?orderId=${table.currentOrder.id}`);
  }
  
  showDetailModal.value = false;
};

// 页面加载时执行
onMounted(() => {
  // 如果有默认门店，加载数据
  if (storeList.value.length > 0) {
    selectedStore.value = storeList.value[0].id;
    loadTableData();
  }
});
</script>

<style scoped>
.table-layout-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
}

/* 页面标题和操作区 */
.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 20px;
  color: #1D2129;
  margin: 0 0 16px 0;
  font-weight: 600;
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
}

.filter-label {
  color: #4E5969;
  margin-right: 8px;
  font-size: 14px;
}

.store-select {
  padding: 6px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  background-color: #fff;
  font-size: 14px;
  color: #1D2129;
  min-width: 180px;
}

.view-controls {
  display: flex;
  gap: 8px;
}

.view-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 4px;
  border: 1px solid #DCDFE6;
  background-color: #fff;
  color: #1D2129;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.view-btn.active {
  background-color: #165DFF;
  color: #fff;
  border-color: #165DFF;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.refresh-btn, .edit-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 16px;
  border-radius: 4px;
  border: 1px solid #DCDFE6;
  background-color: #fff;
  color: #1D2129;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-btn:hover {
  background-color: #F5F7FA;
}

.edit-btn {
  background-color: #36CFC9;
  color: #fff;
  border-color: #36CFC9;
}

.edit-btn:hover {
  background-color: #2AA9A1;
}

/* 桌台状态图例 */
.table-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  padding: 12px 16px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
  align-items: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.legend-color {
  width: 16px;
  height: 16px;
  border-radius: 4px;
}

.legend-color.available {
  background-color: #52C41A;
}

.legend-color.occupied {
  background-color: #FF4D4F;
}

.legend-color.reserved {
  background-color: #FAAD14;
}

.legend-color.maintenance {
  background-color: #86909C;
}

.legend-text {
  font-size: 14px;
  color: #4E5969;
}

.legend-text.total {
  color: #1D2129;
  font-weight: 500;
  margin-left: 20px;
}

.legend-text.occupied {
  color: #FF4D4F;
  font-weight: 500;
}

.legend-text.available {
  color: #52C41A;
  font-weight: 500;
}

/* 布局视图样式 */
.restaurant-layout {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 30px;
}

.restaurant-area {
  position: relative;
  background-color: #E8F3FF;
  border: 2px solid #91BFFF;
  border-radius: 8px;
  background-image: 
    linear-gradient(rgba(145, 191, 255, 0.2) 1px, transparent 1px),
    linear-gradient(90deg, rgba(145, 191, 255, 0.2) 1px, transparent 1px);
  background-size: 50px 50px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.restaurant-entrance {
  position: absolute;
  width: 80px;
  height: 30px;
  background-color: #fff;
  border: 2px solid #91BFFF;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.entrance-text {
  font-size: 14px;
  color: #165DFF;
  font-weight: 500;
}

.bar-counter {
  position: absolute;
  background-color: #FFE8CC;
  border: 2px solid #FFB980;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.bar-text {
  font-size: 16px;
  color: #FA8C16;
  font-weight: 600;
}

.table-item {
  position: absolute;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
}

.table-item:hover {
  transform: scale(1.05);
  z-index: 3 !important;
}

.table-round {
  border-radius: 50%;
}

.table-square {
  border-radius: 4px;
}

.table-rectangle {
  border-radius: 4px;
}

.table-item.available {
  background-color: rgba(82, 196, 26, 0.7);
}

.table-item.occupied {
  background-color: rgba(255, 77, 79, 0.7);
}

.table-item.reserved {
  background-color: rgba(250, 173, 20, 0.7);
}

.table-item.maintenance {
  background-color: rgba(134, 144, 156, 0.7);
}

.table-number {
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.table-capacity {
  font-size: 12px;
  color: #fff;
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.table-order-info, .table-reserve-info {
  position: absolute;
  top: -100px;
  left: 50%;
  transform: translateX(-50%);
  width: 180px;
  background-color: #fff;
  border-radius: 6px;
  padding: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  font-size: 12px;
  z-index: 10;
  display: none;
}

.table-item.occupied:hover .table-order-info,
.table-item.reserved:hover .table-reserve-info {
  display: block;
}

.table-order-info::after, .table-reserve-info::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  border-width: 8px 8px 0;
  border-style: solid;
  border-color: #fff transparent transparent;
}

.order-number, .reserve-customer {
  font-weight: 500;
  margin-bottom: 4px;
  color: #1D2129;
}

.order-time, .order-amount, .reserve-time {
  color: #4E5969;
  margin-bottom: 2px;
}

.waiter-icon {
  position: absolute;
  width: 40px;
  height: 40px;
  background-color: #165DFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  z-index: 1;
}

.waiter-name {
  position: absolute;
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  color: #1D2129;
  white-space: nowrap;
  background-color: #fff;
  padding: 2px 6px;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* 列表视图样式 */
.table-list-view {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.table-list-header {
  display: flex;
  background-color: #F5F7FA;
  border-bottom: 1px solid #F2F3F5;
}

.table-list-body {
  max-height: 600px;
  overflow-y: auto;
}

.table-list-item {
  display: flex;
  border-bottom: 1px solid #F2F3F5;
  transition: background-color 0.2s;
  cursor: pointer;
}

.table-list-item:hover {
  background-color: #F5F7FA;
}

.list-column {
  flex: 1;
  padding: 12px 16px;
  font-size: 14px;
  color: #1D2129;
}

.table-list-header .list-column {
  font-weight: 500;
  color: #4E5969;
}

.shape-tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  background-color: #E8F3FF;
  color: #165DFF;
  font-size: 12px;
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

.action-btn {
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  margin-right: 6px;
}

.view-details {
  background-color: #F5F7FA;
  color: #4E5969;
}

.view-details:hover {
  background-color: #E8EBF0;
}

.manage-order {
  background-color: #165DFF;
  color: #fff;
}

.manage-order:hover {
  background-color: #0E42D2;
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
  width: 600px;
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
  transition: all 0.2s;
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

.detail-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 14px;
  color: #1D2129;
  margin: 0 0 12px 0;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 1px solid #F2F3F5;
}

.detail-item {
  display: flex;
  margin-bottom: 12px;
}

.detail-label {
  width: 100px;
  font-size: 14px;
  color: #4E5969;
  flex-shrink: 0;
}

.detail-value {
  flex: 1;
  font-size: 14px;
  color: #1D2129;
}

.usage-record-list {
  border: 1px solid #F2F3F5;
  border-radius: 4px;
  overflow: hidden;
}

.record-item {
  display: flex;
  border-bottom: 1px solid #F2F3F5;
}

.record-item.header {
  background-color: #F5F7FA;
  font-weight: 500;
}

.record-item:last-child {
  border-bottom: none;
}

.record-col {
  flex: 1;
  padding: 10px 12px;
  font-size: 14px;
  color: #1D2129;
}

.record-item.header .record-col {
  color: #4E5969;
}

.no-record {
  text-align: center;
  padding: 20px;
  color: #86909C;
  font-size: 14px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #F2F3F5;
}

.btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.cancel-btn {
  background-color: #fff;
  color: #1D2129;
  border: 1px solid #DCDFE6;
}

.cancel-btn:hover {
  background-color: #F5F7FA;
}

.primary-btn {
  background-color: #165DFF;
  color: #fff;
  border: 1px solid #165DFF;
}

.primary-btn:hover {
  background-color: #0E42D2;
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .restaurant-area {
    transform: scale(0.9);
  }
}

@media (max-width: 992px) {
  .restaurant-area {
    transform: scale(0.8);
  }
  
  .modal-dialog {
    width: 90%;
    max-width: 500px;
  }
}

@media (max-width: 768px) {
  .restaurant-area {
    transform: scale(0.7);
  }
  
  .operation-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .view-controls, .action-buttons {
    width: 100%;
    justify-content: flex-start;
  }
  
  .table-legend {
    gap: 10px;
  }
  
  .legend-text.total {
    margin-left: 0;
    width: 100%;
    margin-top: 8px;
  }
  
  .list-column {
    padding: 10px 8px;
    font-size: 12px;
  }
  
  .action-btn {
    padding: 2px 6px;
    font-size: 11px;
  }
}
</style>
