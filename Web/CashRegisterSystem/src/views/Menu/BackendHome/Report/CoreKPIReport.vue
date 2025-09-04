<template>
  <div class="report-dashboard-container">
    <!-- <div class="dashboard-header">
      <h2 class="dashboard-title">餐饮运营数据总览</h2>
    </div> -->
    <!-- 第一行：左核心指标，右时段客流高峰 -->
    <div class="dashboard-row">
      <el-card shadow="hover" class="dashboard-card kpi-card">
        <div class="card-title">餐饮核心指标</div>
        <div class="kpi-value">
          <span class="kpi-label">翻台率：</span>
          <span class="kpi-number">{{ turnoverRate }}</span>
          <span class="kpi-desc">（当日桌台使用次数 / 总桌台数）</span>
        </div>
        <div class="kpi-value">
          <span class="kpi-label">人均消费：</span>
          <span class="kpi-number">¥{{ avgPerPerson }}</span>
        </div>
        <div class="kpi-value">
          <span class="kpi-label">客单价：</span>
          <span class="kpi-number">¥{{ avgPerOrder }}</span>
        </div>
      </el-card>
      <el-card shadow="hover" class="dashboard-card peak-card">
        <div class="card-title">时段客流高峰分析</div>
        <canvas id="peakChart"></canvas>
      </el-card>
    </div>
    <!-- 第二行：畅销、滞销、搭配 -->
    <div class="dashboard-row">
      <el-card shadow="hover" class="dashboard-card dish-card">
        <div class="card-title">畅销菜品 TOP10（销量/利润）</div>
        <canvas id="topDishChart"></canvas>
      </el-card>
      <el-card shadow="hover" class="dashboard-card unsalable-card">
        <div class="card-title">滞销菜品预警</div>
        <el-table :data="unsalableDishData" style="width: 100%" size="small" border>
          <el-table-column prop="name" label="菜品名称" />
          <el-table-column prop="sales" label="近两周销量" />
          <el-table-column prop="warning" label="预警">
            <template #default="scope">
              <el-tag type="danger" v-if="scope.row.sales < 10">滞销</el-tag>
              <el-tag type="success" v-else>正常</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
      <el-card shadow="hover" class="dashboard-card combo-card">
        <div class="card-title">菜品搭配分析</div>
        <canvas id="comboChart"></canvas>
      </el-card>
    </div>
    <!-- 第三行：服务员、门店、外卖 -->
    <div class="dashboard-row">
      <el-card shadow="hover" class="dashboard-card waiter-card">
        <div class="card-title">服务员绩效</div>
        <canvas id="waiterChart"></canvas>
      </el-card>
      <el-card shadow="hover" class="dashboard-card store-card">
        <div class="card-title">门店对比</div>
        <canvas id="storeChart"></canvas>
      </el-card>
      <el-card shadow="hover" class="dashboard-card order-card">
        <div class="card-title">外卖订单占比分析</div>
        <canvas id="orderChart"></canvas>
      </el-card>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, nextTick, onUnmounted, onActivated } from 'vue';
import { Chart, registerables } from 'chart.js';
import { getDashboardData } from '../../../../api/storeapi';
Chart.register(...registerables);

// 数据（同原来）
const turnoverRate = ref(0);
const avgPerPerson = ref(0);
const avgPerOrder = ref(0);
const peakData = ref<any[]>([]);
const topDishData = ref<any[]>([]);
const unsalableDishData = ref<any[]>([]);
const comboData = ref<any[]>([]);
const waiterData = ref<any[]>([]);
const storeData = ref<any[]>([]);
const orderData = ref<any[]>([]);

const fetchDashboardData = async () => {
  const res:any = await getDashboardData();
  if (res && res.success) {
    const d = res.response;
    turnoverRate.value = d.turnoverRate;
    avgPerPerson.value = d.avgPerPerson;
    avgPerOrder.value = d.avgPerOrder;
    peakData.value = d.peakPeriod || [];
    topDishData.value = d.topDishes || [];
    unsalableDishData.value = d.unsalableDishes || [];
    comboData.value = d.comboAnalysis || [];
    waiterData.value = d.waiterPerformance || [];
    storeData.value = d.storeCompare || [];
    orderData.value = d.orderChannels || [];
  }
};

// 图表实例
let peakChart: Chart | null = null;
let topDishChart: Chart | null = null;
let comboChart: Chart | null = null;
let waiterChart: Chart | null = null;
let storeChart: Chart | null = null;
let orderChart: Chart | null = null;
let chartInitFlag = false;

function destroyCharts() {
  chartInitFlag = false;
  if (peakChart) { peakChart.destroy(); peakChart = null; }
  if (topDishChart) { topDishChart.destroy(); topDishChart = null; }
  if (comboChart) { comboChart.destroy(); comboChart = null; }
  if (waiterChart) { waiterChart.destroy(); waiterChart = null; }
  if (storeChart) { storeChart.destroy(); storeChart = null; }
  if (orderChart) { orderChart.destroy(); orderChart = null; }
}
let refreshTimer: number | undefined;
onMounted(async () => {
  await fetchDashboardData();
  refreshTimer = window.setInterval(() => {
    fetchDashboardData();
  }, 30000);
  await nextTick();
  destroyCharts();
  setTimeout(() => {
    if (chartInitFlag) return; // 防止多次初始化
    chartInitFlag = true;
    peakChart = new Chart(document.getElementById('peakChart') as HTMLCanvasElement, {
      type: 'bar',
      data: {
        labels: peakData.value.map(d => d.period),
        datasets: [{
          label: '就餐人数',
          data: peakData.value.map(d => d.count),
          backgroundColor: '#165DFF'
        }]
      },
      options: {
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true } }
      }
    });
    topDishChart = new Chart(document.getElementById('topDishChart') as HTMLCanvasElement, {
      type: 'bar',
      data: {
        labels: topDishData.value.map(d => d.name),
        datasets: [
          {
            label: '销量',
            data: topDishData.value.map(d => d.sales),
            backgroundColor: '#36CFC9'
          },
          {
            label: '利润',
            data: topDishData.value.map(d => d.profit),
            backgroundColor: '#FAAD14'
          }
        ]
      },
      options: {
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true } }
      }
    });
    comboChart = new Chart(document.getElementById('comboChart') as HTMLCanvasElement, {
      type: 'pie',
      data: {
        labels: comboData.value.map(d => d.mainDish + '+' + d.comboDish),
        datasets: [{
          data: comboData.value.map(d => parseInt(d.rate)),
          backgroundColor: ['#165DFF', '#36CFC9', '#FAAD14', '#722ED1']
        }]
      },
      options: {
        plugins: { legend: { position: 'bottom' } }
      }
    });
    waiterChart = new Chart(document.getElementById('waiterChart') as HTMLCanvasElement, {
      type: 'bar',
      data: {
        labels: waiterData.value.map(d => d.name),
        datasets: [
          {
            label: '接单量',
            data: waiterData.value.map(d => d.orderCount),
            backgroundColor: '#165DFF'
          },
          {
            label: '退菜率',
            data: waiterData.value.map(d => parseFloat(d.returnRate)),
            backgroundColor: '#FF4D4F'
          },
          {
            label: '顾客评价',
            data: waiterData.value.map(d => parseFloat(d.rating)),
            backgroundColor: '#36CFC9'
          }
        ]
      },
      options: {
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true } }
      }
    });
    storeChart = new Chart(document.getElementById('storeChart') as HTMLCanvasElement, {
      type: 'bar',
      data: {
        labels: storeData.value.map(d => d.name),
        datasets: [
          {
            label: '营业额',
            data: storeData.value.map(d => d.revenue),
            backgroundColor: '#165DFF'
          },
          {
            label: '利润率',
            data: storeData.value.map(d => d.profitRate),
            backgroundColor: '#FAAD14'
          }
        ]
      },
      options: {
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true } }
      }
    });
    orderChart = new Chart(document.getElementById('orderChart') as HTMLCanvasElement, {
      type: 'doughnut',
      data: {
        labels: orderData.value.map(d => d.store),
        datasets: [{
          data: orderData.value.map(d => d.takeawayRate),
          backgroundColor: ['#165DFF', '#36CFC9', '#FAAD14']
        }]
      },
      options: {
        plugins: { legend: { position: 'bottom' } }
      }
    });
  }, 100);
});

onActivated(() => {
  destroyCharts();
});

onUnmounted(() => {
  destroyCharts();
  if (refreshTimer) clearInterval(refreshTimer);
});
</script>

<style scoped>
.report-dashboard-container {
  padding: 24px;
  background: #f5f7fa;
  min-height: 100vh;
}
.dashboard-header {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
}
.dashboard-title {
  font-size: 22px;
  font-weight: 600;
  color: #165DFF;
}
.dashboard-row {
  display: flex;
  gap: 24px;
  margin-bottom: 24px;
  height: auto;
}
.dashboard-card {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
.kpi-card, .peak-card, .dish-card, .unsalable-card, .combo-card, .waiter-card, .store-card, .order-card {
  min-width: 340px;
  max-width: 480px;
}
.card-title {
  font-size: 16px;
  font-weight: 500;
  color: #333;
  margin-bottom: 12px;
}
.kpi-value {
  font-size: 18px;
  color: #444;
  margin-top: 8px;
}
.kpi-number {
  font-size: 28px;
  font-weight: bold;
  color: #165DFF;
  margin-right: 8px;
}
.kpi-desc {
  font-size: 14px;
  color: #888;
}
.kpi-label {
  font-size: 16px;
  color: #333;
  margin-right: 4px;
}
canvas {
  width: 100% !important;
  max-width: 100%;
  height: 220px !important;
  margin-bottom: 16px;
  }
</style>