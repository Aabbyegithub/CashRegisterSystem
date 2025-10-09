<template>
  <view class="queue-manage-page">
    <!-- 顶部统计栏 -->
    <view class="queue-header">
      <view class="queue-stats">
        <view class="queue-stat">
          <view class="queue-stat-label">当前排队</view>
          <view class="queue-stat-value">{{ stats.current }}</view>
        </view>
        <view class="queue-stat">
          <view class="queue-stat-label">已完成</view>
          <view class="queue-stat-value">{{ stats.finished }}</view>
        </view>
        <view class="queue-stat">
          <view class="queue-stat-label">今日总号</view>
          <view class="queue-stat-value">{{ stats.today }}</view>
        </view>
      </view>
    </view>
    <!-- 新增排队按钮 -->
    <view class="queue-add-btn-box">
      <u-button type="primary" icon="plus-circle-fill" custom-style="width:100%;height:40px;font-size:15px;background:#1E8090;border-radius:12px;" @click="showAddDialog=true">
        新增排队
      </u-button>
    </view>
    <!-- 当前排队列表 -->
    <view class="queue-section-title">当前排队列表</view>
    <view class="queue-update-tip">更新于：刚刚</view>
    <view class="queue-list">
      <view v-for="item in queueList" :key="item.queue_id" class="queue-card" :class="item.status===1?'waiting':item.status===2?'processing':'other'">
        <view class="queue-card-left">
          <view class="queue-status-tag" :class="item.status===1?'tag-wait':item.status===2?'tag-process':'tag-other'">
            {{ item.status===2?'处理中':item.status===1?'等待中':'过号' }}
          </view>
          <!-- <view class="queue-customer">顾客：{{ item.customer_name }}</view> -->
          <view class="queue-no">排队号：{{ item.queue_no }}</view>
          <view class="queue-party-size">用餐人数: {{ item.party_size }}</view>
        </view>
        <view class="queue-card-right">
          <view class="queue-wait-label">等待时间</view>
          <view class="queue-wait-time" :class="item.status===1?'time-red':'time-normal'">{{ item.wait_time || '-' }}</view>
          <view class="queue-card-actions">
            <u-button v-if="item.status===1 || item.status ===2" size="mini" custom-style="margin-right:10px" @click="skip(item)">过号</u-button>
            <u-button v-if="item.status===2" type="success" size="mini" @click="finish(item)">完成</u-button>
            <u-button v-if="item.status===1" size="mini" custom-style="margin-right:10px" @click="call(item)">叫号</u-button>
            <u-button v-if="item.status===1 || item.status ===2" type="error" size="mini" @click="cancel(item)">取消</u-button>
          </view>
        </view>
      </view>
    </view>
    <!-- 最近完成 -->
    <!-- <view class="queue-section-title" style="margin-top:32px;">最近完成</view>
    <view class="queue-list">
      <view v-for="item in finishedList" :key="item.queue_id" class="queue-card finished">
        <view class="queue-customer">{{ item.customer_name }}</view>
        <view class="queue-no">排队号: #{{ item.queue_no }}</view>
        <view class="queue-finished-tag">已完成</view>
      </view>
    </view> -->
    <!-- 新增排队弹窗 -->
    <u-popup :show="showAddDialog" mode="center" @close="showAddDialog=false" custom-style="border-radius:20px;overflow:hidden;">
      <view class="create-queue-form" style="max-width:340px; border-radius:20px; position:relative;">
        <!-- 关闭按钮 -->
        <u-icon name="close" size="28" color="#999" @click="showAddDialog=false"
          style="position:absolute;top:16px;right:16px;z-index:2;cursor:pointer;" />
        <view style="height:28px"></view>
        <!-- <view class="form-row">
          <view class="form-label">顾客姓名</view>
          <u-input v-model="form.customer_name" placeholder="请输入顾客姓名" custom-style="background:#f6fbfc;border-radius:8px;" />
        </view>
        <view class="form-row">
          <view class="form-label">顾客电话</view>
          <u-input v-model="form.customer_phone" placeholder="请输入顾客电话" custom-style="background:#f6fbfc;border-radius:8px;" />
        </view> -->
        <view class="form-row">
          <view class="form-label">用餐人数</view>
          <u-number-box v-model="form.party_size" min="1" max="20" />
        </view>
        <view class="form-row">
          <view class="form-label">备注：</view>
          <u-input v-model="form.customer_phone" placeholder="是否有特殊注意" custom-style="background:#f6fbfc;border-radius:8px;" />
        </view>
        <u-button type="primary" custom-style="width:100%;margin:24px auto 0;background:#1E8090;border-radius:8px;font-size:18px;" @click="submitQueue">确认新增</u-button>
      </view>
    </u-popup>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { request } from '@/utitl/request'
import { onLoad, onUnload } from '@dcloudio/uni-app'
const stats = ref({
  current: 0,
  finished: 0,
  today: 0
})
const showAddDialog = ref(false)
const form = ref({
  customer_name: '',
  customer_phone: '',
  party_size: 1,
  remark: ''
})
const queueList = ref<any[]>([])
const finishedList = ref([])

async function fetchQueueList() {
  await request({
    url: '/api/Queue/GetQueueList',
    method: 'GET'
  }).then((res: any) => {
    if (res.success && res.response) {
      queueList.value = res.response
      queueList.value.forEach((item:any)=>{
        if(item.status ===1 || item.status ===2 ){
          // 计算等待时间
          const created = new Date(item.created_at)
          const now = new Date()
          const diffMs = now.getTime() - created.getTime()
          const diffMins = Math.floor(diffMs / 60000)
          item.wait_time = diffMins < 60 ? `${diffMins}分钟` : `${Math.floor(diffMins/60)}小时${diffMins%60}分钟`
        }else{
          item.wait_time = '-'
        }
      })
    }
  })
}
async function fetchQueueStats() {
  await request({
    url: '/api/Queue/GetAppQueueStats',
    method: 'GET'
  }).then((res: any) => {
    if (res.success && res.response) {
      stats.value.current = res.response.waitingCount
      stats.value.finished = res.response.finished
      stats.value.today = res.response.totalToday
    }
  })
}
async function submitQueue() {
  await request({
    url: '/api/Queue/AddQueue',
    method: 'POST',
    data: {
      party_size: form.value.party_size,
      remark: form.value.remark
    }
  }).then((res: any) => {
    if (res.success) {
      showAddDialog.value = false
      uni.showToast({ title: '新增成功', icon: 'success' })
      fetchQueueList()
      fetchQueueStats()
    } else {
      uni.showToast({ title: res.message || '新增失败', icon: 'none' })
    }
  })
}
async function skip(item: any) {
  await request({
    url: `/api/Queue/SkipQueue?queueId=${item.queue_id}`,
    method: 'POST',
    // data: { queueId: item.queue_id }
  }).then((res: any) => {
    if (res.success) {
      uni.showToast({ title: '已过号', icon: 'success' })
      fetchQueueList()
      fetchQueueStats()
    } else {
      uni.showToast({ title: res.message || '操作失败', icon: 'none' })
    }
  })
}
async function finish(item: any) {
  await request({
    url: `/api/Queue/finishQueue?queueId=${item.queue_id}`,
    method: 'POST',
    // data: { queueId: item.queue_id }
  }).then((res: any) => {
    if (res.success) {
      uni.showToast({ title: '已完成', icon: 'success' })
      fetchQueueList()
      fetchQueueStats()
    } else {
      uni.showToast({ title: res.message || '操作失败', icon: 'none' })
    }
  })
}
async function call(item: any) {
  await request({
    url: `/api/Queue/CallQueue?queueId=${item.queue_id}`,
    method: 'POST',
    // data: { queueId: item.queue_id }
  }).then((res: any) => {
    if (res.success) {
      uni.showToast({ title: '已叫号', icon: 'success' })
      fetchQueueList()
      fetchQueueStats()
    } else {
      uni.showToast({ title: res.message || '操作失败', icon: 'none' })
    }
  })
}
async function cancel(item: any) {
  await request({
    url: '/api/Queue/CancelQueue?queueId='+item.queue_id,
    method: 'POST',
    // data: { queueId: item.queue_id }
  }).then((res: any) => {
    if (res.success) {
      uni.showToast({ title: '已取消', icon: 'success' })
      fetchQueueList()
      fetchQueueStats()
    } else {
      uni.showToast({ title: res.message || '操作失败', icon: 'none' })
    }
  })
}

let queueTimer: any = null
onLoad(() => {
  fetchQueueList()
  fetchQueueStats()
  queueTimer = setInterval(() => {
    fetchQueueList()
    fetchQueueStats()
  }, 5000 *6)
})
onUnload(() => {
  if (queueTimer) clearInterval(queueTimer)
})
</script>

<style scoped>
.queue-manage-page {
  min-height: 100%;
  background: #f6f7f9;
  padding-bottom: 32px;
}
.queue-header {
  background: #1E8090;
  padding: 24px 0 18px 0;
  text-align: center;
  color: #fff;
  border-radius: 0 0 24px 24px;
}
.queue-title {
  font-size: 26px;
  font-weight: bold;
  margin-bottom: 18px;
}
.queue-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 10px;
}
.queue-stat {
  text-align: center;
}
.queue-stat-label {
  font-size: 16px;
  color: #e3e7f7;
}
.queue-stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-top: 4px;
}
.queue-add-btn-box {
  margin: 10px 24px 0 24px;
}
.queue-section-title {
  font-size: 15px;
  font-weight: bold;
  margin: 10px 0 12px 24px;
  display: inline-block;
}
.queue-update-tip {
  font-size: 14px;
  color: #888;
  margin-left: 200px;
  margin-bottom: 12px;
  display: inline-block;
}
.queue-view-all {
  float: right;
  font-size: 16px;
  color: #1976f3;
  margin-right: 32px;
  margin-top: 6px;
  cursor: pointer;
}
.queue-list {
  margin: 0 14px 0 14px;
  overflow-y: auto;
  height: calc(100vh - 380px);
}
.queue-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(25,118,243,0.06);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 18px 18px 12px 18px;
  margin-bottom: 18px;
}
.queue-card.finished {
  align-items: center;
  padding: 18px 18px;
}
.queue-card-left {
  flex: 1;
}
.queue-status-tag {
  display: inline-block;
  padding: 3px 14px;
  border-radius: 12px;
  font-size: 15px;
  margin-bottom: 8px;
}
.tag-process {
  background: #e0f7fa;
  color: #1dbb7c;
}
.tag-wait {
  background: #fff7e6;
  color: #ff9800;
}
.tag-other {
  background: #eee;
  color: #888;
}
.queue-customer {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 4px;
}
.queue-no {
  font-size: 15px;
  color: #888;
  margin-bottom: 10px;
}
.queue-card-right {
  text-align: right;
  min-width: 120px;
}
.queue-wait-label {
  font-size: 15px;
  color: #666;
}
.queue-wait-time {
  font-size: 22px;
  font-weight: bold;
  margin-bottom: 8px;
}
.time-red {
  color: #e53935;
}
.time-normal {
  color: #333;
}
.queue-card-actions {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}
.queue-finished-tag {
  background: #eee;
  color: #888;
  border-radius: 12px;
  padding: 3px 14px;
  font-size: 15px;
  margin-left: 12px;
}
.create-queue-form {
  padding: 32px 24px 24px 24px;
  background: #fff;
  border-radius: 24px !important;
  margin: 0 auto;
  box-shadow: 0 8px 32px rgba(25,118,243,0.08);
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
  position: relative;
}
.form-label {
  width: 90px;
  color: #333;
  font-size: 16px;
}
</style>