<template>
  <view class="menu-container">
    <CustomHeader
      :title="'A2桌点餐'"
      :searchValue="searchValue"
      :searchPlaceholder="'搜索'"
      @update:searchValue="val => searchValue = val"
      @search="handleSearch"
    />
    <view class="main-content" :style="'height: calc(100vh - 93px' + (cartList.length > 0 ? ' - 60px' : '') + ');'">
      <view class="sidebar">
        <view
          v-for="item in categories"
          :key="item.id"
          :class="['sidebar-item', item.active ? 'active' : '']"
          @click="selectCategory(item.id)"
        >
          {{ item.name }}
        </view>
      </view>
      <view class="dish-list">
        <view v-for="dish in dishes" :key="dish.id" class="dish-item">
         <u-image
            :src="dish.img"
            width="80px"
            height="80px"
            radius="10rpx"
            lazy-load
          >
            <template #loading>
              <image src=""/>
            </template>
            <template #error>
              <image src="https://jebben.cn/posts/%E7%BD%91%E9%A1%B5%E5%9B%BE%E7%89%87%E5%8A%A0%E8%BD%BD%E5%A4%B1%E8%B4%A5%E6%95%99%E4%BD%A05%E7%A7%8D%E6%96%B9%E6%B3%95%E5%AE%8C%E7%BE%8E%E5%BA%94%E5%AF%B9/cover.png" style="width:80px;height:80px;" />
            </template>
          </u-image>
          <view class="dish-info">
            <view class="dish-title">{{ dish.name }}</view>
            <view class="dish-desc">{{ dish.desc }}</view>
            <view class="dish-price">￥{{ dish.price }}</view>
          </view>
          <!-- spece==0 直接加购逻辑 -->
            <template v-if="dish.spece == 0">
              <template v-if="getCartQty(dish.id) > 0">
                <u-icon
                  size="24"
                  name="minus-circle"
                  custom-style="width:50px;float:right;color:#0E8A9E;margin-right:-40px;margin-bottom:-60px"
                  @click="changeCartQtySimple(dish, -1)"
                ></u-icon>
                <view
                  style="width:50px;float:right;margin-right:-20px;margin-bottom:-60px;padding: 5px;text-align:center;"
                >{{ getCartQty(dish.id) }}</view>
                <u-icon
                  size="24"
                  name="plus-circle-fill"
                  custom-style="width:50px;float:right;color:#0E8A9E;margin-right:-30px;margin-bottom:-60px"
                  @click="changeCartQtySimple(dish, 1)"
                ></u-icon>
              </template>
              <template v-else>
                <u-icon
                  size="24"
                  name="plus-circle-fill"
                  custom-style="width:50px;float:right;color:#0E8A9E;margin-right:-30px;margin-bottom:-60px"
                  @click="changeCartQtySimple(dish, 1)"
                ></u-icon>
              </template>
            </template>
          <u-button v-if="dish.spece == 1" size="mini" custom-style="width:50px;float:right;color:#ffffff;background:#0E8A9E;border-radius: 20rpx;margin-bottom:-60px" @click="openSpecDialog(dish)">选规格</u-button>
        </view>
      </view>
    <!-- 规格弹窗 -->
    <u-popup :show="showSpecDialog" mode="bottom" @close="showSpecDialog = false">
      <view class="spec-dialog">
        <view class="spec-header">
          <image :src="selectedDish?.img" class="spec-img" />
          <view class="spec-info">
            <view class="spec-title">{{ selectedDish?.name }}</view>
            <view class="spec-desc">已选：{{ selectedSpec }} / {{ selectedSpicy }}</view>
            <view class="spec-price">￥{{ selectedDish?.price }}</view>
          </view>
        </view>
        <view class="spec-section">
          <view class="spec-label">份量</view>
          <view class="spec-options">
            <view v-for="spec in specList" :key="spec" :class="['spec-option', selectedSpec === spec ? 'active' : '']" @click="selectedSpec = spec">{{ spec }}</view>
          </view>
        </view>
        <view class="spec-section">
          <view class="spec-label">辣度</view>
          <view class="spec-options">
            <view v-for="spicy in spicyList" :key="spicy" :class="['spec-option', selectedSpicy === spicy ? 'active' : '']" @click="selectedSpicy = spicy">{{ spicy }}</view>
          </view>
        </view>
        <view class="spec-section" style="display: flex;">
          <view class="spec-label">数量</view>
          <view class="spec-qty">
            <u-icon name="minus" size="20" @click="changeQty(-1)" custom-style="margin-right:10px" />
            <view class="spec-qty-num">{{ qty }}</view>
            <u-icon name="plus" size="20" @click="changeQty(1)" custom-style="margin-left:10px" />
          </view>
        </view>
        <u-button custom-style="width:90%;margin:30px auto 0;border-radius: 50rpx;background:#0E8A9E;color:#ffffff;" @click="addToCart">加入购物车</u-button>
      </view>
    </u-popup>
    <!-- 购物车弹窗 -->
    <u-popup :show="showCartDialog" mode="bottom" @close="showCartDialog = false">
      <view class="cart-dialog">
        <view class="cart-header">
          <image class="cart-icon" src="/src/static/Group.png" />
          <view v-if="cartList.length > 0" class="cart-badge" style="left:35px;top:20px">{{ cartList.length }}</view>
          <view class="cart-title">购物车</view>
        </view>
        <view v-if="cartList.length === 0" class="cart-empty">购物车为空</view>
        <view v-else class="cart-list">
          <view v-for="item in cartList" :key="item.id + item.spec + item.spicy" class="cart-item">
            <image :src="item.img" class="cart-item-img" />
            <view class="cart-item-info">
              <view class="cart-item-name">{{ item.name }}</view>
              <view class="cart-item-spec">{{ item.spec }} / {{ item.spicy }}</view>
              <view class="cart-item-price">￥{{ item.price }}</view>
            </view>
            <view class="cart-item-qty">
              <u-icon name="minus" size="20" @click="changeCartQty(item, -1)" custom-style="margin-right:10px" />
              <view class="cart-item-qty-num">{{ item.qty }}</view>
              <u-icon name="plus" size="20" @click="changeCartQty(item, 1)" custom-style="margin-left:10px" />
            </view>
          </view>
        </view>
        <view class="cart-footer">
          <view class="cart-total">
            <view class="cart-total-label">合计：</view>
            <view class="cart-total-price">￥{{ cartTotal }}</view>
          </view>
          <u-button class="cart-btn" type="primary" custom-style="border-radius: 50rpx;background:#0E8A9E;color:#fff;width:120px;height:40px;font-size:28rpx;margin-right:40rpx" @click="submitOrder">下单</u-button>
        </view>
      </view>
    </u-popup>
    <!-- 底部购物车栏，直接展示在 main-content 下方 -->
    </view>
    <view class="cart-bar" v-if="cartList.length > 0" @click.self="showCartDialog = true">
      <view class="cart-left">
        <view class="cart-icon-box">
          <image class="cart-icon" src="/src/static/Group.png" />
          <view v-if="cartList.length > 0" class="cart-badge">{{ cartList.length }}</view>
        </view>
        <view class="cart-price-box">
          <view class="cart-price">￥{{ cartTotal }}</view>
        </view>
      </view>
      <view @click.stop style="display:inline-block">
        <u-button class="cart-btn" type="primary" custom-style="border-radius: 50rpx;background:#0E8A9E;color:#fff;width:120px;height:40px;font-size:28rpx;margin-right:40rpx"  @click="submitOrder">下单</u-button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
// 规格弹窗相关
const showSpecDialog = ref(false)
const selectedDish = ref<any>(null)
const specList = ['约1000克']
const spicyList = ['不辣', '正常', '中辣', '重辣']
const selectedSpec = ref(specList[0])
const selectedSpicy = ref(spicyList[0])
const qty = ref(1)
const TableId = ref(0)

function openSpecDialog(dish: any) {
  selectedDish.value = dish
  showSpecDialog.value = true
  selectedSpec.value = specList[0]
  selectedSpicy.value = spicyList[0]
  qty.value = 1
}
function changeQty(val: number) {
  if (qty.value + val >= 1) qty.value += val
}
import CustomHeader from '@/components/CustomHeader.vue'
import { request } from '@/utitl/request'

const searchValue = ref('')
const categories = ref([
  { id: 1, name: '招牌推荐', active: true },
  { id: 2, name: '一人套餐', active: false },
  { id: 3, name: '家常小炒', active: false },
  { id: 4, name: '爽口凉菜', active: false },
  { id: 5, name: '主食', active: false },
  { id: 6, name: '汤', active: false },
  { id: 7, name: '酒水饮料', active: false }
])
const dishes = ref([
  { id: 1, name: '糖醋里脊', desc: '招牌特色菜', price: 28,spece:0,dishCategoryType:1, img: 'https://vcg02.cfp.cn/creative/vcg/nowater800/new/VCG211430891214.jpg?x-oss-process=image/format,webp' },
  { id: 2, name: '麻婆豆腐', desc: '100+热销家常菜', price: 18,spece:0,dishCategoryType:1,  img: 'https://vcg02.cfp.cn/creative/vcg/nowater800/new/VCG211430891214.jpg?x-oss-process=image/format,webp' },
  { id: 3, name: '小炒黄牛肉', desc: '99%好评 老价位回归', price: 58,spece:1,dishCategoryType:1,  img: 'https://vcg02.cfp.cn/creative/vcg/nowater800/new/VCG211430891214.jpg?x-oss-process=image/format,webp' },
  { id: 4, name: '孜然肉片', desc: '香辣孜然，嫩滑', price: 28,spece:0 ,dishCategoryType:1,img: 'https://vcg02.cfp.cn/creative/vcg/nowater800/new/VCG211430891214.jpg?x-oss-process=image/format,webp' },
  { id: 5, name: '手撕包菜', desc: '99%好评 老价位回归', price: 18,spece:1,dishCategoryType:1,  img: 'https://vcg02.cfp.cn/creative/vcg/nowater800/new/VCG211430891214.jpg?x-oss-process=image/format,webp' }
])

function selectCategory(id: number) {
  categories.value.forEach(item => item.active = item.id === id)
  // 切换分类时定位到当前选中分类的第一个菜品
  setTimeout(() => {
    const dishIndex = dishes.value.findIndex(d => d.dishCategoryType === id)
    if (dishIndex > -1) {
      const selector = `.dish-item:nth-child(${dishIndex + 1})`
      uni.createSelectorQuery()
        .select(selector)
        .boundingClientRect((rect: any) => {
          if (rect && typeof rect.top === 'number') {
            uni.pageScrollTo({
              scrollTop: rect.top - 80, // 80为header高度，可根据实际调整
              duration: 300
            })
          }
        })
        .exec()
    }
  }, 50)
}
function handleSearch(val:any) {
  // TODO: 搜索逻辑
}

// 获取购物车中某菜品数量（spece==0专用）
function getCartQty(id: number) {
  const item = cartList.value.find(i => i.id === id && (!i.spec && !i.spicy))
  return item ? item.qty : 0
}
// spece==0菜品加减购物车
function changeCartQtySimple(dish: any, val: number) {
  const idx = cartList.value.findIndex(i => i.id === dish.id && (!i.spec && !i.spicy))
  if (idx > -1) {
    cartList.value[idx].qty += val
    if (cartList.value[idx].qty <= 0) cartList.value.splice(idx, 1)
  } else if (val > 0) {
    cartList.value.push({
      id: dish.id,
      name: dish.name,
      img: dish.img,
      price: dish.price,
      qty: 1
    })
  }
  calcCartTotal()
}
// 购物车相关
const showCartDialog = ref(false)
const cartList = ref<any[]>([])
const cartTotal = ref(0)
function addToCart() {
  // 规格弹窗添加到购物车
  const dish = selectedDish.value
  if (!dish) return
  // 查找是否已存在相同规格
  const idx = cartList.value.findIndex(item => item.id === dish.id && item.spec === selectedSpec.value && item.spicy === selectedSpicy.value)
  if (idx > -1) {
    cartList.value[idx].qty += qty.value
  } else {
    cartList.value.push({
      id: dish.id,
      name: dish.name,
      img: dish.img,
      price: dish.price,
      spec: selectedSpec.value,
      spicy: selectedSpicy.value,
      qty: qty.value
    })
  }
  calcCartTotal()
  showSpecDialog.value = false
  uni.showToast({ title: '已加入购物车', icon: 'success' })
}
function changeCartQty(item: any, val: number) {
  item.qty += val
  if (item.qty <= 0) {
    cartList.value = cartList.value.filter(i => i !== item)
  }
  calcCartTotal()
}
function calcCartTotal() {
  cartTotal.value = cartList.value.reduce((sum, item) => sum + item.price * item.qty, 0)
}
async function submitOrder() {
  if (cartList.value.length === 0) {
    uni.showToast({ title: '购物车为空', icon: 'none' })
    return
  }
  var sourceType = 2
  var UserInfo = uni.getStorageSync('UserInfo')
  if (!UserInfo) {
     sourceType = 1
  }
  const { tableId, storeId,people } = uni.getStorageSync('TableInfo') || {}
  const orderId = uni.getStorageSync('OrderId')
  // 提交订单逻辑
  await request({
    url: `/api/Client/SaveOrder?store_id=${storeId}&table_id=${tableId}&sourceType=${sourceType}&people=${people}&orderId=${orderId}`,
    method: 'POST',
    data:  cartList.value.map(item => ({
    ...item,
    price: String(item.price),
    spec: String(item.spec || ''),
    spicy: String(item.spicy || ''),
    qty: Number(item.qty)
  }))
  }).then((res: any) => {
    if (res.start == 200) {
      uni.showToast({ title: '下单成功', icon: 'success' })
      cartList.value = []
      cartTotal.value = 0
      showCartDialog.value = false
    } else {
      uni.showToast({ title: res.message || '下单失败', icon: 'none' })
    }
  }).catch(() => {
    uni.showToast({ title: '网络错误，请稍后再试', icon: 'none' })
  })
}

onLoad(() => {
  const { tableId, storeId,people } = uni.getStorageSync('TableInfo') || {}
  if (tableId) {
    // 获取桌台ID
    TableId.value = tableId
  }else {
    uni.showToast({ title: '未指定桌台', icon: 'none' })
  }
  getmenuType(storeId) 
  getmenuList(storeId)
})

async function getmenuType(storeId: number) {
   await request({
    url: '/api/Client/GetDishType',
    method: 'GET',
    data: {
      store_id: storeId
    }}).then((res: any) => {
      categories.value = res.response || []
    })
}

async function getmenuList(storeId: number) {
  await request({
    url: '/api/Client/GetDish',
    method: 'GET',
    data: {
      store_id: storeId
    }}).then((res: any) => {
      dishes.value = res.response || []
    })
}
</script>

<style>
.menu-container {
  background: #f5f5f5;
  height: 100vh
}
/* 规格弹窗样式 */
.spec-dialog {
  background: #fff;
  border-radius: 20rpx 20rpx 0 0 !important;
  padding: 30rpx;
  width: 90vw;
  max-width: 500px;
}
::v-deep .u-popup__content {
  border-radius: 20rpx 20rpx 0 0 !important;
  overflow: visible !important;
}
.spec-header {
  display: flex;
  align-items: center;
  margin-bottom: 20rpx;
}
.spec-img {
  width: 100px;
  height: 100px;
  border-radius: 10rpx;
  margin-right: 20rpx;
}
.spec-info {
  flex: 1;
}
.spec-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}
.spec-desc {
  font-size: 24rpx;
  color: #888;
  margin: 8rpx 0;
}
.spec-price {
  font-size: 28rpx;
  color: #222;
  font-weight: bold;
  margin-top: 40px;
}
.spec-section {
  margin-bottom: 20rpx;
}
.spec-label {
  font-size: 28rpx;
  color: #333;
  margin-bottom: 10rpx;
}
.spec-options {
  display: flex;
  gap: 20rpx;
  flex-wrap: wrap;
}
.spec-option {
  padding: 10rpx 30rpx;
  border-radius: 10rpx;
  background: #f5f5f5;
  color: #222222;
  font-size: 28rpx;
  width: 120rpx;
  text-align: center;
  /* border: 1px solid #F04216; */
  margin-bottom: 10rpx;
}
.spec-option.active {
  background: #fff2ee;
  color: #F04216;
  border: 2px solid #F04216;
}
.spec-qty {
  display: flex;
  align-items: center;
  margin-left: auto;
}
.spec-qty-num {
  font-size: 32rpx;
  width: 50px;
  text-align: center;
  background: #ECECEC;
}
.main-content {
  display: flex;
  flex-direction: row;
}
.sidebar {
  width: 110px;
  background: #EEEEEE;
  border-radius: 20rpx;
  margin: 20rpx 0 20rpx 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
  padding: 10rpx 0;
  overflow-y: auto;
}
.sidebar-item {
  padding:20px;
  text-align: center;
  color: #333;
  font-size: 28rpx;
  cursor: pointer;
}
.sidebar-item.active {
  color: #F04216;
  font-weight: bold;
  background: #FFFFFF;
  border-radius: 10rpx;
}
.dish-list {
  /* flex: 1; */
  padding: 20rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  overflow-y: auto;
  overflow-x: hidden;
  width: calc(100vw - 150px);
}
.dish-item {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 15rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
  padding: 20rpx;
}
.dish-img {
  width: 80px;
  height: 80px;
  border-radius: 10rpx;
  margin-right: 20rpx;
}
.dish-info {
  flex: 1;
  margin-left: 10px;
}
.dish-title {
  font-size: 30rpx;
  font-weight: bold;
  color: #333;
  /* margin-top: 0px; */
}
.dish-desc {
  font-size: 18rpx;
  color: #F04216;
  margin: 8rpx 0;
}
.dish-price {
  font-size: 28rpx;
  color: #222222;
  font-weight: bold;
  margin-top: 30px;
  
}
/* 购物车弹窗样式 */
.cart-dialog {
  background: #fff;
  border-radius: 30rpx 30rpx 0 0;
  padding: 30rpx 20rpx 20rpx 20rpx;
  width: 100vw;
  max-width: 600px;
}
.cart-header {
  display: flex;
  align-items: center;
  margin-bottom: 20rpx;
}
.cart-icon {
  width: 60px;
  height: 60px;
  border-radius: 12rpx;
  border: 2px dashed #ddd;
}
.cart-badge {
  position: absolute;
  top: -10px;
  left: 40px;
  background: #F04216;
  color: #fff;
  font-size: 24rpx;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.08);
}
.cart-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #222;
  margin-left: 20px;
}
.cart-empty {
  text-align: center;
  color: #bbb;
  font-size: 28rpx;
  margin: 40px 0;
}
.cart-list {
  max-height: 300px;
  overflow-y: auto;
  margin-bottom: 20px;
}
.cart-item {
  display: flex;
  align-items: center;
  margin-bottom: 20rpx;
}
.cart-item-img {
  width: 60px;
  height: 60px;
  border-radius: 10rpx;
  margin-right: 20rpx;
}
.cart-item-info {
  flex: 1;
}
.cart-item-name {
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
}
.cart-item-spec {
  font-size: 24rpx;
  color: #888;
  margin: 4rpx 0;
}
.cart-item-price {
  font-size: 28rpx;
  color: #222;
  font-weight: bold;
}
.cart-item-qty {
  display: flex;
  align-items: center;
  margin-right: 30px;
}
.cart-item-qty-num {
  font-size: 28rpx;
  width: 40px;
  height: 25px;
  /* 竖直居中 */
  align-items: center; 
  justify-content: center;
  text-align: center;
  background: #ECECEC;
}
.cart-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 20px;
}
.cart-total {
  display: flex;
  align-items: center;
}
.cart-total-label {
  font-size: 28rpx;
  color: #888;
  margin-right: 10px;
}
.cart-total-price {
  font-size: 36rpx;
  font-weight: bold;
  color: #222;
}
.cart-bar {
  width: 100%;
  height: 60px;
  background: #fff;
  box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.05);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 30rpx;
  border-radius: 30rpx 30rpx 0 0;
  margin-top: 0;
  position: static;
  z-index: 1;
}
.cart-left {
  display: flex;
  align-items: center;
}
.cart-icon-box {
  position: relative;
  width: 60px;
  height: 60px;
  margin-right: 20px;
}
.cart-icon {
  width: 30px;
  height: 30px;
  border-radius: 12rpx;
  border: 2px dashed #ddd;
  margin-top: 15px;
}
.cart-badge {
  position: absolute;
  top: 5px;
  left: 20px;
  background: #F04216;
  color: #fff;
  font-size: 24rpx;
  border-radius: 50%;
  width: 40rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #fff;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.08);
}
.cart-price-box {
  display: flex;
  align-items: center;
}
.cart-price {
  font-size: 36rpx;
  font-weight: bold;
  color: #222;
  margin-left: -20px;
}
.cart-btn {
  margin-left: auto;
}
</style>
