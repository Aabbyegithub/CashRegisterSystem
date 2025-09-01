<template>
  <view class="bankcard-page">
    <!-- <view class="bankcard-header">
      <u-icon name="arrow-left" size="28" @click="goBack" custom-style="position:absolute;left:20rpx;top:40rpx" />
      <view class="bankcard-title">银行卡设置</view>
    </view> -->
    <view class="bankcard-form">
      <view class="form-section">
        <view class="form-switch">
          <u-icon name="order" size="22" custom-style="margin-right:10rpx;color:#8fc1c7" />
          <text class="form-switch-label">收款人及账号信息</text>
        </view>
        <view class="form-row">
          <view class="form-label">真实姓名</view>
          <u-input v-model="form.name" custom-style="width:70%;background:#ffffff;border: 1px solid #666666;" />
        </view>
        <view class="form-row">
          <view class="form-label">身份证件</view>
          <u-input v-model="form.idcard" custom-style="width:70%;border: 1px solid #666666;" placeholder="请输入身份证号" />
        </view>
        <view class="form-row required">
          <view class="form-label">收款银行账号</view>
          <u-input v-model="form.banknum" custom-style="width:70%;border: 1px solid #666666;" placeholder="请输入银行账号" />
        </view>
        <view class="form-row required">
          <view class="form-label">银行类别</view>
          <u-input v-model="form.banktype" custom-style="width:70%;border: 1px solid #666666;" placeholder="请输入银行类别" />
        </view>
        <view class="form-row required">
          <view class="form-label">开户支行</view>
          <u-input v-model="form.branch" custom-style="width:70%;border: 1px solid #666666;" placeholder="请输入开户支行" />
        </view>
        <view class="form-row">
          <view class="form-label">邮箱</view>
          <u-input v-model="form.email" custom-style="width:70%;border: 1px solid #666666;" placeholder="请输入邮箱" />
        </view>
      </view>
      <view class="form-btns">
        <u-button custom-style="width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc" @click="goBack">取消</u-button>
        <u-button type="primary" custom-style="width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff" @click="submit">确定</u-button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const form = ref({
  name: '李美丽', 
  idcard: '610481199526354236',
  banknum: '621356895456620',
  banktype: '招商银行',
  branch: '长安南路支行',
  email: '6548924156@qq.com'
})
function goBack() {
  uni.navigateBack()
}
function submit() {
  uni.showToast({ title: '保存成功', icon: 'success' })
}
</script>

<style>
.bankcard-page {
  background: #f5f5f5;
  min-height: 100vh;
}
.bankcard-header {
  background: linear-gradient(90deg,#0E8A9E,#1CB5E0);
  color: #fff;
  font-size: 36rpx;
  text-align: center;
  padding: 40rpx 0 20rpx 0;
  position: relative;
}
.bankcard-title {
  font-size: 36rpx;
  font-weight: bold;
}
.bankcard-form {
  background: #fff;
  border-radius: 16rpx;
  margin: 30rpx 20rpx 0 20rpx;
  padding: 30rpx 20rpx 20rpx 20rpx;
}
.form-section {
  margin-bottom: 40rpx;
}
.form-switch {
  display: flex;
  align-items: center;
  margin-bottom: 20rpx;
}
.form-switch-label {
  font-size: 28rpx;
  color: #333;
  font-weight: bold;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 24rpx;
}
.form-label {
  width: 28%;
  font-size: 28rpx;
  color: #333;
  text-align: right;
  margin-right: 10rpx;
}
.form-row.required .form-label::before {
  content: '*';
  color: #F04216;
  margin-right: 4rpx;
}
.form-btns {
  display: flex;
  justify-content: space-between;
  margin-top: 40rpx;
}
</style>
