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
Chart.register(...registerables);

// 数据（同原来）
const turnoverRate = ref('2.3');
const avgPerPerson = ref('85.6');
const avgPerOrder = ref('210.4');
const peakData = ref([
  { period: '早餐', count: 120, rate: '12%' },
  { period: '午餐', count: 420, rate: '42%' },
  { period: '晚餐', count: 400, rate: '40%' },
  { period: '其他', count: 60, rate: '6%' }
]);
const topDishData = ref([
  { rank: 1, name: '肥牛火锅', sales: 320, profit: 4800 },
  { rank: 2, name: '麻辣小龙虾', sales: 280, profit: 4200 },
  { rank: 3, name: '烤鱼', sales: 260, profit: 3900 },
  { rank: 4, name: '酸菜鱼', sales: 240, profit: 3600 },
  { rank: 5, name: '香辣虾', sales: 220, profit: 3300 },
  { rank: 6, name: '干锅牛蛙', sales: 210, profit: 3150 },
  { rank: 7, name: '红烧肉', sales: 200, profit: 3000 },
  { rank: 8, name: '水煮牛肉', sales: 190, profit: 2850 },
  { rank: 9, name: '宫保鸡丁', sales: 180, profit: 2700 },
  { rank: 10, name: '鱼香肉丝', sales: 170, profit: 2550 }
]);
const unsalableDishData = ref([
  { name: '清炒西兰花', sales: 6, warning: true },
  { name: '蒜蓉粉丝扇贝', sales: 8, warning: true },
  { name: '糖醋里脊', sales: 12, warning: false },
  { name: '干锅花菜', sales: 9, warning: true }
]);
const comboData = ref([
  { mainDish: '火锅', comboDish: '肥牛', rate: '80%' },
  { mainDish: '火锅', comboDish: '金针菇', rate: '65%' },
  { mainDish: '烤鱼', comboDish: '土豆片', rate: '70%' },
  { mainDish: '麻辣小龙虾', comboDish: '啤酒', rate: '85%' }
]);
const waiterData = ref([
  { name: '张三', orderCount: 120, returnRate: '2.5%', rating: '4.8' },
  { name: '李四', orderCount: 98, returnRate: '1.8%', rating: '4.6' },
  { name: '王五', orderCount: 110, returnRate: '3.1%', rating: '4.7' }
]);
const storeData = ref([
  { name: '旗舰店', revenue: 120000, profitRate: 18, rank: 1 },
  { name: '分店A', revenue: 85000, profitRate: 15, rank: 2 },
  { name: '分店B', revenue: 60000, profitRate: 12, rank: 3 }
]);
const orderData = ref([
  { store: '旗舰店', online: 40000, offline: 80000, takeawayRate: 33 },
  { store: '分店A', online: 30000, offline: 55000, takeawayRate: 35 },
  { store: '分店B', online: 20000, offline: 40000, takeawayRate: 33 }
]);

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

onMounted(async () => {
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