<template>
  <div class="core-kpi-container">
    <div class="page-header">
      <h2 class="page-title">餐饮核心指标报表</h2>
    </div>
    <el-row :gutter="24" class="report-row">
      <!-- 翻台率 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">翻台率</div>
          <div class="kpi-value">
            <span class="kpi-number">{{ turnoverRate }}</span>
            <span class="kpi-desc">（当日桌台使用次数 / 总桌台数）</span>
          </div>
        </el-card>
      </el-col>
      <!-- 人均消费、客单价 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">人均消费 / 客单价</div>
          <div class="kpi-value">
            <div>
              <span class="kpi-label">人均消费：</span>
              <span class="kpi-number">¥{{ avgPerPerson }}</span>
            </div>
            <div>
              <span class="kpi-label">客单价：</span>
              <span class="kpi-number">¥{{ avgPerOrder }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <!-- 时段客流高峰分析 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">时段客流高峰分析</div>
          <el-table :data="peakData" style="width: 100%" size="small">
            <el-table-column prop="period" label="时段" />
            <el-table-column prop="count" label="就餐人数" />
            <el-table-column prop="rate" label="占比" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';

// 模拟数据
const turnoverRate = ref('2.3'); // 翻台率
const avgPerPerson = ref('85.6'); // 人均消费
const avgPerOrder = ref('210.4'); // 客单价

const peakData = ref([
  { period: '早餐 07:00-09:00', count: 120, rate: '12%' },
  { period: '午餐 11:30-13:30', count: 420, rate: '42%' },
  { period: '晚餐 18:00-20:00', count: 400, rate: '40%' },
  { period: '其他时段', count: 60, rate: '6%' }
]);

onMounted(() => {
  // 可在此处请求接口获取数据
});
</script>

<style scoped>
.core-kpi-container {
  padding: 24px;
  background: #f5f7fa;
  min-height: 100vh;
}
.page-header {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
}
.page-title {
  font-size: 22px;
  font-weight: 600;
  color: #165DFF;
}
.report-row {
  margin-top: 0;
}
.report-card {
  margin-bottom: 24px;
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
</style>