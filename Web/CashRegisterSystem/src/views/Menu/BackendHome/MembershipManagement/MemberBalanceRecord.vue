<template>
  <div class="member-balance-record-container">
    <!-- 筛选区 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="手机号/姓名：">
        <el-input v-model="searchKeyword" placeholder="请输入手机号或姓名" clearable style="min-width:180px;" />
      </el-form-item>
      <el-form-item label="时间区间：">
        <el-date-picker v-model="searchDate" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" style="min-width:220px;" />
      </el-form-item>
      <el-form-item label="操作员工：">
        <el-input v-model="searchOperator" placeholder="请输入员工" clearable style="min-width:120px;" />
      </el-form-item>
    <el-form-item>
      <el-button @click="handleReset" class="cancel-btn">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
    </el-form-item>
    </el-form>

    <!-- 储值记录列表 -->
    <el-table :data="filteredRecords" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="member_no" label="会员编号" align="center" />
      <el-table-column prop="name" label="姓名" align="center" />
      <el-table-column prop="phone" label="手机号" align="center" />
      <el-table-column prop="recharge_amount" label="充值金额" align="center" />
      <el-table-column prop="give_amount" label="赠送金额" align="center" />
      <el-table-column prop="balance" label="当前余额" align="center"/>
      <el-table-column prop="recharge_time" label="充值时间" align="center" />
      <!-- <el-table-column prop="payment_id" label="支付方式" align="center">
        <template #default="scope">
          <span class="table-btn-balance">{{ paymentMap[scope.row.payment_id] }}</span>
        </template>
      </el-table-column> -->
      <el-table-column prop="operator_name" label="操作员工" align="center"/>
    </el-table>
    <!-- <div v-if="filteredRecords.length === 0" class="empty-row">
      <el-empty description="暂无储值记录" />
    </div> -->

    <!-- 分页 -->
    <div class="pagination-bar">
      <el-pagination
        layout="prev, pager, next, ->, sizes, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="currentPage"
        :page-sizes="[10, 20, 30, 40, 50]"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue';
import { getBalanceRecordList } from '../../../../api/member';


interface BalanceRecord {
  balance_id: number;
  member_id: number;
  balance: number;
  recharge_amount: number;
  give_amount: number;
  recharge_time: string;
  payment_id: number;
  operator_id: number;
}

const paymentMap: Record<number, string> = {
  1: '微信',
  2: '支付宝',
  3: '现金',
};

const searchKeyword = ref('');
const searchDate = ref<[Date | null, Date | null] | null>(null);
const searchOperator = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

const recordList = ref<BalanceRecord[]>([]);

const filteredRecords = computed(() => {
  return recordList.value;
});

const handleQuery = async () => {
  const params: any = {
    page: currentPage.value,
    size: pageSize.value,
    keyword: searchKeyword.value,
    operatorId: searchOperator.value
  };
  if (searchDate.value && searchDate.value[0] && searchDate.value[1]) {
    params.startDate = new Date(searchDate.value[0]).toISOString();
    params.endDate = new Date(searchDate.value[1]).toISOString();
  }
  const res:any = await getBalanceRecordList(params);
  if (res?.success) {
    recordList.value = (res.response || []).map((r: any) => ({
      ...r,
      recharge_time: r.recharge_time ? r.recharge_time.replace('T', ' ').slice(0, 19) : '',
      operator_name: r.operatorName?.name || '-',
      balance: parseFloat(r.member?.balance.toFixed(2)),
      recharge_amount: parseFloat(r.recharge_amount.toFixed(2)),
      member_no: r.member?.member_no || '-',
      name: r.member?.name || '-',
      phone: r.member?.phone || '-',
    }));
    total.value = res.count || 0;
  } else {
    recordList.value = [];
    total.value = 0;
  }
};

const handleReset = () => {
  searchKeyword.value = '';
  searchDate.value = null;
  searchOperator.value = '';
  handleQuery();
};
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  handleQuery();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  handleQuery();
};

onMounted(() => {
  handleQuery();
});
</script>

<style scoped>
.member-balance-record-container {
  padding: 20px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  margin-bottom: 16px;
}
.empty-row {
  width: 100%;
  text-align: center;
  padding: 40px 0;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
  padding: 18px 24px 0 0;
  font-size: 15px;
}
.Btn-Save {
  background-color: #22a2b6;
  border-color: #22a2b6;
  color: #fff;
  min-width: 90px;
  height: 36px;
}
.cancel-btn {
  background-color: #fff;
  border-color: #6b5d5d;
  color: #000;
  min-width: 90px;
  height: 36px;
  margin-right: 12px;
}
.custom-table >>> .el-table__body tr:hover {
  background: #e6f7fa !important;
}
.table-btn-balance {
  color: #22a2b6 !important;
  font-weight: 500;
  margin-right: 8px;
}
.table-btn-edit {
  color: #67c23a !important;
  font-weight: 500;
  margin-right: 8px;
}
.table-btn-status {
  color: #f56c6c !important;
  font-weight: 500;
}
</style>
