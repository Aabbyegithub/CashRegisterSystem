<template>
  <view class="table-page">
    <view class="table-area">大堂</view>
    <view class="table-grid">
      <view v-for="table in tables" :key="table.id" :class="['table-card', table.status, selectedTable?.id === table.id ? 'selected' : '']" @click="handleTableClick(table)">
        <view class="table-name">{{ table.name }}</view>
        <view class="table-status">{{ table.status === 'free' ? '空闲' : (table.status === 'booked' ? '预定' : '使用中') }}</view>
        <view style="display: flex;">
          <view class="table-info">{{ table.people }}/{{ table.max }}</view>
          <view v-if="table.status === 'booked'" class="table-booked-time">{{ table.bookedTime }}</view>
        </view>
      </view>
    </view>
    <!-- 开台弹窗 -->
    <u-popup  :show="showOpenDialog" mode="center" @close="showOpenDialog = false">
      <view class="open-dialog">
        <view class="open-title">开台确认</view>
        <view class="open-table-name">{{ selectedTable?.name }}桌</view>
        <view class="open-label">用餐人数</view>
        <view class="open-people">
          <u-icon name="arrow-left" size="28" @click="changePeople(-1)" custom-style="margin-right:20px" />
          <view class="open-people-num">{{ openPeople }}</view>
          <u-icon name="arrow-right" size="28" @click="changePeople(1)" custom-style="margin-left:20px" />
        </view>
        <view class="open-btns">
          <u-button custom-style="width:40%;margin-right:20px;border-radius: 50rpx;" @click="showOpenDialog = false">取消</u-button>
          <u-button type="primary" custom-style="width:40%;background:#0E8A9E;border-radius: 50rpx;" @click="confirmOpen">开台</u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
// 桌台数据示例
const tables = ref([
  { id: 1, name: 'A1', status: 'free', people: 0, max: 5 },
  { id: 2, name: 'A2', status: 'free', people: 0, max: 3 },
  { id: 3, name: 'A3', status: 'free', people: 0, max: 3 },
  { id: 4, name: '1', status: 'used', people: 5, max: 5, usedTime: '00:30' },
  { id: 5, name: '2', status: 'booked', people: 3, max: 3, bookedTime: '今晚8点' },
  { id: 6, name: '3', status: 'free', people: 0, max: 5 },
  { id: 7, name: '4', status: 'used', people: 5, max: 5, usedTime: '00:30' },
  { id: 8, name: '5', status: 'used', people: 5, max: 5, usedTime: '00:30' },
  { id: 9, name: '6', status: 'used', people: 5, max: 5, usedTime: '00:30' },
  { id: 10, name: '7', status: 'used', people: 5, max: 5, usedTime: '00:30' },
  { id: 11, name: '8', status: 'booked', people: 3, max: 3, bookedTime: '明日10点' },
  { id: 12, name: '9', status: 'free', people: 0, max: 6 },
  { id: 13, name: '10', status: 'free', people: 0, max: 6 },
  { id: 14, name: '11', status: 'free', people: 0, max: 4 },
  { id: 15, name: '12', status: 'free', people: 0, max: 3 },
])
const showOpenDialog = ref(false)
const selectedTable = ref<any>(null)
const openPeople = ref(1)

function handleTableClick(table: any) {
  if (table.status === 'free') {
    selectedTable.value = table
    openPeople.value = 1
    showOpenDialog.value = true
  }
}
function changePeople(val: number) {
  if (!selectedTable.value) return
  const max = selectedTable.value.max
  const min = 1
  let next = openPeople.value + val
  if (next < min) next = min
  if (next > max) next = max
  openPeople.value = next
}
function confirmOpen() {
  if (!selectedTable.value) return
  selectedTable.value.status = 'used'
  selectedTable.value.people = openPeople.value
  showOpenDialog.value = false
  uni.switchTab({
    url: `../menu/index?id=${selectedTable.value.id}`
  })
}

// 自动弹窗开台逻辑，扫码进入页面带参数 id 时自动弹窗
onLoad((options: any) => {
  // 兼容扫码参数为 id 或 tableId
  const tableId = options.id || options.tableId
  if (tableId) {
    // 查找对应桌台，且仅空闲桌台可弹窗
    const table = tables.value.find(t => String(t.id) === String(tableId) && t.status === 'free')
    if (table) {
      selectedTable.value = table
      openPeople.value = 1
      showOpenDialog.value = true
    }
  }
})
</script>

<style>
.table-page {
  background: #f5f5f5;
  min-height: 100vh;
}
.table-header {
  background: linear-gradient(90deg,#0E8A9E,#1CB5E0);
  color: #fff;
  font-size: 36rpx;
  text-align: center;
  padding: 30rpx 0 10rpx 0;
  font-weight: bold;
}
.table-area {
  font-size: 28rpx;
  color: #333;
  padding: 20rpx 0 10rpx 30rpx;
  font-weight: bold;
}
.table-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
  padding: 0 20rpx 20rpx 20rpx;
  overflow-y: auto;
}
.table-card {
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
  padding: 20rpx 0 10rpx 0;
  text-align: center;
  position: relative;
  border: 2rpx solid #eee;
  cursor: pointer;
  transition: border-color 0.2s;
}
.table-card.selected {
  border-color: #F04216;
  background: #FFF6F2;
}
.table-card.free {
  color: #333;
}
.table-card.used {
  color: #0E8A9E;
}
.table-card.booked {
  color: #F04216;
}
.table-name {
  font-size: 32rpx;
  font-weight: bold;
  margin-bottom: 10rpx;
}
.table-status {
  font-size: 26rpx;
  color: #888;
  margin-bottom: 8rpx;
}
.table-info {
  font-size: 22rpx;
  color: #bbb;
  margin-bottom: 4rpx;
  margin-left: 20rpx;
}
.table-booked-time {
  font-size: 22rpx;
  color: #F04216;
  margin-top: 2rpx;
  margin-left: auto;
  margin-right: 20rpx;
}
.open-dialog {
  background: #fff;
  border-radius: 16rpx;
  padding: 40rpx 30rpx 30rpx 30rpx;
  width: 70vw;
  max-width: 400px;
  text-align: center;
}
.open-title {
  font-size: 30rpx;
  font-weight: bold;
  color: #0E8A9E;
  margin-bottom: 20rpx;
  text-align: left;
}
.open-table-name {
  font-size: 32rpx;
  font-weight: bold;
  color: #222;
  margin-bottom: 30rpx;
  text-align: left;
}
.open-label {
  font-size: 28rpx;
  color: #333;
  margin-bottom: 10rpx;
}
.open-people {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 30rpx;
}
.open-people-num {
  font-size: 32rpx;
  font-weight: bold;
  color: #222;
  width: 60px;
  text-align: center;
}
.open-btns {
  display: flex;
  justify-content: center;
  gap: 20rpx;
  margin-top: 20rpx;
}
</style>
