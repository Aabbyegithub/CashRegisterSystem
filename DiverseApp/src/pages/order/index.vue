<template>
  <view class="order-container">
    <!-- 订单列表 -->
    <view class="order-list">
      <view v-for="order in orders" :key="order.id" class="order-item">
        <view class="order-header">
          <text class="table-number">桌号{{ order.tableNumber }}</text>
          <text :class="['status', order.status === '待支付' ? 'pending' : 'completed']">
            {{ order.status }}
          </text>
        </view>

        <view class="order-info">
          <view class="info-item">
            <text class="label">就餐人数</text>
            <text class="value">{{ order.peopleCount }}人</text>
          </view>
          <view class="info-item">
            <text class="label">下单时间</text>
            <text class="value">{{ order.orderTime }}</text>
          </view>
          <view class="info-item">
            <text class="label">消费金额</text>
            <text class="value">{{ order.amount }}元</text>
          </view>
          <view class="info-item">
            <text class="label">用餐时间</text>
            <text class="value">{{ order.diningTime }}</text>
          </view>
        </view>

        <view class="order-actions">
          <nut-button
            v-if="order.status === '待支付'"
            type="default"
            size="small"
            @click="urgeOrder(order.id)"
          >
            催单
          </nut-button>
          <nut-button
            v-if="order.status === '待支付'"
            type="default"
            size="small"
            @click="addDish(order.id)"
          >
            加菜
          </nut-button>
          <nut-button
            v-if="order.status === '待支付'"
            type="primary"
            size="small"
            @click="checkout(order.id)"
          >
            结账
          </nut-button>
          <nut-button
            v-if="order.status === '已结清'"
            type="default"
            size="small"
            @click="viewDetails(order.id)"
          >
            详情
          </nut-button>
          <nut-button
            v-if="order.status === '已结清'"
            type="danger"
            size="small"
            @click="deleteOrder(order.id)"
          >
            删除
          </nut-button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// 搜索框值
const searchValue = ref('')

// 订单数据
const orders = ref([
  {
    id: 1,
    tableNumber: 'A01',
    peopleCount: 6,
    orderTime: '13:20:10',
    amount: 376,
    diningTime: '00:40:05',
    status: '待支付'
  },
  {
    id: 2,
    tableNumber: 'A02',
    peopleCount: 6,
    orderTime: '12:15:30',
    amount: 376,
    diningTime: '00:30:20',
    status: '已结清'
  },
  {
    id: 3,
    tableNumber: 'A03',
    peopleCount: 6,
    orderTime: '12:15:30',
    amount: 376,
    diningTime: '00:30:20',
    status: '待支付'
  },
  {
    id: 4,
    tableNumber: '10',
    peopleCount: 6,
    orderTime: '12:15:30',
    amount: 376,
    diningTime: '00:30:20',
    status: '待支付'
  },
  {
    id: 5,
    tableNumber: '12',
    peopleCount: 6,
    orderTime: '12:15:30',
    amount: 376,
    diningTime: '00:30:20',
    status: '已结清'
  }
])

// 订单操作函数
const urgeOrder = (id: number) => {
  console.log('催单:', id)
  uni.showToast({ title: '催单成功', icon: 'success' })
}

const addDish = (id: number) => {
  console.log('加菜:', id)
  // 这里可以跳转到加菜页面
  // uni.navigateTo({ url: `/pages/addDish/index?id=${id}` })
}

const checkout = (id: number) => {
  console.log('结账:', id)
  // 这里可以跳转到结账页面
  // uni.navigateTo({ url: `/pages/checkout/index?id=${id}` })
}

const viewDetails = (id: number) => {
  console.log('查看详情:', id)
  // 这里可以跳转到详情页面
  // uni.navigateTo({ url: `/pages/orderDetails/index?id=${id}` })
}

const deleteOrder = (id: number) => {
  uni.showModal({
    title: '提示',
    content: '确定要删除此订单吗？',
    success: (res) => {
      if (res.confirm) {
        orders.value = orders.value.filter(order => order.id !== id)
        uni.showToast({ title: '删除成功', icon: 'success' })
      }
    }
  })
}
</script>

<style>
.order-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f5f5;
}

.header {
  background-color: #0080ff;
  padding: 20rpx;
  position: relative;
  height: 120rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-box {
  position: absolute;
  left: 30rpx;
  top: 50%;
  transform: translateY(-50%);
  width: 200rpx;
}

.title {
  color: #ffffff;
  font-size: 40rpx;
  font-weight: bold;
}

.order-list {
  flex: 1;
  padding: 20rpx;
  overflow-y: auto;
}

.order-item {
  background-color: #ffffff;
  border-radius: 15rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.table-number {
  font-size: 36rpx;
  font-weight: bold;
  color: #333333;
}

.status {
  padding: 8rpx 16rpx;
  border-radius: 20rpx;
  font-size: 28rpx;
}

.pending {
  background-color: #ff4d4f;
  color: #ffffff;
}

.completed {
  background-color: #52c41a;
  color: #ffffff;
}

.order-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20rpx 0;
  margin-bottom: 20rpx;
}

.info-item {
  display: flex;
  justify-content: space-between;
}

.label {
  font-size: 28rpx;
  color: #888888;
}

.value {
  font-size: 28rpx;
  color: #333333;
}

.order-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10rpx;
  flex-wrap: wrap;
}

/* 适配NutUI按钮 */
.nut-button {
  margin: 5rpx;
}
</style>
