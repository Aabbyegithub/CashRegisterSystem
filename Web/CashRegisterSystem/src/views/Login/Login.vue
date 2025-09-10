<template>
  <div class="login-container">
    <!-- 顶部标题 -->
    <div class="header">
      <img 
        src="../../assets/Title.png"  
        alt="系统图标" 
        class="header-icon"
      >
    </div>

    <!-- 登录表单区域，通过 margin-left: auto 实现靠右 -->
    <el-card class="login-card">
      <div class="tab-header">
        <div 
          :class="['tab-item', { active: loginTab === 'account' }]" 
          @click="loginTab = 'account'"
        >
          账号登录
        </div>
        <!-- <div 
          :class="['tab-item', { active: loginTab === 'sms' }]" 
          @click="loginTab = 'sms'"
        >
          短信登录
        </div> -->
      </div>

      <el-form 
        :model="form" 
        :rules="rules" 
        ref="formRef" 
        label-position="left"
        label-width="65px"
      >
        <!-- 账号登录表单 -->
        <template v-if="loginTab === 'account'">
          <!-- <el-form-item label="门店" prop="storeId">
            <el-select v-model="form.storeId" placeholder="请选择门店">
              <el-option
                v-for="store in storeList"
                :key="store.store_id"
                :label="store.store_name"
                :value="store.store_id"
              />
            </el-select>
          </el-form-item> -->
          <el-form-item label="账号" prop="username">
            <el-input 
              v-model="form.username" 
              placeholder="请输入账号" 
              :prefix-icon="User"
            />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input 
              v-model="form.password" 
              type="password" 
              placeholder="请输入密码" 
              :prefix-icon="Lock"
              :show-password="true"
              @keyup.enter="submit"
            />
          </el-form-item>
          <el-form-item>
            <el-checkbox v-model="form.remember">记住密码</el-checkbox>
          </el-form-item>
        </template>

        <!-- 短信登录表单 -->
        <!-- <template v-else>
          <el-form-item label="门店" prop="storeId">
            <el-select v-model="form.storeId" placeholder="请选择门店">
              <el-option
                v-for="store in storeList"
                :key="store.store_id"
                :label="store.store_name"
                :value="store.store_id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="手机号" prop="phone">
            <el-input 
              v-model="form.phone" 
              placeholder="请输入手机号" 
              prefix-icon="el-icon-phone"
            />
          </el-form-item>
          <el-form-item label="验证码" prop="smsCode" >
            <el-input 
              v-model="form.smsCode" 
              placeholder="请输入验证码" 
              style="width:100%"
              prefix-icon="el-icon-message"
               @keyup.enter="submit"
            >
              <template #append>
                <el-button 
                  type="primary" 
                  size="" 
                  @click="sendSms"
                >
                  {{ smsButtonText }}
                </el-button>
              </template>
            </el-input>
          </el-form-item>
        </template> -->

        <el-form-item>
          <el-button 
            type="primary" 
            @click="submit" 
            :loading="loading" 
            style="width: 100% ;background-color:#1D99AD;"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElForm, ElFormItem, ElInput, ElButton, ElCheckbox } from 'element-plus'
import { useRouter } from 'vue-router'
// 假设 api 模块，需根据实际调整
import { getStoreList, loginApi } from '../../api/login' 
import { User,Lock } from '@element-plus/icons-vue'
const router = useRouter()
const formRef = ref<InstanceType<typeof ElForm>>()
const loading = ref(false)
// 登录 tab：account-账号登录 / sms-短信登录
const loginTab = ref<'account' | 'sms'>('account') 

const form = reactive({
  // storeId: '',
  username: '',
  password: '',
  phone: '',
  smsCode: '',
  remember: false
})

const rules = {
  // storeId: [
  //   { required: true, message: '请选择门店', trigger: 'blur' }
  // ],
  username: [
    { required: true, message: '请输入账号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  smsCode: [
    { required: true, message: '请输入验证码', trigger: 'blur' }
  ]
}

// 短信倒计时相关
const smsCountdown = ref(0)
const smsButtonText = ref('获取验证码')
const sendSms = () => {
  if (!form.phone) {
    ElMessage.warning('请先输入手机号')
    return
  }
  if (smsCountdown.value > 0) return

  // 调用短信接口逻辑，示例：
  smsCountdown.value = 60
  smsButtonText.value = `${smsCountdown.value}s后重发`
  const timer = setInterval(() => {
    smsCountdown.value--
    smsButtonText.value = `${smsCountdown.value}s后重发`
    if (smsCountdown.value <= 0) {
      clearInterval(timer)
      smsButtonText.value = '获取验证码'
    }
  }, 1000)

  // 实际需调用短信发送接口：
  // await sendSmsApi(form.phone)
}

const storeList = ref<any[]>([]);

async function fetchStoreList() {
  await getStoreList().then((res:any)=> {
    if (res && res.response) {
      storeList.value = res.response.map((item: any) => ({
        store_id: item.store_id,
        store_name: item.store_name
      }))
    } else {
      ElMessage.error('获取门店列表失败')
    }
  }).catch(err => {
    console.error('获取门店列表失败:', err)
    ElMessage.error('获取门店列表失败')
  });
}

onMounted(() => {
  //fetchStoreList();
});

const submit = async () => {
  try {
    await formRef.value?.validate()
    loading.value = true
    
    let res: any
    if (loginTab.value === 'account') {
      // 账号密码登录逻辑
      res = await loginApi(form.username, form.password)
      // if (!res || !res.response || !res.response.token) {
      //   throw new Error('登录失败，请检查账号或密码')
      // }
    } else {
      // 短信登录逻辑，需调整 api 调用
      // res = await smsLoginApi(form.phone, form.smsCode)
    }
    console.log(res);
    localStorage.setItem('token', res.response.token)
    localStorage.setItem('UserInfo', JSON.stringify(res.response))
    ElMessage.success('登录成功')
    router.push('/Layout') // 登录成功后跳转到订单管理页面
  } catch (err: any) {
    ElMessage.error(err.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 登录页面容器，通过 flex 布局控制表单位置 */
.login-container {
  position: relative; /* 用于给 header 绝对定位做基准 */
  width: 100%;
  height: 100vh;
  /* 设置背景图 */
  background: url("../../assets/login.png") no-repeat center center;
  background-size: cover; /* 背景图覆盖整个容器 */
  display: flex;
  /* 让表单靠右：左边自动填充空白 */
  justify-content: flex-end; 
  align-items: center;
  padding-right: 5%; /* 可选：给右侧留出一些空间，避免贴边 */
}

/* 顶部标题 */
.header {
  position: absolute; 
  top: 20px;
  left: 20px;
  display: flex;
  align-items: center;
}

.header-icon {
  width: 300px;
  height: 40px;
  margin-left: 20px;
}

/* 登录卡片 */
.login-card {
  width: 400px;
  padding: 30px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  margin-right: 150px;
}

/* 标签切换样式 */
.tab-header {
  display: flex;
  margin-bottom: 20px;
  border-bottom: 1px solid #e6e6e6;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 10px 0;
  cursor: pointer;
  color: #999;
  transition: all 0.3s;
}

.tab-item.active {
  color: #409eff;
  border-bottom: 2px solid #409eff;
}

/* 适配响应式，小屏幕下让表单居中 */
@media (max-width: 992px) {
  .login-container {
    justify-content: center; /* 小屏幕居中 */
    padding-right: 0;
  }

  .login-card {
    width: 100%;
    max-width: 400px;
  }
}
</style>