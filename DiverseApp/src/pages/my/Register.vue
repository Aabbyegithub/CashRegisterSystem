<template>
  <view class="register-page">
    <view class="register-header">
      <image src="/static/login-bg.png" class="register-bg" mode="widthFix" />
      <view class="register-title">餐厅收银系统</view>
    </view>
    <view class="register-form">
      <view class="register-title-row">
        <view class="register-form-title">用户注册</view>
        <view class="register-login-tip">
          已有账号？<text class="register-login-link" @click="goLogin">去登录</text>
        </view>
      </view>
      <view class="form-row">
        <view class="form-label">手机号</view>
        <u-input v-model="form.mobile" placeholder="请输入手机号" custom-style="background:#f6fbfc;border-radius:8px;" />
      </view>
      <view class="form-row">
        <view class="form-label">短信验证码</view>
        <u-input v-model="form.code" placeholder="请输入短信验证码" custom-style="background:#f6fbfc;border-radius:8px;" />
        <u-button type="default" size="mini" custom-style="margin-left:10px;" @click="sendCode">获取验证码</u-button>
      </view>
      <view class="form-row">
        <view class="form-label">设置密码</view>
        <u-input v-model="form.password" type="password" placeholder="请输入密码" custom-style="background:#f6fbfc;border-radius:8px;" />
      </view>
      <view class="form-row">
        <view class="form-label">确认密码</view>
        <u-input v-model="form.confirm" type="password" placeholder="请再次输入密码" custom-style="background:#f6fbfc;border-radius:8px;" />
      </view>
      <u-button type="primary" custom-style="width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;" @click="register">立即注册</u-button>
      <view class="register-protocol">
        登录及接受
        <text class="register-link">用户协议</text>
        及
        <text class="register-link">隐私政策</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const form = ref({
  mobile: '',
  code: '',
  password: '',
  confirm: ''
})
function sendCode() {
  // 发送验证码逻辑
}
function register() {
  // 注册逻辑
}
function goLogin() {
  uni.navigateTo({ url: '/pages/my/Login' })
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: #f6f7f9;
}
.register-header {
  position: relative;
  height: 180px;
}
.register-bg {
  width: 100%;
  height: 180px;
  object-fit: cover;
}
.register-title {
  position: absolute;
  left: 24px;
  bottom: 18px;
  font-size: 22px;
  color: #fff;
  font-weight: bold;
  letter-spacing: 2px;
}
.register-form {
  padding: 0 24px;
  background: #fff;
  border-radius: 24px 24px 16px 16px;
  margin-top: -24px;
}
.register-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}
.register-form-title {
  font-size: 20px;
  font-weight: bold;
  color: #222;
  border-bottom: 2px solid #0e8a9e;
  padding-bottom: 4px;
}
.register-login-tip {
  font-size: 14px;
  color: #888;
}
.register-login-link {
  color: #0e8a9e;
  margin-left: 4px;
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
.register-protocol {
  text-align: center;
  color: #888;
  font-size: 13px;
  margin: 24px 0 0 0;
}
.register-link {
  color: #0e8a9e;
  margin: 0 2px;
}
</style>