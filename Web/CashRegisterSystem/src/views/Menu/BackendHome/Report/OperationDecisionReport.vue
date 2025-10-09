<template>
  <div class="operation-report-container">
    <!-- <div class="page-header">
      <h2 class="page-title">运营决策报表</h2>
    </div> -->
    <el-row :gutter="24" class="report-row">
      <!-- 服务员绩效 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">服务员绩效</div>
          <el-table :data="waiterData" style="width: 100%" size="small">
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="orderCount" label="接单量" />
            <el-table-column prop="returnRate" label="退菜率" />
            <el-table-column prop="rating" label="顾客评价" />
          </el-table>
        </el-card>
      </el-col>
      <!-- 门店对比 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">门店对比</div>
          <el-table :data="storeData" style="width: 100%" size="small">
            <el-table-column prop="name" label="门店" />
            <el-table-column prop="revenue" label="营业额" />
            <el-table-column prop="profitRate" label="利润率" />
            <el-table-column prop="rank" label="排名" />
          </el-table>
        </el-card>
      </el-col>
      <!-- 外卖订单占比分析 -->
      <el-col :span="8">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">外卖订单占比分析</div>
          <el-table :data="orderData" style="width: 100%" size="small">
            <el-table-column prop="store" label="门店" />
            <el-table-column prop="online" label="线上营收" />
            <el-table-column prop="offline" label="线下营收" />
            <el-table-column prop="takeawayRate" label="外卖占比" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';

// 模拟数据
const waiterData = ref([
  { name: '张三', orderCount: 120, returnRate: '2.5%', rating: '4.8' },
  { name: '李四', orderCount: 98, returnRate: '1.8%', rating: '4.6' },
  { name: '王五', orderCount: 110, returnRate: '3.1%', rating: '4.7' }
]);

const storeData = ref([
  { name: '旗舰店', revenue: '¥120,000', profitRate: '18%', rank: 1 },
  { name: '分店A', revenue: '¥85,000', profitRate: '15%', rank: 2 },
  { name: '分店B', revenue: '¥60,000', profitRate: '12%', rank: 3 }
]);

const orderData = ref([
  { store: '旗舰店', online: '¥40,000', offline: '¥80,000', takeawayRate: '33%' },
  { store: '分店A', online: '¥30,000', offline: '¥55,000', takeawayRate: '35%' },
  { store: '分店B', online: '¥20,000', offline: '¥40,000', takeawayRate: '33%' }
]);

onMounted(() => {
  // 可在此处请求接口获取数据
});
</script>

<style scoped>
.operation-report-container {
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
</style>