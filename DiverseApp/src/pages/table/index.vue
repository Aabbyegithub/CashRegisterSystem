<template>
  <view class="table-page">
    <view class="table-area">大堂</view>
    <view class="table-grid">
      <view v-for="table in tables" :key="table.id" :class="['table-card', table.status === 2 ? 'used-red' : table.status, selectedTable?.id === table.id ? 'selected' : '']" @click="handleTableClick(table)">
        <view class="table-name">{{ table.name }}</view>
        <view class="table-status">{{ table.status === 1 ? '空闲' : (table.status === 2 ? '使用中' : (table.status === 3 ? '预订':'清洁中')) }}</view>
        <view style="display: flex;">
          <view class="table-info">{{ table.people }}/{{ table.max }}</view>
          <view v-if="table.status === 3" class="table-booked-time">{{ table.bookedTime }}</view>
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
import { onMounted, ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { request } from '@/utitl/request'
// 桌台数据示例
const tables = ref<any[]>([])
const showOpenDialog = ref(false)
const selectedTable = ref<any>(null)
const selectStoreId = ref(0)
const openPeople = ref(1)

function handleTableClick(table: any) {
  if (table.status === 1) {
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
  selectedTable.value.status = 2
  selectedTable.value.people = openPeople.value
  showOpenDialog.value = false
  // 跳转前存储参数
  uni.setStorageSync('TableInfo',{
    tableId: selectedTable.value.id,
    storeId:  selectStoreId.value,
    people: openPeople.value,
    tableName: selectedTable.value.name
  })
  uni.switchTab({
    url: '../menu/index'
  })
}

//获取桌台数据
async function GetTables(store_id: number) {
  await request({
    url: '/api/Client/GetTableListInfo',
    method: 'GET',
    data: {
      store_id:store_id
    }
  }).then((res: any) => {
    console.log('获取桌台数据', res)
    tables.value = res.response || []
  })
}

// 自动弹窗开台逻辑，扫码进入页面带参数 id 时自动弹窗
onLoad((options: any) => {
  const { tableId, storeId } = options
  let actualStoreId = storeId
  if (!actualStoreId) {    
    actualStoreId = JSON.parse(uni.getStorageSync('UserInfo')).orgId || 2
  }
  selectStoreId.value = actualStoreId
  //获取桌台数据
  GetTables(actualStoreId)
  if (tableId) {
    // 查找对应桌台，且仅空闲桌台可弹窗
    const table = tables.value.find(t => String(t.id) === String(tableId) && t.status === 1)
    if (table) {
      selectedTable.value = table
      openPeople.value = 1
      showOpenDialog.value = true
    }
  }
})
onShow(() => {
  // 页面加载时获取桌台数据
  GetTables(selectStoreId.value)
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

.table-card.used-red {
  border-color: #F04216;
  background: #F04216;
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
