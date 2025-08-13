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
      </view>
      <view class="order-table-actions">
        <u-button size="mini" custom-style="margin-right:20rpx;background:#f5f5f5;color:#333;border:1px solid #eee" @click="showMergeDialog = true">并台</u-button>
        <u-button size="mini" custom-style="background:#f5f5f5;color:#333;border:1px solid #eee" @click="showChangeDialog = true">换桌</u-button>
      </view>
    </view>
    <view class="order-list">
      <view v-for="item in orderList" :key="item.id" class="order-item">
        <view class="order-item-name">{{ item.name }} <span class="order-item-spec">{{ item.spec }}</span></view>
        <view class="order-item-price">￥{{ item.price }}</view>
        <view v-if="item.detail" class="order-item-detail" v-html="item.detail"></view>
      </view>
      <view class="order-coupon">
        <view class="order-coupon-label">选择优惠券 <span style="color:#F04216">·</span></view>
        <view class="order-coupon-info">消费券 满100减5元</view>
      </view>
      <view class="order-total">
        <view class="order-total-label">总计</view>
        <view class="order-total-info"><span style="color:#F04216">已优惠￥5元</span> ￥{{ total }}</view>
      </view>
    </view>
    <view class="order-pay">
      <view v-for="pay in payList" :key="pay.value" class="order-pay-item" @click="selectPay(pay.value)">
        <image :src="pay.icon" class="order-pay-icon" />
        <view class="order-pay-label">{{ pay.label }}</view>
        <view class="order-pay-check">
          <u-icon v-if="payType === pay.value" name="checkbox-mark" size="28" custom-style="color:#F04216" />
          <u-icon v-else name="checkbox-blank" size="28" custom-style="color:#ccc" />
        </view>
      </view>
    </view>
    <view class="order-btns">
      <u-button custom-style="width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc" @click="addDish">加菜</u-button>
      <u-button type="primary" custom-style="width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff" @click="checkout">结账</u-button>
    </view>
    <!-- 并台弹窗 -->
    <u-popup :show="showMergeDialog" mode="center" @close="showMergeDialog = false">
      <view class="merge-dialog">
        <view class="merge-title">并台</view>
        <view class="merge-grid">
          <view v-for="table in mergeTables" :key="table" class="merge-table" :class="{selected: mergeSelect === table}" @click="mergeSelect = table">[并入] {{ table }}</view>
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
          <view v-for="table in changeTables" :key="table" class="merge-table" :class="{selected: changeSelect === table}" @click="changeSelect = table">[换到] {{ table }}</view>
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
import { ref } from 'vue'
const tableName = ref('A2桌')
const mergedTable = ref('')
const showMergeDialog = ref(false)
const showChangeDialog = ref(false)
const mergeTables = ref([
  'A05桌','A07桌','A08桌','A09桌','A10桌','A11桌','A12桌','A13桌','A14桌','A15桌','A16桌','A17桌','A18桌','A19桌','A08桌','A09桌','A05桌','A07桌','A08桌','A09桌'
])
const changeTables = ref([
  'A01桌','A02桌','A03桌','A04桌','A05桌','A06桌','A07桌','A08桌','A09桌','A10桌','A11桌','A12桌','A13桌','A14桌','A15桌','A16桌','A17桌','A18桌','A19桌'
])
const mergeSelect = ref('')
const changeSelect = ref('')
const orderList = ref([
  { id: 1, name: '麻婆豆腐', spec: '微辣*1', price: 18 },
  { id: 2, name: '小炒黄牛肉', spec: '中辣、不加葱*1', price: 48 },
  { id: 3, name: '清蒸鲈鱼', spec: '味淡*1', price: 16 },
  { id: 4, name: '小炒黄牛肉', spec: '中辣、不加葱*1', price: 12, detail: '-香辣蟹（微辣）*1<br>-蒜蓉油麦菜*1<br>-米饭*2' }
])
const total = ref(71)
const payType = ref('wechat')
const payList = ref([
  { value: 'wechat', label: '微信支付', icon: '/static/wechat.png' },
  { value: 'balance', label: '余额支付', icon: '/static/balance.png' },
  { value: 'alipay', label: '支付宝', icon: '/static/alipay.png' },
  { value: 'bank', label: '银行卡', icon: '/static/bank.png' },
  { value: 'cash', label: '现金', icon: '/static/cash.png' }
])
function goBack() {
  uni.navigateBack()
}
function selectPay(val: string) {
  payType.value = val
}
function addDish() {
  uni.showToast({ title: '加菜功能待开发', icon: 'none' })
}
function checkout() {
  uni.showToast({ title: '结账成功', icon: 'success' })
}
function confirmMerge() {
  if (!mergeSelect.value) return
  mergedTable.value = tableName.value
  tableName.value = mergeSelect.value
  showMergeDialog.value = false
  mergeSelect.value = ''
}
function confirmChange() {
  if (!changeSelect.value) return
  tableName.value = changeSelect.value
  mergedTable.value = ''
  showChangeDialog.value = false
  changeSelect.value = ''
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
  margin-top: 20rpx;
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
  width: 40px;
  height: 40px;
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
  width: 90vw;
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
