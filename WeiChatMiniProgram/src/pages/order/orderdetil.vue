<template>
  <view class="order-page">
    <!-- <view class="order-header">
      <u-icon name="arrow-left" size="28" @click="goBack" custom-style="position:absolute;left:20rpx;top:40rpx" />
      <view class="order-title">订单结账</view>
      <view class="order-print">打印订单</view>
    </view> -->
    <view class="order-table">
      <view class="order-table-name">
        {{ tableName }}
        <template v-if="mergedTable"> <span class="order-table-merge">原{{ mergedTable }}并入{{ tableName }}</span></template>
        <template v-if="changeTable"> <span class="order-table-merge">原{{ changeTable }}换到{{ tableName }}</span></template>
      </view>
      <view class="order-table-actions">
      <u-button size="mini" custom-style="margin-right:20rpx;background:#f5f5f5;color:#333;border:1px solid #eee" @click="showMergeDialog = true">
        <image src="/src/static/payFrame(6).png" style="width:15px;height:15px;vertical-align:middle;margin-right:8px;" />
        并台
      </u-button>
      <u-button size="mini" custom-style="margin-right:20rpx;background:#f5f5f5;color:#333;border:1px solid #eee" @click="showChangeDialog = true">
        <image src="/src/static/payFrame(5).png" style="width:15px;height:15px;vertical-align:middle;margin-right:8px;" />
        换桌
      </u-button>
      </view>
    </view>
    <view class="order-list">
      <view v-for="item in orderList" :key="item.id" class="order-item">
        <view class="order-item-name">{{ item.name }} <span class="order-item-spec">{{ item.spec }}</span></view>
        <view class="order-item-price">￥{{ item.price }}</view>
        <!-- <view v-if="item.detail" class="order-item-detail" v-html="item.detail"></view> -->
      </view>
    </view>
    <view class="order-list">
      <view v-if="coupons.length>0" class="order-coupon" @click="handleCunpon">
        <view class="order-coupon-label">选择优惠券 <span style="color:#F04216">·</span></view>
        <view class="order-coupon-info">{{ selectcoupons }}</view>
      </view>
      <view class="order-total">
        <view class="order-total-label">总计</view>
        <view class="order-total-info"><span v-if="couponsMoney" style="color:#F04216">{{couponsMoney}}</span> ￥{{ total }}</view>
      </view>
    </view>
    <view class="order-pay">
      <view v-for="pay in payList" :key="pay.value" class="order-pay-item" @click="selectPay(pay.value)">
        <image :src="pay.icon" class="order-pay-icon" />
        <view class="order-pay-label">{{ pay.label }}</view>
        <view class="order-pay-check">
          <u-icon v-if="payType === pay.value" name="checkmark-circle-fill" size="28" custom-style="color:#F04216" />
          <u-icon v-else name="checkmark-circle" size="28" custom-style="color:#ccc" />
        </view>
      </view>
    </view>
    <view v-if="orderstatus=== '待支付'" class="order-btns">
      <u-button custom-style="width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc" @click="addDish">加菜</u-button>
      <u-button type="primary" custom-style="width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff" @click="checkout">结账</u-button>
    </view>
    <!-- 并台弹窗 -->
    <u-popup :show="showMergeDialog" mode="center" @close="showMergeDialog = false">
      <view class="merge-dialog">
        <view class="merge-title">并台</view>
        <view class="merge-grid">
          <view v-for="table in mergeTables" :key="table.id" class="merge-table" :class="{selected: mergeSelect === table.id}" @click="mergeSelect = table.id">[并入]<br/> {{ table.name }}</view>
        </view>
        <view class="merge-btns">
          <u-button custom-style="width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc" @click="showMergeDialog = false">取消</u-button>
          <u-button type="primary" custom-style="width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff" @click="confirmMerge">开台</u-button>
        </view>
      </view>
    </u-popup>
    <!-- 换桌弹窗（与并台类似，可复用） -->
    <u-popup :show="showChangeDialog" mode="center" @close="showChangeDialog = false">
      <view class="merge-dialog">
        <view class="merge-title">换桌</view>
        <view class="merge-grid">
          <view v-for="table in changeTables" :key="table.id" class="merge-table" :class="{selected: changeSelect === table.id}" @click="changeSelect = table.id">[换到] <br/> {{ table.name }}</view>
        </view>
        <view class="merge-btns">
          <u-button custom-style="width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc" @click="showChangeDialog = false">取消</u-button>
          <u-button type="primary" custom-style="width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff" @click="confirmChange">开台</u-button>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script setup lang="ts">
import { request } from '@/utitl/request'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { ref } from 'vue'
import dayjs from 'dayjs'
const tableName = ref('A2桌')
const oldtableId = ref(0)
const storeId = ref(0)
const mergedTable = ref('')
const changeTable = ref('')
const showMergeDialog = ref(false)
const showChangeDialog = ref(false)
const mergeTables = ref<any[]>([])
const changeTables = ref<any[]>([])
const mergeSelect = ref(0)
const changeSelect = ref(0)
const orderList = ref<any[]>([])
const orderId = ref("0")
const orderstatus = ref()
const total = ref(71)
const payType = ref('wechat')
const coupons = ref([])
const selectcoupons = ref('')
const couponsMoney = ref('')
const selectcouponsId = ref('')
const code = ref('')
const payList = ref([
  { value: 'wechat', label: '微信支付', icon: '/static/Vector.png' },
  // { value: 'balance', label: '余额支付', icon: '/static/payFrame(1).png' },
  // { value: 'alipay', label: '支付宝', icon: '/static/payFrame(2).png' },
  // { value: 'bank', label: '银行卡', icon: '/static/payFrame(3).png' },
  // { value: 'cash', label: '现金', icon: '/static/payFrame(4).png' }
])
function handleCunpon() {
  // 计算当前可用总价（已减去优惠）
  let couponDiscount = 0
  if (couponsMoney.value) {
    const match = couponsMoney.value.match(/\d+(\.\d+)?/)
    couponDiscount = match ? parseFloat(match[0]) : 0
  }
  const availableTotal = total.value + couponDiscount
  uni.navigateTo({
    url: '../order/Coupon?total=' + availableTotal
  })
}
function goBack() {
  uni.navigateBack()
}
function selectPay(val: string) {
  payType.value = val
}
function addDish() {
  uni.switchTab({
    url: '../menu/index'
  })
}
async function checkout() {
        uni.showLoading({ title: '结算中...' })
  uni.login({
    success: async (loginRes) => {
      console.log('登录成功:', loginRes);

      // 可以将 loginRes.code 发送到后台换取 openId 和 sessionKey
      code.value = loginRes.code
        await request({
          url: '/api/Client/OrderCheckout',
          method: 'GET',
          data: {
            orderId: orderId.value,
            type: payType.value,
            CouponsId: selectcouponsId.value || 0,
            Code: code.value,
          }
        }).then((res:any) => {
          uni.hideLoading()
          if (res.start === 200) {
            uni.showToast({ title: '结账成功', icon: 'success' })
            // 结账成功后，清除已选择的优惠券
            uni.removeStorageSync('selectedCoupon')
            // 返回订单列表页
            uni.navigateBack()
          } else {
            uni.showToast({ title: res.message || '结账失败', icon: 'none' })
          }
        }).catch(() => {
          uni.hideLoading()
          uni.showToast({ title: '结账失败', icon: 'none' })
        })
    },
    fail: (err) => {
      uni.hideLoading()
      console.error('登录失败:', err);
    }
  });

}
async function confirmMerge() {
  if (!mergeSelect.value) return
  await request({
    url: '/api/Client/MergeTables',
    method: 'GET',
    data: {
      orderId: orderId.value,
      oldTableId: oldtableId.value,
      newTableId: mergeSelect.value
    }
  }).then((res:any) => {
    if (res.start == 200) {
      mergedTable.value = tableName.value
      tableName.value =  mergeTables.value.find(item => item.id == mergeSelect.value)?.name || '';
      showMergeDialog.value = false
      mergeSelect.value = 0
      uni.showToast({ title: '并台成功', icon: 'success' })
    }
    else {
      uni.showToast({ title: '并台失败', icon: 'none' })
    }
  }).catch(() => {
    uni.showToast({ title: '并台失败', icon: 'none' })
  })
}
async function confirmChange() {
  if (!changeSelect.value) return
  await request({
    url: '/api/Client/ChangeTables',
    method: 'GET',
    data: {
      orderId: orderId.value,
      oldTableId: oldtableId.value,
      newTableId: changeSelect.value
    }
  }).then((res:any) => {
    if (res.start == 200) {
      changeTable.value = tableName.value
      tableName.value = changeTables.value.find(item => item.id == changeSelect.value)?.name || '';
      showChangeDialog.value = false
      changeSelect.value = 0
      uni.showToast({ title: '换桌成功', icon: 'success' })
    }
    else {
      uni.showToast({ title: '换桌失败', icon: 'none' })
    }
  }).catch(() => {
    uni.showToast({ title: '换桌失败', icon: 'none' })
  })
  GetTables(storeId.value)
}

onLoad(async (options: any) => {
    console.log('订单详情参数:', options)
    const { orderId: oid, orderstatus: ostatus } = options
    orderId.value = oid
    orderstatus.value = ostatus
    await GetOrderDetail(oid)
    await getStoredCoupon()

})
onShow(() => {
  console.log('onShow订单详情')
  var selectedCoupon = uni.getStorageSync('selectedCoupon')
  if(selectedCoupon && selectedCoupon.id){
    selectcoupons.value = selectedCoupon.title+'满   '+selectedCoupon.limit+'减'+selectedCoupon.value
    couponsMoney.value = '已优惠￥'+selectedCoupon.value+'元'
    // 重新计算总价，避免多次减去
    let orderTotal = 0
    if(orderList.value && orderList.value.length > 0){
      orderTotal = orderList.value.reduce((sum:any, item:any) => sum + Number(item.price), 0)
    }else{
      orderTotal = total.value
    }
    total.value = orderTotal - selectedCoupon.value
    selectcouponsId.value = selectedCoupon.id
  }
})

async function getStoredCoupon() {
   await request({
     url: '/api/Client/GetCouponList',
     method: 'GET',
     data:{
        storeId: uni.getStorageSync('TableInfo').storeId || 0,
     }
   }).then((res:any) => {
     if (res.start === 200 && res.response) {
       // 按某字段（如 value）降序排序，取第一个
       const sorted = res.response.filter((x:any)=> total.value >= x.min_consumption).sort((a:any, b:any) => b.value - a.value)
       coupons.value = res.response
       console.log('可用优惠券:', sorted)
       if(sorted.length > 0){
        selectcoupons.value = sorted.length > 0 ? sorted[0].coupon_name+'满   '+sorted[0].min_consumption+'减'+sorted[0].value : ''
        couponsMoney.value = '已优惠￥'+sorted[0].value+'元'
        total.value = total.value - sorted[0].value
        uni.setStorageSync('selectedCoupon', sorted[0])
        selectcouponsId.value = sorted[0].id
       }
     }
   }).catch(err => {
     console.error('Failed to fetch coupons:', err)
   })
}

async function GetOrderDetail(orderId: number) {
  await request({
    url: '/api/Client/OrderDetails',
    method: 'GET',
    data: {
      orderId: orderId
    }
  }).then((res: any) => {
    console.log('获取订单详情', res)
    if (res.response) {
      orderList.value = res.response.orderDetails || []
      oldtableId.value = res.response.tableId || 0
      total.value = res.response.total || 0
      tableName.value = res.response.tableName || 'A2桌'
      mergedTable.value = res.response.mergedTable || ''
      changeTable.value = res.response.changeTable || ''
      storeId.value = res.response.storeId || 0
       GetTables(storeId.value)
    }
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
    mergeTables.value = res.response.filter((item: any) => item.status === 2 && item.name !=tableName.value) || []
    changeTables.value = res.response.filter((item: any) => item.status === 1) || []
  })
}
</script>

<style>
.order-page {
  background: #f5f5f5;
  min-height: 100vh;
}
.order-header {
  background: linear-gradient(90deg,#0E8A9E,#1CB5E0);
  color: #fff;
  font-size: 36rpx;
  text-align: center;
  padding: 40rpx 0 20rpx 0;
  position: relative;
}
.order-title {
  font-size: 36rpx;
  font-weight: bold;
}
.order-print {
  position: absolute;
  right: 30rpx;
  top: 40rpx;
  font-size: 28rpx;
  color: #fff;
}
.order-table {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 30rpx 30rpx 0 30rpx;
}
.order-table-name {
  font-size: 32rpx;
  font-weight: bold;
  color: #222;
}
.order-table-merge {
  font-size: 24rpx;
  color: #888;
  margin-left: 10rpx;
}
.order-table-actions {
  display: flex;
  align-items: center;
}
.order-list {
  background: #fff;
  border-radius: 16rpx;
  margin: 20rpx 20rpx 0 20rpx;
  padding: 30rpx 20rpx 20rpx 20rpx;
  max-height: 300px;
  overflow-y: auto;
}
.order-item {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 18rpx;
}
.order-item-name {
  font-size: 30rpx;
  font-weight: bold;
  color: #222;
}
.order-item-spec {
  font-size: 24rpx;
  color: #888;
  margin-left: 10rpx;
}
.order-item-price {
  font-size: 28rpx;
  color: #222;
  font-weight: bold;
}
.order-item-detail {
  font-size: 22rpx;
  color: #888;
  margin-left: 10rpx;
  margin-top: 4rpx;
}
.order-coupon {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
  font-size: 26rpx;
}
.order-coupon-label {
  color: #333;
}
.order-coupon-info {
  color: #F04216;
}
.order-total {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 30rpx;
  font-size: 32rpx;
  font-weight: bold;
}
.order-total-label {
  color: #222;
}
.order-total-info {
  color: #222;
}
.order-pay {
  background: #fff;
  border-radius: 16rpx;
  margin: 20rpx 20rpx 0 20rpx;
  padding: 30rpx 20rpx 20rpx 20rpx;
}
.order-pay-item {
  display: flex;
  align-items: center;
  margin-bottom: 24rpx;
  cursor: pointer;
}
.order-pay-icon {
  width: 20px;
  height: 20px;
  margin-right: 20rpx;
}
.order-pay-label {
  font-size: 28rpx;
  color: #333;
  flex: 1;
}
.order-pay-check {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.order-btns {
  display: flex;
  justify-content: space-between;
  margin: 40rpx 20rpx 0 20rpx;
}
.merge-dialog {
  background: #fff;
  border-radius: 16rpx;
  padding: 40rpx 30rpx 30rpx 30rpx;
  width: 75vw;
  max-width: 500px;
  text-align: center;
}
.merge-title {
  font-size: 30rpx;
  font-weight: bold;
  color: #0E8A9E;
  margin-bottom: 20rpx;
  text-align: left;
}
.merge-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20rpx;
  margin-bottom: 30rpx;
}
.merge-table {
  background: #f5f5f5;
  border-radius: 10rpx;
  padding: 20rpx 0;
  font-size: 26rpx;
  color: #333;
  cursor: pointer;
  border: 2rpx solid #eee;
  transition: border-color 0.2s;
}
.merge-table.selected {
  border-color: #0E8A9E;
  background: #E6F7FA;
}
.merge-btns {
  display: flex;
  justify-content: space-between;
  margin-top: 20rpx;
}
</style>
