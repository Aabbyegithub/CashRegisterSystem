<template>
  <div class="order-detail-container">
    <!-- 左侧桌台信息区域 -->
    <div class="left-panel">
      <div class="table-info">
        <h2 class="table-number">{{ tableInfo.tableNumber }}</h2>
        <p class="table-desc">{{ tableInfo.desc }}</p>
      </div>
      <div class="table-actions">
        <el-button @click="handleMerge" style="width: 200px; height: 40px;background-color: #EAF7F8;">        
            <template #icon>
                <img 
                src="/src/assets/Frame-5.png"  
                alt="并台" 
                style="width: 15px; height: 15px;" 
                >
                <label style="font-style: normal;font-size: 15px;margin-left: 10px;color: #13899C ;">并台</label>
            </template>
        </el-button>
        <el-button  @click="handleChangeTable" style="width: 200px; height: 40px;background-color: #FFE6E7;margin-left: 0px;">
             <template #icon>
                <img 
                src="/src/assets/Frame-6.png"  
                alt="并台" 
                style="width: 15px; height: 15px;" 
                >
                <label style="font-style: normal;font-size: 15px;margin-left: 10px;color: #FF6768 ;">换桌</label>
            </template>
        </el-button>
      </div>
      <div class="amount-info">
        <p class="total-amount">¥{{ tableInfo.totalAmount }}</p>
        <p class="sub-title">应收金额</p>
        <p>实收金额: ¥{{ tableInfo.receivedAmount }}</p>
        <p style="text-align: left;">抹零金额: ¥{{ tableInfo.zeroAmount?.toFixed(2) }}</p>
      </div>
      <el-button type="success" class="pay-btn" @click="handlePay" style="background-color: #22A2B6;width: 300px;height: 40px;">收款</el-button>
    </div>
    <!-- 右侧订单详情区域 -->
    <div class="right-panel">
      <div class="order-header">
        <div>
        <p>订单编号: {{ orderInfo.orderNumber }}</p>
        <p style="color: #999; font-size: 13px;">创建时间: {{ orderInfo.createTime }}</p>
        </div>
        <div class="order-actions">
          <el-button  @click="handleReturn">返回</el-button>
          <el-button  @click="handleRefund">退款</el-button>
          <el-button type="success"  @click="handleRedo" style="background-color: #22A2B6;">重做</el-button>
        </div>
      </div>
      <el-table
        :data="orderInfo.items"
        border
        style="width: 100%;height: 80vh;"
         @selection-change="handleSelectionChange"
        class="order-table"
      >
        <!-- 复选框列-->
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="序号" width="60" align="center">
          <template #default="scope">
            {{ scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column prop="name" label="品项名称">
            <template #default="scope">
                <span v-html="scope.row.name"></span>
            </template>
        </el-table-column>
        <el-table-column prop="price" width="100" label="品项单价" align="center" />
        <el-table-column prop="quantity" width="100" label="品项数量" align="center" />
        <el-table-column prop="unit" width="100" label="品项单位" align="center" />
        <el-table-column prop="amount" width="100" label="品项金额" align="center" />
        <el-table-column prop="action" width="100" label="操作" align="center">
          <template #default="scope">
            <el-button
              type="text"
              @click="handleItemRefund(scope.row)"
              v-if="scope.row.action === '退款'"
            >
              {{ scope.row.action }}
            </el-button>
            <span v-else>{{ scope.row.action }}</span>
          </template>
        </el-table-column>
      </el-table>
      <div class="order-footer">
        <p style="margin-left: auto;padding-bottom: 20px;">点餐总金额: ¥{{ tableInfo.totalAmount }}<span style="color: #666; font-size: 14px; margin-left: 10px;">
    (不可优惠金额 ¥{{ orderInfo.nonDiscountAmount }})
  </span></p>
        <div class="footer-actions">
             <p style="background-color: #F5F9FB;padding: 10px;">消费项目: ¥{{ tableInfo.totalAmount }}
                <!-- <el-button type="info"  @click="handleItemDetail" style="background-color: #22A2B6;margin-left: 80px;">消费项目明细</el-button> -->
            </p>
          <p style="background-color: #F5F9FB;padding: 10px;">消费金额: ¥{{ tableInfo.totalAmount }}</p>
          <el-button 
            circle
            @click="handlePrint"
            style="border: 1px solid #000 !important;width: 70px;height: 70px;"
            >
            <!-- 自定义图片图标 -->
            <template #icon>
                <div class="icon-container">
                <img 
                src="/src/assets/Frame-7.png"  
                alt="打印" 
                style="width: 40px; height: 40px;" 
                >
                <label style="font-style: normal;">打印</label>
                </div>
            </template>
            </el-button>
        </div>
      </div>
    </div>
  </div>


    <!-- 支付弹窗 -->
    <el-dialog
      title="支付"
      v-model="payDialogVisible"
      width="720px"
      :before-close="handlePayDialogClose"
      class="pay-dialog"
    >
      <div class="pay-content">
        <!-- 左侧金额操作区 -->
        <div class="pay-left">
          <div class="pay-info">
            <p class="pay-title">
              待支付金额
              <span class="amount">¥ {{ toPayAmount?.toFixed(2) }}</span>
            </p>
            <p>本次支付：¥ {{ toPayAmount?.toFixed(2) }} (抹分：¥ 0.00)</p>
          </div>

          <!-- 金额输入框与操作按钮 -->
          <div class="amount-control">
            <el-input
              v-model="inputAmount"
              placeholder="输入金额"
              type="text"
              class="amount-input"
              @input="handleAmountInput"
            />
            <div class="operation-btns">
               <!-- 抹零方式选择--循环出按钮 -->
               <div class="pay-Erase-list">
                  <div 
                    class="pay-Erase-item" 
                    v-for="(item, index) in payErase" 
                    :key="index"
                    :class="{ active: selectEraseZero === item.value }"
                    @click="selectEraseZero = item.value"
                  >
                    {{ item.label }}
                  </div>
                </div>
            </div>
          </div>

          <!-- 数字键盘 -->
          <div class="number-keypad custom-keypad-grid">
            <div class="keypad-btn" @click="handleKeypadClick(7)">7</div>
            <div class="keypad-btn" @click="handleKeypadClick(8)">8</div>
            <div class="keypad-btn" @click="handleKeypadClick(9)">9</div>
            <div class="keypad-btn delete-btn" @click="handleKeypadClick('&times;')">
              <img src="/src/assets/Rectangle 5894.png" alt="删除" class="delete-icon" />
            </div>
            <div class="keypad-btn" @click="handleKeypadClick(4)">4</div>
            <div class="keypad-btn" @click="handleKeypadClick(5)">5</div>
            <div class="keypad-btn" @click="handleKeypadClick(6)">6</div>
            <div class="keypad-btn clear-btn" @click="handleClear">清空</div>
            <div class="keypad-btn" @click="handleKeypadClick(1)">1</div>
            <div class="keypad-btn" @click="handleKeypadClick(2)">2</div>
            <div class="keypad-btn" @click="handleKeypadClick(3)">3</div>
            <!-- <div class="keypad-btn" style="visibility: hidden;"></div> -->
            <div class="keypad-btn" @click="handleKeypadClick(0)">0</div>
            <div class="keypad-btn" @click="handleKeypadClick('00')">00</div>
            <div class="keypad-btn" @click="handleKeypadClick('.')">.</div>
            <div class="keypad-btn" style="visibility: hidden;"></div>
          </div>
        </div>

        <!-- 右侧支付方式选择区 -->
        <div class="pay-right">
          <div class="pay-type-list">
            <div 
              class="pay-type-item" 
              v-for="(item, index) in payTypes" 
              :key="index"
              :class="{ active: selectedPayType === item.value }"
              @click="selectedPayType = item.value"
            >
              {{ item.label }}
            </div>
          </div>
        </div>
      </div>
          <el-button 
            type="primary" 
            class="cancel-btn"
            @click="payDialogVisible = false"
          >取消</el-button>
         <el-button 
            type="primary" 
            class="confirm-btn"
            @click="handlePayConfirm"
          >确认</el-button>
    </el-dialog>


    <!-- 并台弹窗 -->
    <el-dialog
      title="并台"
      v-model="mergeDialogVisible"
      width="650px"
      :before-close="handleMergeDialogClose"
    >
      <div class="merge-table-list">
        <div 
          class="merge-table-item" 
          v-for="(item, index) in tableList" 
          :key="index"
          :class="{ 'active': selectedMergeTables.includes(item.value) }"
          @click="toggleMergeTable(item.value)"
        >
          <div class="merge-label" style="margin-left: 5px;color: #000;">[并入]</div>
          <div style="color: #000;">{{ item.label }}</div>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button  type="primary"  class="cancel-btn" @click="mergeDialogVisible = false">取消</el-button>
          <el-button  class="confirm-btn" type="primary" style="margin-right: 200px;"  @click="confirmMerge">确认</el-button>
        </span>
      </template>
    </el-dialog>


      <!-- 换桌弹窗 -->
    <el-dialog
      title="换桌"
      v-model="changeTableDialogVisible"
      width="650px"
      :before-close="handleChangeTableDialogClose"
    >
      <div class="change-table-container">
        <!-- 当前桌台信息 -->
        <div class="current-table-info">
          <p class="info-label">当前桌台：</p>
          <div class="current-table-item">
            {{ currentTable.label }}
          </div>
        </div>
        
        <!-- 目标桌台列表 -->
        <p class="target-table-label">选择目标桌台：</p>
        <div class="target-table-list">
          <div 
            class="target-table-item" 
            v-for="(item, index) in availableTables" 
            :key="index"
            :class="{ 
              'active': selectedTargetTable === item.value,
              'disabled': item.disabled 
            }"
            @click="selectTargetTable(item.value)"
          >
            <div class="table-status">
              <span v-if="item.disabled" class="status-dot occupied"></span>
              <span v-else class="status-dot available"></span>
            </div>
            <div class="table-content">
              <div class="change-label">换至</div>
              <div class="table-number">{{ item.label }}</div>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button  type="primary"  class="cancel-btn" @click="changeTableDialogVisible = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="confirmChangeTable"
            :disabled="!selectedTargetTable"
            class="confirm-btn"style="margin-right: 200px;"
          >
            确认换桌
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 打印预览弹窗 -->
    <el-dialog v-model="printPreviewVisible" width="350px" title="打印预览" :show-close="true">
      <div id="print-preview-content" v-html="printHtml"></div>
      <template #footer>
        <el-button @click="printPreviewVisible = false">取消</el-button>
        <el-button type="primary" @click="doPrint">打印</el-button>
      </template>
    </el-dialog>
</template>

<script lang="ts" setup>
import { ElButton, ElTable, ElTableColumn ,ElDialog, dayjs, ElMessage } from 'element-plus';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import {  getOrderDetail, OrderCheckout, redoOrder, refundOrder, refundOrderItem } from '../../../api/OrderDetial';
import { getTableList } from '../../../api/FlatOrderManagement';
import { changeTable, mergeTables } from '../../../api/TableOperation';

const route = useRoute();
const router = useRouter();

// 控制支付弹窗显示隐藏
const payDialogVisible = ref(false); 
// 选中的支付方式，默认选微信
const selectedPayType = ref('wechat'); 
const selectEraseZero = ref('score'); // 是否抹零
const inputAmount = ref('￥');
const orderid = ref(route.query.order_id || ''); // 获取订单ID
// 支付方式列表
const payTypes = ref([
  { label: '微信', value: 'wechat' },
  { label: '支付宝', value: 'alipay' },
  { label: '现金', value: 'cash' },
]);
const payErase=ref([
  { label: '不抹零', value: 'noZero' },
  { label: '抹分', value: 'score' },
  { label: '抹角', value: 'angle' },
])
// 模拟数据
const tableInfo=ref<any>({})

const orderInfo=ref<any>( {});


// 控制并台弹窗显示隐藏
const mergeDialogVisible = ref(false); 
// 模拟桌台数据，可根据实际接口返回调整
const tableList = ref<any[]>([])
// 选中的并台桌台
const selectedMergeTables = ref<string[]>([]); 

// 换桌弹窗相关变量
const changeTableDialogVisible = ref(false);
// 当前桌台信息
const currentTable = ref<any>({});
// 可选目标桌台列表（模拟数据）
const availableTables = ref<any[]>([]);
// 选中的目标桌台
const selectedTargetTable = ref('');

// 打印预览相关
const printPreviewVisible = ref(false);
const printHtml = ref('');

// 待支付金额（从 tableInfo 取，也可根据实际逻辑调整）
const toPayAmount = ref(0); 
// 事件处理函数，可根据实际需求对接接口或逻辑
const handleMerge = () => {
  mergeDialogVisible.value = true; // 打开并台弹窗
  console.log('点击拼台');
  // 这里可写拼台相关逻辑，如调用接口等
};

const handleChangeTable = () => {
  changeTableDialogVisible.value = true;
  console.log('点击换桌');
  // 换桌逻辑
};

const handlePay = () => {
  payDialogVisible.value = true; // 打开支付弹窗
  toPayAmount.value = tableInfo.value.receivedAmount; // 初始化待支付金额
  console.log('点击收款');
  // 收款逻辑
};

const handleRefund = async () => {
  console.log('点击订单退款');
  await refundOrder(orderid.value as string).then((res:any)=>{
    if(res.success){
      console.log('退款接口返回:', res);
      ElMessage.success('订单退款成功');
      router.push('/Layout/Orderhome');
    } else {
      ElMessage.error(res.message || '订单退款失败，请稍后重试');
      return;
    }
  }).catch((error)=>{
    ElMessage.error('订单退款失败，请稍后重试');
    console.error(error);
    return;
  })
};

const handleRedo = async () => {
  console.log('点击重做');
  // 重做逻辑
  await redoOrder(orderid.value as string).then((res:any)=>{
    if(res.success){
      console.log('重做接口返回:', res);
      ElMessage.success('订单重做成功');
      router.push('/Layout/Orderhome');
    } else {
      ElMessage.error(res.message || '订单重做失败，请稍后重试');
      return;
    }
  }).catch((error)=>{
    ElMessage.error('订单重做失败，请稍后重试');
    console.error(error);
    return;
  })
};

const handleItemRefund = async (row: any) => {
  console.log('点击品项退款', row);
  await refundOrderItem(row.orderItemId).then((res:any)=>{
    if(res.success){
      console.log('品项退款接口返回:', res);
      ElMessage.success('品项退款成功');
      OrderDetail(); // 刷新订单详情
    } else {
      ElMessage.error(res.message || '品项退款失败，请稍后重试');
      return;
    }
  }).catch((error)=>{
    ElMessage.error('品项退款失败，请稍后重试');
    console.error(error);
    return;
  })
  // 品项退款逻辑
};

const handleItemDetail = () => {
  console.log('点击消费项目明细');
  // 查看明细逻辑
};

const handlePrint = () => {
  const order = orderInfo.value;
  const table = tableInfo.value;
  console.log(111,table)
  const shopName = "九天阁餐厅";
  const tableNumber = table.tableNumber || "-";
  const tableName = table.tableName || "-";
  const partySize = table.table_capacity || "-";
  const orderNumber = order.orderNumber || "-";
  const createTime = order.createTime || "-";
  const items = order.items || [];
  const receivedAmount = table.receivedAmount || 0;

  printHtml.value = `
    <div style="width:320px;font-family:'SimHei',Arial;margin:0 auto;">
      <div style="text-align:center;font-size:20px;font-weight:bold;margin-bottom:8px;">${shopName}</div>
      <hr style="border:none;border-top:1px dashed #333;margin:8px 0;">
      <div style="font-size:14px;margin-bottom:2px;">桌号：${tableNumber}</div>
      <div style="font-size:14px;margin-bottom:2px;">人数：${partySize}</div>
      <div style="font-size:14px;margin-bottom:2px;">单号：${orderNumber}</div>
      <div style="font-size:14px;margin-bottom:2px;">创建时间：${createTime}</div>
      <hr style="border:none;border-top:1px dashed #333;margin:8px 0;">
      <table style="width:100%;font-size:14px;">
        <thead>
          <tr>
            <th style="text-align:left;">菜品</th>
            <th style="text-align:center;">数量</th>
            <th style="text-align:right;">价格</th>
            <th style="text-align:right;">总价</th>
          </tr>
        </thead>
        <tbody>
          ${items.map((item:any, idx:number) => `
            <tr>
              <td style="text-align:left;">${idx+1}. ${item.name}</td>
              <td style="text-align:center;">${item.quantity}${item.unit || ''}</td>
              <td style="text-align:right;">${item.price}</td>
              <td style="text-align:right;">${item.amount}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      <hr style="border:none;border-top:1px dashed #333;margin:8px 0;">
      <div style="font-size:16px;font-weight:bold;text-align:left;margin-top:8px;">实收金额：${receivedAmount}</div>
    </div>
  `;
  printPreviewVisible.value = true;
};

// 真正打印
const doPrint = () => {
  const printContent = document.getElementById('print-preview-content');
  if (!printContent) return;
  const printWindow = window.open('', '', 'width=350,height=600');
  printWindow!.document.write(`
    <html>
      <head>
        <title>打印小票</title>
        <style>
          @media print { body { margin:0; } }
        </style>
      </head>
      <body>${printContent.innerHTML}</body>
    </html>
  `);
  printWindow!.document.close();
  printWindow!.focus();
  printWindow!.print();
  printWindow!.close();
  printPreviewVisible.value = false;
};

const handleSelectionChange = (val:any) => {
  console.log('选中的行数据：', val);
  // 这里可根据需求编写选中行的处理逻辑，比如收集选中项进行批量操作等
};

// 数字键盘点击事件
const handleKeypadClick = (val: string | number) => {
  console.log('点击键盘按钮:', inputAmount.value);
  if (val === '×') {
    if(inputAmount.value !== '￥') {
      inputAmount.value = inputAmount.value.slice(0, -1);
    } else {
      inputAmount.value = '￥'; // 如果只剩下￥，则清空
    }
  } else {
    inputAmount.value += val;
  }
  // 实时更新待支付金额（如果需要手动输入金额）
  toPayAmount.value = Number(inputAmount.value) || tableInfo.value.receivedAmount;
};

// 金额输入框事件（防止非数字输入）
const handleAmountInput = (val: string) => {
  inputAmount.value = val.replace(/[^\d.]/g, '');
};

// 清空按钮事件
const handleClear = () => { 
  inputAmount.value = '￥';
  toPayAmount.value = tableInfo.value.receivedAmount;
};

// 关闭弹窗事件
const handlePayDialogClose = () => {
  payDialogVisible.value = false;
  // 重置状态
  inputAmount.value = '￥';
  toPayAmount.value = tableInfo.value.receivedAmount;
  selectedPayType.value = 'wechat';
};

// 确认支付事件
const handlePayConfirm = async () => {
  console.log('选中支付方式：', selectedPayType.value);
  console.log('支付金额：', toPayAmount.value);
  if(toPayAmount.value <= 0) {
    ElMessage.error('支付金额必须大于0');
    return;
  }
  ElMessage.warning('请使用扫码枪扫描付款码完成支付');
    // 调用扫码机接口，获取付款码
  let payCode = '';
  try {
    // 这里 scanCode() 是扫码机 SDK 的方法，返回付款码
    payCode = await scanCode(); // 需替换为实际扫码机方法
    if (!payCode) {
      ElMessage.error('未获取到付款码，请重新扫码');
      return;
    }
  } catch (err) {
    ElMessage.error('扫码失败，请重试');
    return;
  }
  // 这里可对接实际支付接口
  await OrderCheckout(orderid.value as string,selectedPayType.value,payCode).then(async (res:any)=>{
    if(res.success){
      orderInfo.value.status='已支付'
      
      console.log('支付接口返回:', res);
      ElMessage.success('支付成功');
      payDialogVisible.value = false;
      await handlePrint();
    } else {
      ElMessage.error(res.message || '支付失败，请稍后重试');
      return;
    }

  }).catch((error)=>{
    ElMessage.error('支付失败，请稍后重试');
    console.error(error);
    return;
  })
};

function scanCode(): Promise<string> {
  return new Promise((resolve) => {
    const input = document.createElement('input');
    input.type = 'text';
    input.style.position = 'fixed';
    input.style.top = '-1000px';
    document.body.appendChild(input);
    input.focus();
    input.addEventListener('keydown', function handler(e) {
      if (e.key === 'Enter') {
        resolve(input.value);
        input.removeEventListener('keydown', handler);
        document.body.removeChild(input);
      }
    });
  });
}



// 切换桌台选中状态
const toggleMergeTable = (tableValue: string) => {
  if (selectedMergeTables.value.includes(tableValue)) {
    selectedMergeTables.value = selectedMergeTables.value.filter(val => val !== tableValue);
  } else {
    selectedMergeTables.value.push(tableValue);
  }
};

// 关闭并台弹窗时重置状态
const handleMergeDialogClose = () => {
  selectedMergeTables.value = [];
  mergeDialogVisible.value = false;
};

// 确认并台逻辑（可根据实际需求调用接口等）
const confirmMerge = async () => {
  console.log('选中的并台桌台：', selectedMergeTables.value);
  // 这里可编写调用接口合并桌台的逻辑，比如：
  // api.mergeTables(selectedMergeTables.value).then(() => {
  //   // 合并成功后的处理，如刷新桌台列表等
  // }).catch(() => {
  //   // 失败处理
  // });
  await mergeTables(currentTable.value.tableId, Number(selectedMergeTables.value) ?? 0,orderid.value as string);
  ElMessage.success('并桌成功');
  mergeDialogVisible.value = false;
};

const handleReturn =()=> {
   window.history.back();
}
// 换桌弹窗方法
const selectTargetTable = (tableValue: string) => {
  // 跳过已禁用的桌台
  const table = availableTables.value.find(item => item.value === tableValue);
  if (table && !table.disabled) {
    selectedTargetTable.value = tableValue;
  }
};

const handleChangeTableDialogClose = () => {
  selectedTargetTable.value = '';
  changeTableDialogVisible.value = false;
};

const confirmChangeTable = async () => {
  if (!selectedTargetTable.value) return;
  
  const targetTable = availableTables.value.find(
    item => item.value === selectedTargetTable.value
  );

  await changeTable(currentTable.value.tableId,Number(selectedTargetTable.value) ?? 0,orderid.value as string).then((res:any)=>{
    console.log('换桌接口返回:', res);
  }).catch((error)=>{
    ElMessage.error('换桌失败，请稍后重试');
    console.error(error);
    return;
  });
  ElMessage.success('换桌成功');
  handleChangeTableDialogClose();
};

onMounted(async () => {
  console.log('订单ID:', orderid.value);
  await OrderDetail();
  await gettableList();
  inputAmount.value = '￥' + tableInfo.value.receivedAmount.toFixed(2);
});

async function OrderDetail() {
  await getOrderDetail(orderid.value as string)
    .then((res: any) => {
      orderInfo.value = res.response;
      orderInfo.value.createTime = dayjs(orderInfo.value.createTime).format('YYYY-MM-DD HH:mm:ss');
      tableInfo.value = res.response;
      currentTable.value = {
        label: tableInfo.value.tableNumber,
        value: tableInfo.value.tableId.toString(),
      };
      console.log('订单详情数据:', orderInfo.value);
    })
}

async function gettableList() {
  await getTableList().then((res: any) => {
    tableList.value = res.response.filter((item: any) => item.status === 2 && item.name !=currentTable.value.label).map((item: any) => ({
      label: item.name,
      value: item.id,
    }));
    console.log('桌台列表数据:', tableList.value);
    console.log('当前桌台:', currentTable.value);
    availableTables.value = res.response.map((item: any) => ({
      label: item.name,
      value: item.id,
      disabled: item.status !== 1, // 假设状态2表示可用
    }));
  })
}
</script>

<style scoped>
.order-detail-container {
  display: flex;
  padding: 20px;
  gap: 20px;
  background-color: #fff;
  /* min-height: calc(100vh - 64px); 可根据布局调整 */
  height: 100%;
}

.left-panel {
  width: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  border-right: 1px solid #ebeef5;
  padding-right: 20px;
}

.table-info {
  text-align: center;
  margin-bottom: 20px;
}

.table-number {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 10px;
}

.table-desc {
  color: #999;
}

.table-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 30px;
  margin-top: 10px;
}

.amount-info {
  text-align: center;
  margin-bottom: 20px;
  margin-top: 200px;
}

.total-amount {
  font-size: 40px;
  font-weight: bold;
  margin-bottom: 10px;
}

.sub-title {
  color: #999;
  margin-bottom: 5px;
}

.pay-btn {
  width: 180px;
  margin-top: 50px;
}

.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.order-actions {
  display: flex;
  gap: 10px;
}

.order-table {
  margin-bottom: 20px;
  --el-table-bg-color: #F5FBFB; /* 表格整体背景色 */
  --el-table-header-bg-color: #f0f2f5; /* 表头背景色 */
}

.order-footer {
  display: flex;
  justify-content: space-between;
  flex-direction: column;
  align-items: center;
}

.footer-actions {
  display: flex;
  gap: 20px;
  align-items: center;
  margin-left: auto;
  margin-right: 20px;
}

/* 适配表格内容换行 */
.el-table .cell {
  white-space: pre-line;
}
.icon-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}





/* 支付弹窗整体样式 */
.pay-dialog {
  --el-dialog-padding: 0;
}
.pay-content {
  display: flex;
  width: 100%;
  height: 450px;
}

/* 左侧金额操作区 */
.pay-left {
  width: 50%;
  background-color: #fff;
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.pay-info {
  margin-bottom: -90px;
}
.pay-title {
  font-size: 16px;
  margin-bottom: 10px;
}
.amount {
  color: #ff9900;
  font-size: 20px;
}
.amount-control {
  display: flex;
  flex-direction: column;
  margin-bottom: 10px;
}
.amount-input {
  width: 95%;
  margin-top: 100px;
  margin-bottom: 10px;
  height: 40px;
}
:deep(.amount-input .el-input__inner) {
  text-align: center; /* 文字水平居中 */
  color: #ff6700; /* 文字颜色，可自定义 */
  font-size: 30px; /* 可选：调整字体大小 */
}
.operation-btns {
  display: flex;
  gap: 10px;
}

/* 数字键盘样式 */
/* 数字键盘网格布局 */
.custom-keypad-grid {
  display: grid;
  grid-template-columns: repeat(4, 69px);
  grid-template-rows: repeat(4, 60px);
  gap: 5px;
  margin-bottom: 50px;
}
.keypad-btn {
  background-color: #f8f9fa;
  border: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border-radius: 4px;
  font-size: 20px;
  font-weight: 400;
}
.keypad-btn:hover {
  background-color: #f1f2f4;
}
.delete-btn {
  grid-row: 1 / span 2;
  grid-column: 4;
}
.clear-btn {
  grid-row: 3 / span 2;
  grid-column: 4;
  font-size: 16px;
}
.delete-icon {
  width: 20px;
  height: 20px;
}
/* 取消按钮 */
.cancel-btn {
  align-self: flex-start;
  width: 20%;
  background-color: #fff;
  border-color: #6b5d5d;
  color: #000;
  margin-left: 25%;
  height: 40px;
  /* margin-top: -100px; */
}

/* 右侧支付方式选择区 */
.pay-right {
  width: 50%;
  height: 430px;
  background-color: #f8f9fa;
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.pay-type-title {
  font-size: 16px;
  margin-bottom: 20px;
  color: #333;
}
.pay-type-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.pay-Erase-list{
  display: flex;
  gap:10px
}
.pay-type-item {
  padding: 10px;
  background-color: #fff;
  border: 1px solid #ebeef5;
  cursor: pointer;
  border-radius: 4px;
  text-align: center;
}

.pay-Erase-item{
  padding: 10px;
  background-color: #fff;
  border: 1px solid #ebeef5;
  cursor: pointer;
  border-radius: 4px;
  text-align: center;
  line-height: 10px;
  width: 90px;
  height: 30px;
}
.pay-type-item.active {
  background-color: #22a2b6;
  color: #fff;
  border-color: #22a2b6;
}
.pay-Erase-item.active {
  background-color: #F98D40;
  color: #fff;
  border-color: #F98D40;
}

/* 确认按钮 */
.confirm-btn {
  align-self: flex-start;
  width: 20%;
  background-color: #22a2b6;
  border-color: #22a2b6;
    height: 40px;
}
.confirm-btn:hover {
  background-color: #1c8a9b;
  border-color: #1c8a9b;
}

/* 并台弹窗 */
.merge-table-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.merge-table-item {
  padding: 10px 15px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  cursor: pointer;
  width: 90px;
}
.merge-table-item.active {
  background-color: #FFEEEE;
  color: #fff;
  border-color: #F04216;
}
.dialog-footer {
  text-align: right;
}





/* 换桌弹窗样式 */
.change-table-container {
  padding: 10px 0;
}

.current-table-info {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px dashed #eee;
}

.info-label {
  font-size: 14px;
  color: #666;
  margin-right: 10px;
  white-space: nowrap;
}

.current-table-item {
  padding: 8px 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  font-weight: 500;
}

.target-table-label {
  font-size: 14px;
  color: #666;
  margin-bottom: 10px;
}

.target-table-list {
  display: flex;
   flex-wrap: wrap;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
}

.target-table-item {
  padding: 15px 10px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  cursor: pointer;
  text-align: center;
  transition: all 0.2s;
  position: relative;
}

.target-table-item.disabled {
  cursor: not-allowed;
  opacity: 0.6;
  background-color: #f5f5f5;
}

.target-table-item.active {
  background-color: #FF6768;
  border-color: #FF6768;
}

.table-status {
  position: absolute;
  top: 5px;
  right: 5px;
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-dot.available {
  background-color: #52c41a; /* 可用桌台-绿色 */
}

.status-dot.occupied {
  background-color: #faad14; /* 已占用-黄色 */
}

.table-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.change-label {
  font-size: 12px;
  color: #666;
  margin-bottom: 5px;
}

.target-table-item.active .change-label,
.target-table-item.active .table-number {
  color: #fff;
}

.table-number {
  font-size: 16px;
  font-weight: 500;
}
</style>