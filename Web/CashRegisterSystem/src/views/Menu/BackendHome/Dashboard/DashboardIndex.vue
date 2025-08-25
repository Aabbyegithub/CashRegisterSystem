<template>
  <div class="dashboard-container">
    <!-- 顶部筛选器 -->
    <div class="filter-bar">
      <div class="date-filter">
        <label class="filter-label">时间范围:</label>
        <select v-model="selectedTimeRange" class="time-select">
          <option value="today">今日</option>
          <option value="yesterday">昨日</option>
          <option value="week">本周</option>
          <option value="month" selected>本月</option>
          <option value="quarter">本季度</option>
          <option value="year">本年</option>
          <option value="custom">自定义</option>
        </select>
      </div>
      
      <div class="store-filter" v-if="multiStore">
        <label class="filter-label">门店:</label>
        <select v-model="selectedStore" class="store-select">
          <option value="all">全部门店</option>
          <option v-for="store in storeList" :key="store.id" :value="store.id">{{ store.name }}</option>
        </select>
      </div>
      
      <div class="action-buttons">
        <button class="refresh-btn" @click="refreshData">
          <i class="fa fa-refresh"></i> 刷新数据
        </button>
        <button class="export-btn">
          <i class="fa fa-download"></i> 导出报表
        </button>
      </div>
    </div>
    
    <!-- 核心指标卡片 -->
    <div class="stats-grid">
      <!-- 营业额 -->
      <div class="stat-card">
        <div class="stat-header">
          <h3 class="stat-title">总营业额</h3>
          <i class="fa fa-rmb stat-icon primary"></i>
        </div>
        <div class="stat-value">¥{{ formatNumber(revenue.total) }}</div>
        <div class="stat-trend">
          <span class="trend-value up">
            <i class="fa fa-arrow-up"></i> {{ revenue.rate }}%
          </span>
          <span class="trend-label">较上期</span>
        </div>
        <div class="stat-detail">
          <span class="detail-item">客单价: ¥{{ revenue.average }}</span>
        </div>
      </div>
      
      <!-- 订单数量 -->
      <div class="stat-card">
        <div class="stat-header">
          <h3 class="stat-title">订单总数</h3>
          <i class="fa fa-file-text-o stat-icon secondary"></i>
        </div>
        <div class="stat-value">{{ formatNumber(orders.total) }}</div>
        <div class="stat-trend">
          <span class="trend-value up">
            <i class="fa fa-arrow-up"></i> {{ orders.rate }}%
          </span>
          <span class="trend-label">较上期</span>
        </div>
        <div class="stat-detail">
          <span class="detail-item">完成率: {{ orders.completionRate }}%</span>
        </div>
      </div>
      
      <!-- 顾客数量 -->
      <div class="stat-card">
        <div class="stat-header">
          <h3 class="stat-title">总客流量</h3>
          <i class="fa fa-users stat-icon warning"></i>
        </div>
        <div class="stat-value">{{ formatNumber(customers.total) }}</div>
        <div class="stat-trend">
          <span class="trend-value up">
            <i class="fa fa-arrow-up"></i> {{ customers.rate }}%
          </span>
          <span class="trend-label">较上期</span>
        </div>
        <div class="stat-detail">
          <span class="detail-item">会员占比: {{ customers.memberRate }}%</span>
        </div>
      </div>
      
      <!-- 翻台率 -->
      <div class="stat-card">
        <div class="stat-header">
          <h3 class="stat-title">平均翻台率</h3>
          <i class="fa fa-refresh stat-icon info"></i>
        </div>
        <div class="stat-value">{{ tables.turnoverRate }}次/天</div>
        <div class="stat-trend">
          <span class="trend-value down">
            <i class="fa fa-arrow-down"></i> {{ tables.rate }}%
          </span>
          <span class="trend-label">较上期</span>
        </div>
        <div class="stat-detail">
          <span class="detail-item">上座率: {{ tables.occupancyRate }}%</span>
        </div>
      </div>
    </div>
    
    <!-- 图表区域 -->
    <div class="charts-grid">
      <!-- 营业额趋势 -->
      <div class="chart-card large">
        <div class="chart-header">
          <h3 class="chart-title">营业额趋势</h3>
          <div class="chart-filter">
            <button :class="{'active': timeGranularity === 'day'}" @click="timeGranularity = 'day'">日</button>
            <button :class="{'active': timeGranularity === 'week'}" @click="timeGranularity = 'week'">周</button>
            <button :class="{'active': timeGranularity === 'month'}" @click="timeGranularity = 'month'">月</button>
          </div>
        </div>
        <div class="chart-container">
          <canvas id="revenueChart"></canvas>
        </div>
      </div>
      
      <!-- 订单与客流对比 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">订单与客流对比</h3>
          <button class="chart-detail">详情 <i class="fa fa-angle-right"></i></button>
        </div>
        <div class="chart-container">
          <canvas id="ordersCustomersChart"></canvas>
        </div>
      </div>
      
      <!-- 热销菜品排行 -->
      <div class="chart-card large">
        <div class="chart-header">
          <h3 class="chart-title">热销菜品排行</h3>
          <div class="chart-filter">
            <select v-model="dishRankFilter" class="rank-select">
              <option value="month">本月</option>
              <option value="week">本周</option>
              <option value="quarter">本季度</option>
            </select>
            <button class="chart-detail">查看全部</button>
          </div>
        </div>
        <div class="chart-container">
          <canvas id="topDishesChart"></canvas>
        </div>
      </div>
      
      <!-- 支付方式分布 -->
      <div class="chart-card">
        <div class="chart-header">
          <h3 class="chart-title">支付方式分布</h3>
          <button class="chart-detail">详情 <i class="fa fa-angle-right"></i></button>
        </div>
        <div class="chart-container">
          <canvas id="paymentMethodChart"></canvas>
        </div>
      </div>
    </div>
    
    <!-- 最近订单表格 -->
    <div class="recent-orders">
      <div class="section-header">
        <h3 class="section-title">最近订单</h3>
        <button class="view-all">查看全部订单</button>
      </div>
      <div class="table-container">
        <table class="orders-table">
          <thead>
            <tr>
              <th>订单编号</th>
              <th>桌台</th>
              <th>时间</th>
              <th>金额</th>
              <th>支付方式</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in recentOrders" :key="order.id">
              <td>{{ order.number }}</td>
              <td>{{ order.table }}</td>
              <td>{{ order.time }}</td>
              <td>¥{{ order.amount }}</td>
              <td><span :class="['payment-tag', order.paymentClass]">{{ order.paymentMethod }}</span></td>
              <td><span :class="['status-tag', order.statusClass]">{{ order.status }}</span></td>
              <td>
                <button class="view-detail">详情</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, watch, nextTick } from 'vue';
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

let revenueChartInstance: Chart | null = null;
let ordersCustomersChartInstance: Chart | null = null;
let topDishesChartInstance: Chart | null = null;
let paymentMethodChartInstance: Chart | null = null;

// 时间范围选择
const selectedTimeRange = ref('month');
const timeGranularity = ref('day');
const dishRankFilter = ref('month');

// 多门店模式
const multiStore = ref(true);
const selectedStore = ref('all');
const storeList = ref([
  { id: 1, name: '旗舰店' },
  { id: 2, name: '分店一' },
  { id: 3, name: '分店二' }
]);

// 核心指标数据
const revenue = ref({
  total: 158620,
  rate: 12.5,
  average: 58.6
});

const orders = ref({
  total: 2846,
  rate: 8.3,
  completionRate: 98.2
});

const customers = ref({
  total: 7532,
  rate: 5.7,
  memberRate: 38
});

const tables = ref({
  turnoverRate: 3.2,
  rate: 1.2,
  occupancyRate: 82.5
});

// 最近订单数据
const recentOrders = ref([
  {
    id: 1,
    number: 'ORD20230615001',
    table: '1号桌',
    time: '2023-06-15 18:30',
    amount: 256.00,
    paymentMethod: '微信支付',
    paymentClass: 'wechat',
    status: '已完成',
    statusClass: 'completed'
  },
  {
    id: 2,
    number: 'ORD20230615002',
    table: '5号桌',
    time: '2023-06-15 18:45',
    amount: 188.00,
    paymentMethod: '支付宝',
    paymentClass: 'alipay',
    status: '已完成',
    statusClass: 'completed'
  },
  {
    id: 3,
    number: 'ORD20230615003',
    table: '包间A',
    time: '2023-06-15 19:10',
    amount: 680.00,
    paymentMethod: '会员支付',
    paymentClass: 'member',
    status: '已完成',
    statusClass: 'completed'
  },
  {
    id: 4,
    number: 'ORD20230615004',
    table: '8号桌',
    time: '2023-06-15 19:25',
    amount: 156.00,
    paymentMethod: '现金',
    paymentClass: 'cash',
    status: '已完成',
    statusClass: 'completed'
  },
  {
    id: 5,
    number: 'ORD20230615005',
    table: '3号桌',
    time: '2023-06-15 20:05',
    amount: 218.00,
    paymentMethod: '微信支付',
    paymentClass: 'wechat',
    status: '进行中',
    statusClass: 'processing'
  }
]);

// 格式化数字显示（千位分隔符）
const formatNumber = (num: number) => {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

// 刷新数据
const refreshData = () => {
  // 模拟数据加载
  const loadingState = ref(true);
  
  // 实际项目中这里会调用API获取最新数据
  setTimeout(() => {
    loadingState.value = false;
  }, 800);
};

// 初始化图表
const initCharts = async () => {
  await nextTick(); // 确保 DOM 已渲染
  // 销毁旧图表实例，避免重复创建导致 Canvas is already in use
  if (revenueChartInstance) {
    revenueChartInstance.destroy();
    revenueChartInstance = null;
  }
  if (ordersCustomersChartInstance) {
    ordersCustomersChartInstance.destroy();
    ordersCustomersChartInstance = null;
  }
  if (topDishesChartInstance) {
    topDishesChartInstance.destroy();
    topDishesChartInstance = null;
  }
  if (paymentMethodChartInstance) {
    paymentMethodChartInstance.destroy();
    paymentMethodChartInstance = null;
  }

  // 营业额趋势图
  const revenueCtx = document.getElementById('revenueChart') as HTMLCanvasElement;
  if (revenueCtx) {
    revenueChartInstance = new Chart(revenueCtx.getContext('2d')!, {
      type: 'line',
      data: {
        labels: ['1日', '5日', '10日', '15日', '20日', '25日', '30日'],
        datasets: [
          {
            label: '本月营业额',
            data: [4200, 5100, 4800, 6500, 7200, 6800, 5900],
            borderColor: '#165DFF',
            backgroundColor: 'rgba(22, 93, 255, 0.1)',
            tension: 0.4,
            fill: true
          },
          {
            label: '上月营业额',
            data: [3800, 4500, 5000, 5800, 6200, 5500, 5200],
            borderColor: '#C9CDD4',
            borderDash: [5, 5],
            backgroundColor: 'transparent',
            tension: 0.4,
            fill: false
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: 'index',
          intersect: false,
        },
        plugins: {
          legend: {
            position: 'top',
            align: 'end',
            labels: {
              boxWidth: 10,
              usePointStyle: true,
              pointStyle: 'circle'
            }
          },
          tooltip: {
            padding: 10,
            backgroundColor: 'rgba(0, 0, 0, 0.7)'
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            }
          },
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '¥' + value;
              }
            }
          }
        },
        animation: {
          duration: 1500,
          easing: 'easeOutQuart'
        }
      }
    });
  }

  // 订单与客流对比图
  const ordersCustomersCtx = document.getElementById('ordersCustomersChart') as HTMLCanvasElement;
  if (ordersCustomersCtx) {
    ordersCustomersChartInstance = new Chart(ordersCustomersCtx.getContext('2d')!, {
      type: 'bar',
      data: {
        labels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
        datasets: [
          {
            label: '订单数',
            data: [320, 280, 350, 420, 580, 650, 520],
            backgroundColor: '#165DFF',
            borderRadius: 4
          },
          {
            label: '客流量',
            data: [850, 750, 920, 1100, 1500, 1700, 1350],
            backgroundColor: '#36CFC9',
            borderRadius: 4
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
            align: 'end',
            labels: {
              boxWidth: 10,
              usePointStyle: true
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            }
          },
          y: {
            beginAtZero: true
          }
        },
        animation: {
          duration: 1500
        }
      }
    });
  }

  // 热销菜品排行图
  const topDishesCtx = document.getElementById('topDishesChart') as HTMLCanvasElement;
  if (topDishesCtx) {
    topDishesChartInstance = new Chart(topDishesCtx.getContext('2d')!, {
      type: 'bar',
      data: {
        labels: ['招牌烤鸭', '麻辣香锅', '海鲜炒饭', '水果沙拉', '珍珠奶茶', '水煮鱼', '宫保鸡丁'],
        datasets: [
          {
            label: '销量',
            data: [1258, 986, 842, 756, 1125, 689, 542],
            backgroundColor: '#165DFF',
            borderRadius: 4
          }
        ]
      },
      options: {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          x: {
            beginAtZero: true
          },
          y: {
            grid: {
              display: false
            }
          }
        },
        animation: {
          duration: 1500
        }
      }
    });
  }

  // 支付方式分布图
  const paymentMethodCtx = document.getElementById('paymentMethodChart') as HTMLCanvasElement;
  if (paymentMethodCtx) {
    paymentMethodChartInstance = new Chart(paymentMethodCtx.getContext('2d')!, {
      type: 'doughnut',
      data: {
        labels: ['微信支付', '支付宝', '现金', '会员支付'],
        datasets: [
          {
            data: [45, 35, 12, 8],
            backgroundColor: [
              '#165DFF',
              '#36CFC9',
              '#FAAD14',
              '#722ED1'
            ],
            borderWidth: 0,
            hoverOffset: 5
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '70%',
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              boxWidth: 10,
              usePointStyle: true
            }
          }
        },
        animation: {
          animateRotate: true,
          animateScale: true,
          duration: 1500
        }
      }
    });
  }
};

// 监听时间粒度变化，更新图表
watch(timeGranularity, () => {
  // 在实际项目中，这里会根据时间粒度重新加载数据并更新图表
  initCharts();
});

// 监听时间范围变化，更新数据
watch(selectedTimeRange, () => {
  refreshData();
});

// 页面加载完成后初始化图表
onMounted(() => {
  initCharts();
  
  // 添加卡片进入动画
  const cards = document.querySelectorAll('.stat-card');
  cards.forEach((card, index) => {
    setTimeout(() => {
      card.classList.add('animate-in');
    }, index * 100);
  });
});
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
}

/* 筛选栏样式 */
.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
}

.filter-label {
  color: #4E5969;
  margin-right: 8px;
  font-size: 14px;
}

.time-select, .store-select, .rank-select {
  padding: 6px 12px;
  border: 1px solid #DCDFE6;
  border-radius: 4px;
  background-color: #fff;
  font-size: 14px;
  color: #1D2129;
  cursor: pointer;
  transition: border-color 0.2s;
}

.time-select:focus, .store-select:focus, .rank-select:focus {
  outline: none;
  border-color: #165DFF;
}

.action-buttons {
  display: flex;
  gap: 12px;
}

.refresh-btn, .export-btn {
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

.refresh-btn:hover, .export-btn:hover {
  background-color: #F5F7FA;
  border-color: #C9CDD4;
}

.export-btn {
  background-color: #165DFF;
  color: #fff;
  border-color: #165DFF;
}

.export-btn:hover {
  background-color: #0E42D2;
  border-color: #0E42D2;
}

/* 核心指标卡片样式 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  opacity: 0;
  transform: translateY(20px);
}

.stat-card.animate-in {
  opacity: 1;
  transform: translateY(0);
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.stat-title {
  font-size: 14px;
  color: #4E5969;
  margin: 0;
  font-weight: 500;
}

.stat-icon {
  width: 36px;
  height: 36px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}

.stat-icon.primary {
  background-color: rgba(22, 93, 255, 0.1);
  color: #165DFF;
}

.stat-icon.secondary {
  background-color: rgba(54, 207, 201, 0.1);
  color: #36CFC9;
}

.stat-icon.warning {
  background-color: rgba(250, 173, 20, 0.1);
  color: #FAAD14;
}

.stat-icon.info {
  background-color: rgba(114, 46, 209, 0.1);
  color: #722ED1;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #1D2129;
  margin-bottom: 8px;
  line-height: 1.2;
}

.stat-trend {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.trend-value {
  font-size: 14px;
  font-weight: 500;
  margin-right: 6px;
}

.trend-value.up {
  color: #52C41A;
}

.trend-value.down {
  color: #FF4D4F;
}

.trend-label {
  font-size: 12px;
  color: #86909C;
}

.stat-detail {
  padding-top: 12px;
  border-top: 1px dashed #F2F3F5;
}

.detail-item {
  font-size: 12px;
  color: #4E5969;
}

/* 图表区域样式 */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.chart-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  grid-column: span 1;
}

.chart-card.large {
  grid-column: span 2;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.chart-title {
  font-size: 16px;
  color: #1D2129;
  margin: 0;
  font-weight: 600;
}

.chart-filter {
  display: flex;
  gap: 8px;
}

.chart-filter button {
  padding: 4px 12px;
  border-radius: 12px;
  background-color: #F5F7FA;
  color: #4E5969;
  border: none;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.chart-filter button.active {
  background-color: #165DFF;
  color: #fff;
}

.chart-detail {
  color: #165DFF;
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
}

.chart-container {
  width: 100%;
  height: 300px;
}

/* 最近订单表格样式 */
.recent-orders {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  color: #1D2129;
  margin: 0;
  font-weight: 600;
}

.view-all {
  color: #165DFF;
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
}

.table-container {
  overflow-x: auto;
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.orders-table th {
  text-align: left;
  padding: 12px 16px;
  color: #4E5969;
  font-weight: 500;
  border-bottom: 1px solid #F2F3F5;
}

.orders-table td {
  padding: 12px 16px;
  color: #1D2129;
  border-bottom: 1px solid #F2F3F5;
}

.orders-table tr:last-child td {
  border-bottom: none;
}

.orders-table tr:hover td {
  background-color: #F5F7FA;
}

.payment-tag, .status-tag {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.payment-tag.wechat {
  background-color: rgba(73, 197, 182, 0.1);
  color: #49C5B6;
}

.payment-tag.alipay {
  background-color: rgba(66, 185, 131, 0.1);
  color: #42B983;
}

.payment-tag.cash {
  background-color: rgba(250, 173, 20, 0.1);
  color: #FAAD14;
}

.payment-tag.member {
  background-color: rgba(114, 46, 209, 0.1);
  color: #722ED1;
}

.status-tag.completed {
  background-color: rgba(82, 196, 26, 0.1);
  color: #52C41A;
}

.status-tag.processing {
  background-color: rgba(22, 93, 255, 0.1);
  color: #165DFF;
}

.view-detail {
  color: #165DFF;
  background: none;
  border: none;
  font-size: 14px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.view-detail:hover {
  background-color: rgba(22, 93, 255, 0.1);
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
  
  .chart-card, .chart-card.large {
    grid-column: span 1;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .filter-bar {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .action-buttons {
    width: 100%;
    justify-content: flex-end;
  }
  
  .chart-container {
    height: 250px;
  }
}
</style>
