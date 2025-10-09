<template>
  <view class="coupon-page">
    <view class="coupon-list">
      <view v-for="coupon in coupons" :key="coupon.id" class="coupon-item" :class="{selected: selectedCoupon === coupon.id}">
      <view class="coupon-left" :class="{disabled: coupon.limit > total}">
        <view class="coupon-value-main">
          <text class="coupon-money"
            :style="coupon.limit > total ? 'color:#bbb;' : (selectedCoupon === coupon.id ? 'color:#F6A623;' : 'color:#F04216;')"
          >￥{{ coupon.value }}</text>
          <text class="coupon-type"
            :style="coupon.limit > total ? 'color:#bbb;' : (selectedCoupon === coupon.id ? 'color:#F6A623;' : 'color:#0E8A9E;')"
          >满{{ coupon.limit }}减{{ coupon.value }}</text>
        </view>
        <view class="coupon-name"
          :style="coupon.limit > total ? 'color:#bbb;' : (selectedCoupon === coupon.id ? 'color:#F6A623;' : '')"
        >{{ coupon.title }}</view>
        <view class="coupon-date"
          :style="coupon.limit > total ? 'color:#bbb;' : (selectedCoupon === coupon.id ? 'color:#888;' : '')"
        >{{ coupon.date }}</view>
      </view>
      <view class="coupon-right">
        <u-button
          type="primary"
          size="mini"
          custom-style="width:100rpx;height:48rpx;border-radius: 24rpx;background: #F6A623;color:#fff;font-size:24rpx;"
          @click="useCoupon(coupon)"
          :disabled="selectedCoupon === coupon.id || coupon.limit > total"
        >去使用</u-button>
      </view>
      </view>
    </view>
    <!-- <view class="coupon-footer">
      <u-button type="primary" custom-style="width:90%;border-radius: 50rpx;background:#0E8A9E;color:#fff;" @click="confirmCoupon">确定</u-button>
    </view> -->
  </view>
</template>

<script setup lang="ts">
import { request } from '@/utitl/request'
import { onShow,onLoad } from '@dcloudio/uni-app'
import { ref } from 'vue'
import dayjs from 'dayjs'
const coupons = ref([
  { id: 1, title: '消费券', limit: 100, value: 5, date: '2025.09.01-2025.09.30' },
  { id: 2, title: '会员专享', limit: 200, value: 15, date: '2025.09.01-2025.09.30' },
  { id: 3, title: '新客专享', limit: 50, value: 2, date: '2025.09.01-2025.09.30' }
])

const total = ref(0)
// 获取传递的参数
onLoad((options:any) => {
  if (options.total) {
    total.value = parseFloat(options.total)
    console.log('传递的总价参数:', total.value)
  }
})
onShow(async () => {
  await getStoredCoupon()
})

async function getStoredCoupon() {
   await request({
     url: '/api/Client/GetCouponList',
     method: 'GET',
     data:{
        storeId: uni.getStorageSync('TableInfo').storeId || JSON.parse(uni.getStorageSync('UserInfo').orgId) || 0,
     }
   }).then((res:any) => {
     if (res.start === 200 && res.response) {
       coupons.value = res.response.map((c: any) => ({
         id: c.coupon_id,
         title: c.coupon_name,
         limit: c.min_consumption,
         value: c.value,
         date: `${dayjs(c.valid_start).format('YYYY.MM.DD')} - ${dayjs(c.valid_end).format('YYYY.MM.DD')}`
       }))
     }
   }).catch(err => {
     console.error('Failed to fetch coupons:', err)
   })
}
const selectedCoupon = ref<number|null>(null)
function useCoupon(coupon: any) {
  selectedCoupon.value = coupon.id
  uni.setStorageSync('selectedCoupon', coupon)
  uni.navigateBack()
}
function confirmCoupon() {
  if (selectedCoupon.value) {
    const coupon = coupons.value.find(c => c.id === selectedCoupon.value)
    // 兼容微信小程序、APP、支付宝小程序
    // #ifdef MP-WEIXIN
    //@ts-ignore
    const eventChannel = uni.getOpenerEventChannel && uni.getOpenerEventChannel();
    if (eventChannel) {
      eventChannel.emit('selectCoupon', coupon)
    }
    // #endif
    // #ifdef APP-PLUS
    uni.$emit && uni.$emit('selectCoupon', coupon)
    // #endif
    // #ifdef MP-ALIPAY
    uni.setStorageSync('selectedCoupon', coupon)
    // #endif
    uni.navigateBack()
  } else {
    uni.showToast({ title: '请选择优惠券', icon: 'none' })
  }
}
</script>

<style>
.coupon-page {
  background: #f5f5f5;
  min-height: 100vh;
  padding: 0 20rpx;
}
.coupon-header {
  font-size: 36rpx;
  font-weight: bold;
  color: #0E8A9E;
  text-align: center;
  margin: 40rpx 0 30rpx 0;
}
 .coupon-list {
   display: flex;
   flex-direction: column;
   gap: 30rpx;
 }
 .coupon-item {
   display: flex;
   flex-direction: row;
   align-items: center;
   background: #fff;
   border-radius: 20rpx;
   box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
   padding: 0;
   border: 2rpx solid #eee;
   transition: border-color 0.2s;
   min-height: 160rpx;
 }
 .coupon-item.selected {
   border-color: #F6A623;
   background: #FFF6F2;
 }
 .coupon-left {
   flex: 1;
   padding: 30rpx 0 30rpx 30rpx;
   border-radius: 20rpx;
   display: flex;
   flex-direction: column;
   justify-content: center;
   background-color: #f8e9df;
   border-right: 2rpx dashed #858080;
 }
 .coupon-left.disabled {
   background-color: #f5f5f5;
   opacity: 0.7;
 }
 .coupon-value-main {
   display: flex;
   align-items: baseline;
   gap: 16rpx;
 }
 .coupon-money {
   font-size: 48rpx;
   font-weight: bold;
 }
 .coupon-type {
   font-size: 24rpx;
   margin-left: 10rpx;
 }
 .coupon-name {
   font-size: 32rpx;
   font-weight: bold;
   margin: 10rpx 0 0 0;
 }
 .coupon-date {
   font-size: 24rpx;
   margin-top: 8rpx;
 }
 .coupon-right {
   width: 120rpx;
   display: flex;
   padding: 26rpx 30rpx 26rpx 0;
   align-items: center;
   justify-content: center;
   /* padding-right: 30rpx; */
   min-height: 160rpx;
   border-radius:  20rpx;
   background-color: #f8e9df;
 }
 .coupon-footer {
   margin-top: 40rpx;
   text-align: center;
 }
.coupon-footer {
  margin-top: 40rpx;
  text-align: center;
}
</style>
