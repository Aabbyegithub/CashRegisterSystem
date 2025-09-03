<template>
  <div class="home-container">
    <div class="home-header">
      <img src="/src/assets/首页.png" class="logo" alt="logo" />
      <div class="title">智慧餐饮收银管理系统</div>
      <div class="subtitle">高效 · 智能 · 安全 · 便捷</div>
    </div>
    <div class="home-content">
      <el-row gutter="32">
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/数据概览.png" class="card-icon" />
            <div class="card-title">数据概览</div>
            <div class="card-desc">门店、菜品、会员、订单等核心数据一览</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/订单管理.png" class="card-icon" />
            <div class="card-title">订单管理</div>
            <div class="card-desc">高效处理订单，支持多种支付方式</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/菜品管理.png" class="card-icon" />
            <div class="card-title">菜品管理</div>
            <div class="card-desc">菜品、配方、套餐、规格一站式管理</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/会员管理.png" class="card-icon" />
            <div class="card-title">会员中心</div>
            <div class="card-desc">会员储值、权益、积分、促销活动</div>
          </div>
        </el-col>
      </el-row>
      <el-row gutter="32" style="margin-top:32px;">
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/库存管理.png" class="card-icon" />
            <div class="card-title">库存采购</div>
            <div class="card-desc">原材料、采购、损耗、供应商全流程管控</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/厨房管理.png" class="card-icon" />
            <div class="card-title">厨房看板</div>
            <div class="card-desc">厨房任务、出餐记录、效率分析</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/系统设置.png" class="card-icon" />
            <div class="card-title">系统设置</div>
            <div class="card-desc">权限、定时任务、数据备份、日志管理</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="card">
            <img src="/src/assets/数据分析.png" class="card-icon" />
            <div class="card-title">数据分析</div>
            <div class="card-desc">销售、客流、成本、门店对比等多维报表</div>
          </div>
        </el-col>
      </el-row>
    </div>
    <div class="home-footer">
      <span>© 2025 智慧餐饮收银管理系统</span>
    </div>
  </div>
</template>

<script setup>
// 无需特殊功能
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafd 0%, #eaf6fb 100%);
  display: flex;
  flex-direction: column;
}
.home-header {
  text-align: center;
  padding: 48px 0 24px 0;
}
.logo {
  width: 80px;
  height: 80px;
  margin-bottom: 12px;
}
.title {
  font-size: 2.2rem;
  font-weight: bold;
  color: #22a2b6;
  margin-bottom: 8px;
}
.subtitle {
  font-size: 1.1rem;
  color: #888;
  margin-bottom: 16px;
}
.home-content {
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}
.card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(34,162,182,0.08);
  padding: 32px 18px 24px 18px;
  text-align: center;
  transition: box-shadow 0.2s;
  cursor: pointer;
  min-height: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.card:hover {
  box-shadow: 0 4px 24px rgba(34,162,182,0.18);
}
.card-icon {
  width: 48px;
  height: 48px;
  margin-bottom: 12px;
}
.card-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #165dff;
  margin-bottom: 6px;
}
.card-desc {
  font-size: 0.95rem;
  color: #666;
}
.home-footer {
  text-align: center;
  padding: 32px 0 12px 0;
  color: #aaa;
  font-size: 0.95rem;
}
</style>
