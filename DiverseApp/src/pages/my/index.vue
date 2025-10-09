<template>
  <view class="my-container">
    <!-- 顶部背景区域 -->
    <view class="top-bg">
      <!-- 背景图片 -->
      <image class="bg-image" src="/static/mytop.png" mode="aspectFill"></image>
      <!-- 用户信息 -->
      <view class="user-info">
        <image class="avatar" src="/static/Frame.png" mode="aspectFill"></image>
        <view class="user-name">星空ASFEGF</view>
      </view>
    </view>

    <!-- 设置选项列表 -->
    <view class="settings-list">
      <view class="setting-item" @click="gobankcard">
        <view class="item-icon">
          <image src="/static/Frame(8).png" mode="aspectFit"></image>
        </view>
        <view class="item-text">银行卡设置</view>
        <view class="item-arrow">
            <u-icon
                  size="24"
                  name="arrow-right"
                  custom-style="width:50px;float:right;color:#0E8A9E;margin-right:-40px;"
            ></u-icon>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
function gobankcard() {
  uni.navigateTo({
    url: '/pages/my/bankcard'
  })
}
// 可以添加必要的数据和方法
</script>

<style>
.my-container {
  display: flex;
  flex-direction: column;
  /* height: 100vh; */
  background-color: #f5f5f5;
}

.top-bg {
  /* 移除background相关属性 */
  background-color: #e0f7fa;
  height: 500rpx;
  padding: 40rpx;
  width: 100%;
  border-radius: 0 0 20rpx 20rpx;
  margin-bottom: 20rpx;
  margin-top: -10px;
  position: relative; /* 添加相对定位 */
  overflow: hidden; /* 防止图片超出容器 */
}

/* 添加背景图片样式 */
.bg-image {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0; /* 确保图片在底层 */
}

.user-info {
  display: flex;
  align-items: center;
  padding: 20rpx 0;
  margin-top: 50px;
  position: relative;
  z-index: 1; /* 确保用户信息在上层 */
}

.avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  margin-right: 30rpx;
  border: 4rpx solid #ffffff;
}

.user-name {
  font-size: 40rpx;
  font-weight: bold;
  color: #333333;
}

.settings-list {
  background-color: #ffffff;
  border-radius: 15rpx;
  /* margin: 0 20rpx; */
  margin-top: -140px;
  overflow: hidden;
  height:calc(100vh - 550rpx);
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
  z-index: 999;
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 30rpx;
  border-bottom: 2rpx solid #f0f0f0;
}

.setting-item:last-child {
  border-bottom: none;
}

.item-icon {
  width: 50rpx;
  height: 50rpx;
  margin-right: 30rpx;
}

.item-icon image {
  width: 100%;
  height: 100%;
}

.item-text {
  flex: 1;
  font-size: 32rpx;
  color: #333333;
}

.item-arrow {
  width: 50rpx;
  height: 50rpx;
}

.item-arrow image {
  width: 100%;
  height: 100%;
}
</style>
