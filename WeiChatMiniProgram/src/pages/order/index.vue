<template>
  <view class="order-container">
    <CustomHeader
      :title="'订单管理'"
      :searchValue="searchValue"
      :searchPlaceholder="'桌号'"
      @update:searchValue="val => searchValue = val"
      @search="handleSearch"
    />
    <!-- 订单列表 -->
    <view class="order-list">
      <view v-for="order in orders" :key="order.id" class="order-item" @click="MenuDetails(order.id,order.status)">
        <view class="order-header">
          <text class="table-number">桌号{{ order.tableNumber }}</text>
          <view class="status">
            <image
              v-if="order.status === '待支付'"
              src="/src/static/列表图标.png"
              class="status-icon"
              mode="aspectFit"
            />
            <image
              v-else
              src="/src/static/列表图标(1).png"
              class="status-icon"
              mode="aspectFit"
            />
          </view>
        </view>

        <view class="order-info">
          <view class="info-item">
            <text class="label">就餐人数</text>
            <text class="value">{{ order.peopleCount }}人</text>
          </view>
          <view class="info-item">
            <text class="label">下单时间</text>
            <text class="value" style="font-size: 10px;">{{ order.orderTime }}</text>
          </view>
          <view class="info-item">
            <text class="label">消费金额</text>
            <text class="value">{{ order.amount }}元</text>
          </view>
          <view class="info-item">
            <text class="label">用餐时间</text>
            <text class="value" style="font-size: 10px;">{{ order.diningTime }}</text>
          </view>
        </view>

        <view class="order-actions">
          <view @click.stop>
          <u-button
            v-if="order.status === '待支付'"
            size="mini"
            native-type="button"
            @click.stop.prevent="urgeOrder(order.id)"
            custom-style="margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
          >催单</u-button></view>
          <view @click.stop>
          <u-button
            v-if="order.status === '待支付'"
            type="default"
            size="mini"
            native-type="button"
            @click.stop.prevent="addDish(order.id)"
            custom-style="margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
          >加菜</u-button></view>
          <view @click.stop>
          <u-button
            v-if="order.status === '待支付'"
            type="default"
            size="mini"
            native-type="button"
            @click.stop.prevent="checkout(order.id,order.status)"
            custom-style="margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
          >结账</u-button></view>
          <view @click.stop>
          <u-button
            v-if="order.status === '已结清'"
            type="default"
            size="mini"
            native-type="button"
            @click.stop.prevent="viewDetails(order.id,order.status)"
            custom-style="margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
          >详情</u-button></view>
          <!-- <u-button
            v-if="order.status === '已结清'"
            type="default"
            size="mini"
            @click="deleteOrder(order.id)"
            custom-style="margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
          >删除</u-button> -->
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import CustomHeader from '@/components/CustomHeader.vue'
import { request } from '@/utitl/request'
import dayjs from 'dayjs';
import { onShow } from '@dcloudio/uni-app';

// 搜索框值
const searchValue = ref('')
const sourceType =ref(2) // 默认客人
var UserInfo = uni.getStorageSync('UserInfo')
if (!UserInfo) {
   sourceType.value = 1
}
 const { tableId, storeId,people } = uni.getStorageSync('TableInfo') || {}

// 订单数据
const orders = ref<any[]>([])

// 订单操作函数
const urgeOrder = async (id: number) => {
  console.log('催单:', id)
  await request({
    url: `/api/Client/OrderReminder?orderId=${id}`,
    method: 'GET'
  }).then(() => {
    uni.showToast({ title: '催单成功', icon: 'success' })
  }).catch(() => {
    uni.showToast({ title: '催单失败', icon: 'none' })
  })
}

const addDish = (id: number) => {
  console.log('加菜:', id)
   uni.setStorageSync('OrderId', id)
  // 这里可以跳转到加菜页面
  uni.switchTab({
    url: `../menu/index`
  })
}

const checkout = (id: number,orderstatus:string) => {
  console.log('结账:', id)
  // 这里可以跳转到结账页面
   uni.navigateTo({ url: `/pages/order/orderdetil?orderId=${id}&orderstatus=${orderstatus}` })
}

const viewDetails = (id: number,orderstatus:string) => {
  console.log('查看详情:', id)
  // 这里可以跳转到详情页面
   uni.navigateTo({ url: `/pages/order/orderdetil?orderId=${id}&orderstatus=${orderstatus}` })
}

const MenuDetails = (id: number,orderstatus:string) => {
  console.log('查看详情:', id)
  // 这里可以跳转到详情页面
   uni.navigateTo({ url: `/pages/order/orderdetil?orderId=${id}&orderstatus=${orderstatus}` })
}

const handleSearch = (value: string) => {
  console.log('搜索:', value)
  // 这里可以添加搜索逻辑
  // 比如过滤订单列表
  orders.value = orders.value.filter(order => order.tableNumber.includes(value))
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

onShow(() => {
  //加载订单数据 --员工可以获取所有，客人只能获取自己所对应的桌台
  getOrders()
})

const getOrders = async () => {
  await request({
    url: `/api/Client/GetTableOrder?store_id=${storeId || 2}&table_id=${tableId || 1}&sourceType=${sourceType.value}`,
    method: 'GET'
  }).then((res: any) => {
    console.log('获取订单数据', res)
    if (res.start === 200) {
      orders.value = res.response.map((order: any) => ({
        ...order,
        id: order.order_id,
        tableNumber: order.table.table_no,
        orderTime:dayjs(order.start_time).format('YYYY-MM-DD HH:mm:ss') ,
        diningTime:dayjs(order.start_time).format('YYYY-MM-DD HH:mm:ss'),
        status: order.status === 1 || order.status == 2? '待支付' : '已结清',
        peopleCount: order.table_capacity,
        amount: order.payable_amount
      }))
    } else {
      uni.showToast({ title: res.message, icon: 'none' })
    }
  }).catch((error) => {
    console.error('获取订单数据失败', error)
    uni.showToast({ title: '获取订单数据失败', icon: 'none' })
  })
}

</script>

<style>
.order-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #ffffff;
}

/* .header {
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
} */

.order-list {
  flex: 1;
  padding: 20rpx;
  overflow-y: auto;
  height: calc(100vh - 120rpx); /* 减去头部高度 */
}

.order-item {
  background-color: #FBFBFB;
  border-radius: 15rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
  border: 1px solid #e5e5e5;
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
  align-items: center;
  justify-content: flex-start;
}

.label {
  font-size: 28rpx;
  color: #888888;
  margin-right: 10px;
}

.value {
  font-size: 28rpx;
  color: #333333;
}

.order-actions {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: flex-end;
  gap: 10rpx;
}

/* 适配NutUI按钮 */
::v-deep wx-button::after {
  border: none !important; 
  /* 把原有的边框、阴影等样式都清掉，按需调整 */
  box-shadow: none !important; 
  content: none; /* 若不需要伪元素内容，直接去掉 */
}
.u-button--mini{
  min-width: 20px !important;
  padding: 0 !important
}
.status-icon{
  width: 80px;
  height: 35px;
  margin-right: -25px;
}
</style>
