<template>
  <div class="member-management-container">
    <!-- 筛选区 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="手机号：">
        <el-input v-model="searchPhone" placeholder="请输入手机号" clearable style="min-width:140px;" />
      </el-form-item>
      <el-form-item label="姓名：">
        <el-input v-model="searchName" placeholder="请输入姓名" clearable style="min-width:140px;" />
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="searchStatus" placeholder="全部状态" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="1" label="正常" />
          <el-option value="0" label="冻结" />
        </el-select>
      </el-form-item>
      <el-form-item label="注册时间：">
        <el-date-picker v-model="searchRegister" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" style="min-width:220px;" />
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="showAddMember = true" class="Btn-Save">新增会员</el-button>
      </el-form-item>
    </el-form>

    <!-- 会员列表 -->
    <el-table :data="filteredMembers" border style="width:100%;height: 68vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="member_no" label="会员编号" align="center" />
      <el-table-column prop="phone" label="手机号" align="center" />
      <el-table-column prop="name" label="姓名" align="center" />
      <el-table-column prop="birthday" label="生日" align="center" />
      <el-table-column prop="register_time" label="注册时间" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'" effect="plain">{{ scope.row.status === 1 ? '正常' : '冻结' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="total_points" label="总积分" align="center" />
      <el-table-column prop="referrer_id" label="推荐人" align="center">
        <template #default="scope">
          {{ getReferrerName(scope.row.referrer_id) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="220">
        <template #default="scope">
          <el-button type="text" class="table-btn-balance" @click="openBalanceDialog(scope.row)">储值</el-button>
          <el-button type="text" class="table-btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button type="text" class="table-btn-status" @click="toggleStatus(scope.row)">{{ scope.row.status === 1 ? '冻结' : '解冻' }}</el-button>
        </template>
      </el-table-column>
    <!-- 编辑会员弹窗（移到根节点，避免嵌套在 el-table-column 内） -->
    <el-dialog v-model="showEditMember" width="500" title="编辑会员">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="手机号">
          <el-input v-model="editForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker v-model="editForm.birthday" type="date" placeholder="请选择生日" style="width:100%;" />
        </el-form-item>
        <el-form-item label="推荐人">
          <el-select v-model="editForm.referrer_id" placeholder="请选择推荐人">
            <el-option v-for="m in memberList" :key="m.member_id" :label="m.name" :value="m.member_id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditMember = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleEditMember" class="Btn-Save">保存</el-button>
      </template>
    </el-dialog>
    </el-table>
    <div v-if="filteredMembers.length === 0" class="empty-row">
      <el-empty description="暂无会员记录" />
    </div>

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

    <!-- 新增会员弹窗 -->
    <el-dialog v-model="showAddMember" width="500" title="新增会员">
      <el-form :model="addForm" label-width="120px">
        <el-form-item label="手机号">
          <el-input v-model="addForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="addForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="生日">
          <el-date-picker v-model="addForm.birthday" type="date" placeholder="请选择生日" style="width:100%;" />
        </el-form-item>
        <el-form-item label="推荐人">
          <el-select v-model="addForm.referrer_id" placeholder="请选择推荐人">
            <el-option v-for="m in memberList" :key="m.member_id" :label="m.name" :value="m.member_id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddMember = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleAddMember" class="Btn-Save">保存</el-button>
      </template>
    </el-dialog>

    <!-- 储值弹窗 -->
    <el-dialog v-model="showBalanceDialog" width="500" title="会员储值">
      <el-form :model="balanceForm" label-width="120px">
        <el-form-item label="充值金额">
          <el-input v-model.number="balanceForm.recharge_amount" type="number" placeholder="请输入充值金额" />
        </el-form-item>
        <el-form-item label="赠送金额">
          <el-input v-model.number="balanceForm.give_amount" type="number" placeholder="请输入赠送金额" />
        </el-form-item>
        <el-form-item label="支付方式">
          <el-select v-model="balanceForm.payment_id" placeholder="请选择支付方式">
            <el-option value="1" label="微信" />
            <el-option value="2" label="支付宝" />
            <el-option value="3" label="现金" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作员工">
          <el-input v-model="balanceForm.operator_id" placeholder="请输入员工ID" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showBalanceDialog = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleBalance" class="Btn-Save">确认储值</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
const showEditMember = ref(false);
const editForm = ref({
  member_id: 0,
  phone: '',
  name: '',
  birthday: '',
  referrer_id: undefined as number | undefined
});
import { ref, computed } from 'vue';
import { ElMessage } from 'element-plus';

interface Member {
  member_id: number;
  member_no: string;
  phone: string;
  name?: string;
  birthday?: string;
  register_time: string;
  status: number;
  total_points: number;
  referrer_id?: null | number;
}
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

const searchPhone = ref('');
const searchName = ref('');
const searchStatus = ref('');
const searchRegister = ref<[Date | null, Date | null] | null>(null);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

const memberList = ref<Member[]>([
  { member_id: 1, member_no: 'M001', phone: '13812345678', name: '张三', birthday: '1990-01-01', register_time: '2025-08-01 10:00:00', status: 1, total_points: 100 },
  { member_id: 2, member_no: 'M002', phone: '13987654321', name: '李四', birthday: '1992-05-12', register_time: '2025-08-10 09:30:00', status: 0, total_points: 50, referrer_id: 1 },
]);

const filteredMembers = computed(() => {
  let result = memberList.value.filter(m => {
    const matchPhone = !searchPhone.value || m.phone.includes(searchPhone.value);
    const matchName = !searchName.value || (m.name && m.name.includes(searchName.value));
    const matchStatus = !searchStatus.value || String(m.status) === searchStatus.value;
    let matchRegister = true;
    if (searchRegister.value && searchRegister.value[0] && searchRegister.value[1]) {
      const start = new Date(searchRegister.value[0]).getTime();
      const end = new Date(searchRegister.value[1]).getTime();
      const reg = new Date(m.register_time).getTime();
      matchRegister = reg >= start && reg <= end;
    }
    return matchPhone && matchName && matchStatus && matchRegister;
  });
  total.value = result.length;
  // 分页
  const startIdx = (currentPage.value - 1) * pageSize.value;
  return result.slice(startIdx, startIdx + pageSize.value);
});

const showAddMember = ref(false);
const addForm = ref({
  phone: '',
  name: '',
  birthday: '',
  referrer_id: undefined as number | undefined
});
const handleAddMember = () => {
  if (!addForm.value.phone) {
    ElMessage.warning('请填写手机号');
    return;
  }
  const newId = Date.now();
  const member: Member = {
    member_id: newId,
    member_no: 'M' + newId,
    phone: addForm.value.phone,
    name: addForm.value.name,
    birthday: addForm.value.birthday,
    register_time: new Date().toISOString(),
    status: 1,
    total_points: 0
  };
  if (addForm.value.referrer_id !== undefined) member.referrer_id = addForm.value.referrer_id;
  memberList.value.push(member);
  showAddMember.value = false;
  ElMessage.success('新增会员成功');
};

const showBalanceDialog = ref(false);
const balanceForm = ref({
  recharge_amount: 0,
  give_amount: 0,
  payment_id: 1,
  operator_id: ''
});
let currentMemberId: number | null = null;
const openBalanceDialog = (row: Member) => {
  currentMemberId = row.member_id;
  balanceForm.value = {
    recharge_amount: 0,
    give_amount: 0,
    payment_id: 1,
    operator_id: ''
  };
  showBalanceDialog.value = true;
};
const handleBalance = () => {
  if (!currentMemberId || !balanceForm.value.recharge_amount) {
    ElMessage.warning('请填写充值金额');
    return;
  }
  // 此处可扩展为储值记录写入
  showBalanceDialog.value = false;
  ElMessage.success('储值成功');
};

const openEditDialog = (row: Member) => {
  editForm.value = {
    member_id: row.member_id,
    phone: row.phone,
    name: row.name ?? '',
    birthday: row.birthday ?? '',
    referrer_id: typeof row.referrer_id === 'number' ? row.referrer_id : undefined
  };
  showEditMember.value = true;
};
const handleEditMember = () => {
  const idx = memberList.value.findIndex(m => m.member_id === editForm.value.member_id);
  if (idx !== -1) {
    memberList.value[idx] = {
      ...memberList.value[idx],
      phone: editForm.value.phone,
      name: editForm.value.name,
      birthday: editForm.value.birthday,
      referrer_id: editForm.value.referrer_id
    };
    ElMessage.success('会员信息已更新');
    showEditMember.value = false;
  }
};

const toggleStatus = (row: Member) => {
  row.status = row.status === 1 ? 0 : 1;
  ElMessage.success(row.status === 1 ? '已解冻' : '已冻结');
};
const getReferrerName = (id?: number | null) => {
  if (!id) return '-';
  const ref = memberList.value.find(m => m.member_id === id);
  return ref?.name || '-';
};
const handleQuery = () => {};
const handleReset = () => {
  searchPhone.value = '';
  searchName.value = '';
  searchStatus.value = '';
  searchRegister.value = null;
};
const handleSizeChange = (val: number) => {
  pageSize.value = val;
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
};
</script>

<style scoped>
.member-management-container {
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
