<template>
  <view class="menu-container">
    <CustomHeader
      :title="'A2桌点餐'"
      :searchValue="searchValue"
      :searchPlaceholder="'搜索'"
      @update:searchValue="val => searchValue = val"
      @search="handleSearch"
    />
    <view class="main-content">
      <view class="sidebar">
        <view
          v-for="item in categories"
          :key="item.id"
          :class="['sidebar-item', item.active ? 'active' : '']"
          @click="selectCategory(item.id)"
        >
          {{ item.name }}
        </view>
      </view>
      <view class="dish-list">
        <view v-for="dish in dishes" :key="dish.id" class="dish-item">
          <image :src="dish.img" class="dish-img" />
          <view class="dish-info">
            <view class="dish-title">{{ dish.name }}</view>
            <view class="dish-desc">{{ dish.desc }}</view>
            <view class="dish-price">￥{{ dish.price }}</view>
          </view>
          <u-button size="mini" custom-style="width:50px;float:right;">选购</u-button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import CustomHeader from '@/components/CustomHeader.vue'

const searchValue = ref('')
const categories = ref([
  { id: 1, name: '招牌推荐', active: true },
  { id: 2, name: '一人套餐', active: false },
  { id: 3, name: '家常小炒', active: false },
  { id: 4, name: '爽口凉菜', active: false },
  { id: 5, name: '主食', active: false },
  { id: 6, name: '汤', active: false },
  { id: 7, name: '酒水饮料', active: false }
])
const dishes = ref([
  { id: 1, name: '糖醋里脊', desc: '招牌特色菜', price: 28, img: '/src/static/Frame.png' },
  { id: 2, name: '麻婆豆腐', desc: '100+热销家常菜', price: 18, img: '/src/static/Frame(1).png' },
  { id: 3, name: '小炒黄牛肉', desc: '99%好评 老价位回归', price: 58, img: '/src/static/Frame(2).png' },
  { id: 4, name: '孜然肉片', desc: '香辣孜然，嫩滑', price: 28, img: '/src/static/Frame(3).png' },
  { id: 5, name: '手撕包菜', desc: '99%好评 老价位回归', price: 18, img: '/src/static/Frame(4).png' }
])

function selectCategory(id: number) {
  categories.value.forEach(item => item.active = item.id === id)
  // TODO: 切换分类时筛选菜品
}
function handleSearch(val:any) {
  // TODO: 搜索逻辑
}
</script>

<style>
.menu-container {
  background: #f5f5f5;
  height: 100vh
}
.main-content {
  display: flex;
  flex-direction: row;
  height: calc(100vh - 100px);
}
.sidebar {
  width: 120rpx;
  background: #fff;
  border-radius: 20rpx;
  margin: 20rpx 0 20rpx 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
  padding: 10rpx 0;
}
.sidebar-item {
  padding: 18rpx 0;
  text-align: center;
  color: #333;
  font-size: 28rpx;
  cursor: pointer;
}
.sidebar-item.active {
  color: #0080ff;
  font-weight: bold;
  background: #f0f7ff;
  border-radius: 10rpx;
}
.dish-list {
  flex: 1;
  padding: 20rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}
.dish-item {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 15rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
  padding: 20rpx;
}
.dish-img {
  width: 100rpx;
  height: 100rpx;
  border-radius: 10rpx;
  margin-right: 20rpx;
}
.dish-info {
  flex: 1;
}
.dish-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}
.dish-desc {
  font-size: 24rpx;
  color: #888;
  margin: 8rpx 0;
}
.dish-price {
  font-size: 28rpx;
  color: #ff4d4f;
  font-weight: bold;
}
</style>
