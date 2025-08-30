<template>
  <view class="login-page">
    <view class="login-header">
      <image src="/static/mytop.png" class="login-bg" mode="widthFix" />
      <view class="login-title">餐厅收银系统</view>
      <view class="login-form login-form-float">
        <view class="form-row">
          <view class="form-label">账号</view>
          <u-input v-model="form.account" placeholder="请输入账号" custom-style="background:#eaf7f7;border-radius:8px;" />
        </view>
        <view class="form-row">
          <view class="form-label">密码</view>
          <u-input v-model="form.password" :type="showPwd ? 'text' : 'password'" placeholder="请输入密码" custom-style="background:#eaf7f7;border-radius:8px;padding-right:40px;" />
          <view class="pwd-toggle" @click.stop="showPwd = !showPwd">
            <text v-if="showPwd">👁️</text>
            <text v-else>🙈</text>
          </view>
        </view>
        <view class="form-forget" @click="goForget">忘记密码？</view>
        <u-button type="primary" custom-style="width:100%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;font-size:18px;" @click="login">登录</u-button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { request } from '@/utitl/request'
import { ref } from 'vue'
const form = ref({
  account: '',
  password: ''
})
const showPwd = ref(false)
async function login() {
  // 登录逻辑
  await request({
    url: '/api/User/Login',
    method: 'GET',
    data:{
      UserName: form.value.account,
      PassWord: form.value.password
    }
  }).then((res:any) => {
    if (res.start === 200) {
      uni.showToast({ title: '登录成功', icon: 'success' })
      // 保存登录状态
      uni.setStorageSync('token', res.response.token)
        uni.setStorageSync('UserInfo', JSON.stringify(res.response))
      // 跳转到首页或其他页面
      uni.switchTab({ url: '/pages/table/index' })
    } else {
      uni.showToast({ title: res.message || '登录失败', icon: 'none' })
    }
  }).catch(err => {
    uni.showToast({ title: '网络错误，请稍后重试', icon: 'none' })
  })
}
function goForget() {
  // 跳转忘记密码
  uni.navigateTo({ url: '/pages/my/ForgetPwd' })
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
  z-index: 999 ;
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
  position: absolute;
  left: 50%;
  top: 170px;
  transform: translateX(-50%);
  width: 90%;
  min-width: 320px;
  max-width: 400px;
  background: #fff;
  border-radius: 28px;
  box-shadow: 0 8px 32px rgba(14,138,158,0.16);
  padding: 36px 24px 28px 24px;
  z-index: 2;
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
.pwd-toggle {
  position: absolute;
  right: 38px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  color: #999;
  cursor: pointer;
  user-select: none;
  margin-right: -30px;
}
.form-forget {
  text-align: right;
  color: #999;
  font-size: 14px;
  margin-top: 12px;
  cursor: pointer;
}
.form-change {
  text-align: right;
  color: #999;
  font-size: 14px;
  margin-top: 12px;
  cursor: pointer;
}

</style>
