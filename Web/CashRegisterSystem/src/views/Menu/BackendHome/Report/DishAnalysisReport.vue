<template>
  <div class="dish-analysis-container">
    <!-- <div class="page-header">
      <h2 class="page-title">菜品分析报表</h2>
    </div> -->
    <el-row :gutter="24" class="report-row">
      <!-- 畅销菜品 TOP10 -->
      <el-col :span="12">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">畅销菜品 TOP10（销量/利润）</div>
          <el-table :data="topDishData" style="width: 100%" size="small">
            <el-table-column prop="rank" label="排名" width="60"/>
            <el-table-column prop="name" label="菜品名称" />
            <el-table-column prop="sales" label="销量（份）" />
            <el-table-column prop="profit" label="利润（元）" />
          </el-table>
        </el-card>
      </el-col>
      <!-- 滞销菜品预警 -->
      <el-col :span="12">
        <el-card shadow="hover" class="report-card">
          <div class="card-title">滞销菜品预警（连续两周销量＜10份）</div>
          <el-table :data="unsalableDishData" style="width: 100%" size="small">
            <el-table-column prop="name" label="菜品名称" />
            <el-table-column prop="sales" label="近两周销量" />
            <el-table-column prop="warning" label="预警" >
              <template #default="scope">
                <el-tag type="danger" v-if="scope.row.sales < 10">滞销</el-tag>
                <el-tag type="success" v-else>正常</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
    <!-- 菜品搭配分析 -->
    <el-card shadow="hover" class="report-card" style="margin-top:24px;">
      <div class="card-title">菜品搭配分析</div>
      <el-table :data="comboData" style="width: 100%" size="small">
        <el-table-column prop="mainDish" label="主菜品" />
        <el-table-column prop="comboDish" label="常搭配菜品" />
        <el-table-column prop="rate" label="搭配率" />
      </el-table>
    </el-card>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';

// 畅销菜品 TOP10（模拟数据）
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

// 滞销菜品预警（模拟数据）
const unsalableDishData = ref([
  { name: '清炒西兰花', sales: 6, warning: true },
  { name: '蒜蓉粉丝扇贝', sales: 8, warning: true },
  { name: '糖醋里脊', sales: 12, warning: false },
  { name: '干锅花菜', sales: 9, warning: true }
]);

// 菜品搭配分析（模拟数据）
const comboData = ref([
  { mainDish: '火锅', comboDish: '肥牛', rate: '80%' },
  { mainDish: '火锅', comboDish: '金针菇', rate: '65%' },
  { mainDish: '烤鱼', comboDish: '土豆片', rate: '70%' },
  { mainDish: '麻辣小龙虾', comboDish: '啤酒', rate: '85%' }
]);

onMounted(() => {
  // 可在此处请求接口获取数据
});
</script>

<style scoped>
.dish-analysis-container {
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