<template>
  <view class="login-page">
    <view class="login-header">
      <image src="/static/login-bg.png" class="login-bg" mode="widthFix" />
      <view class="login-title">餐厅收银系统</view>
    </view>
    <view class="login-tabs">
      <view :class="['login-tab', activeTab === 0 ? 'active' : '']" @click="activeTab = 0">账号登录</view>
      <view :class="['login-tab', activeTab === 1 ? 'active' : '']" @click="activeTab = 1">短信登录</view>
    </view>
    <view v-if="activeTab === 0" class="login-form">
      <view class="form-row">
        <view class="form-label">账号</view>
        <u-input v-model="form.account" placeholder="请输入账号" custom-style="background:#f6fbfc;border-radius:8px;" />
      </view>
      <view class="form-row">
        <view class="form-label">密码</view>
        <u-input v-model="form.password" type="password" placeholder="请输入密码" custom-style="background:#f6fbfc;border-radius:8px;" />
        <view class="form-forget" @click="goForget">忘记密码？</view>
      </view>
      <u-button type="primary" custom-style="width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;" @click="login">登录</u-button>
    </view>
    <view v-else class="login-form">
      <view class="form-row">
        <view class="form-label">手机号</view>
        <u-input v-model="form.mobile" placeholder="请输入手机号" custom-style="background:#f6fbfc;border-radius:8px;" />
      </view>
      <view class="form-row">
        <view class="form-label">验证码</view>
        <u-input v-model="form.code" placeholder="请输入验证码" custom-style="background:#f6fbfc;border-radius:8px;" />
        <u-button type="default" size="mini" custom-style="margin-left:10px;" @click="sendCode">获取验证码</u-button>
      </view>
      <u-button type="primary" custom-style="width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;" @click="loginSms">登录</u-button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const activeTab = ref(0)
const form = ref({
  account: '',
  password: '',
  mobile: '',
  code: ''
})
function login() {
  // 登录逻辑
}
function loginSms() {
  // 短信登录逻辑
}
function sendCode() {
  // 发送验证码逻辑
}
function goForget() {
  // 跳转忘记密码
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: #f6f7f9;
}
.login-header {
  position: relative;
  height: 180px;
}
.login-bg {
  width: 100%;
  height: 180px;
  object-fit: cover;
}
.login-title {
  position: absolute;
  left: 24px;
  bottom: 18px;
  font-size: 22px;
  color: #fff;
  font-weight: bold;
  letter-spacing: 2px;
}
.login-tabs {
  display: flex;
  margin: 0 0 24px 0;
  background: #fff;
  border-radius: 24px 24px 0 0;
  overflow: hidden;
}
.login-tab {
  flex: 1;
  text-align: center;
  padding: 18px 0 12px 0;
  font-size: 18px;
  color: #666;
  border-bottom: 2px solid transparent;
  background: #fff;
}
.login-tab.active {
  color: #0e8a9e;
  font-weight: bold;
  border-bottom: 2px solid #0e8a9e;
}
.login-form {
  padding: 0 24px;
  background: #fff;
  border-radius: 0 0 16px 16px;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
  position: relative;
}
.form-label {
  width: 70px;
  color: #333;
  font-size: 16px;
}
.form-forget {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  color: #999;
  font-size: 14px;
}
</style>
