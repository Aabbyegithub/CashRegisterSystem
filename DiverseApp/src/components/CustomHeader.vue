<template>
  <view class="header">
    <view class="search-box">
      <image src="/src/static/Frame(10).png" style="width:18px;height:18px;vertical-align:middle;margin-right:8px;" />
      <input
        class="search-input"
        type="text"
        :value="searchValue"
        :placeholder="searchPlaceholder"
        @input="onInput"
        placeholder-style="color:#C6E6EC"
      />
    </view>
    <view class="title">{{ title }}</view>
  </view>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  title: { type: String, default: '标题' },
  searchValue: { type: String, default: '' },
  searchPlaceholder: { type: String, default: '搜索' },
  icon: { type: String, default: '/src/static/Frame.png' }
})
const emit = defineEmits(['update:searchValue', 'search'])

function onInput(e: any) {
  emit('update:searchValue', e.detail.value)
  emit('search', e.detail.value)
}
</script>

<style scoped>
.header {
  background:#1E8090 ;
  padding: 40rpx 0 20rpx 0;
  position: relative;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.search-box {
  position: absolute;
  left: 30rpx;
  /* top: 50%; */
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  background: rgba(255,255,255,0.15);
  border: 1px solid #e5e5e5;
  border-radius: 30rpx;
  padding: 0 20rpx;
  height: 48rpx;
  margin-top: 40rpx;

}
.search-input {
  border: none;
  background: transparent;
  /* color: #ffffff !important; */
  font-size: 28rpx;
  outline: none;
  width: 120rpx;
}
.title {
  color: #ffffff;
  font-size: 25rpx;
  font-weight: bold;
  text-align: center;
  /* margin-bottom: -30px; */

}
</style>
