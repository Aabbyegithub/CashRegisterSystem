<template>
  <div class="promotion-list-container">
    <!-- 筛选区 -->
      <el-form :inline="true" :model="filterForm" class="filter-form">
      <el-form-item label="门店">
          <el-select v-model="selectedStore" class="store-select" placeholder="请选择门店" style="min-width: 120px;">
            <el-option value="">全部门店</el-option>
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
      </el-form-item>
        <el-form-item label="活动名称">
          <el-input v-model="filterForm.name" placeholder="请输入活动名称" clearable />
        </el-form-item>
        <el-form-item label="活动类型">
          <el-select v-model="filterForm.type" placeholder="请选择类型" clearable style="width: 150px;">
            <el-option label="全部" value="" />
            <el-option label="满减" value="1" />
            <el-option label="折扣" value="2" />
            <el-option label="赠品" value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="filterForm.status" placeholder="请选择状态" clearable style="width: 150px;">
            <el-option label="全部" value="" />
            <el-option label="未开始" value="未开始" />
            <el-option label="进行中" value="进行中" />
            <el-option label="已结束" value="已结束" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="margin-left:auto;">
          <el-button type="success" @click="openDialog('add')">新建活动</el-button>
        </el-form-item>
      </el-form>


    <!-- 表格区 -->
    <div class="table-card">
      <el-table :data="promotionList" border stripe style="width: 100%;height: 67vh;" class="custom-table">
        <el-table-column label="门店名称" prop="store_id" align="center">
            <template #default="scope">
             {{ storeList.find(cat => cat.id === scope.row.store_id)?.name || '' }}
            </template>
        </el-table-column>
        <el-table-column prop="promotion_name" label="活动名称" min-width="120"  align="center"/>
        <el-table-column prop="type" label="类型" min-width="100"  align="center"/>
        <el-table-column prop="start_time" label="开始时间" min-width="160"  align="center"/>
        <el-table-column prop="end_time" label="结束时间" min-width="160"  align="center"/>
        <el-table-column prop="applicable_scope" label="适用范围" min-width="120"  align="center"/>
        <el-table-column prop="status" label="状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="statusTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="min_consumption" label="最低消费金额" min-width="120"  align="center"/>
        <el-table-column prop="value" label="优惠面值或折扣" min-width="120"  align="center"/>
        <el-table-column label="操作" min-width="150" align="center">
          <template #default="scope">
            <el-button type="text"  class="table-btn-edit" size="small" @click="openDialog('edit', scope.row)">编辑</el-button>
            <el-button type="text" class="table-btn-status" size="small" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination
          layout="prev, pager, next, ->, sizes, jumper"
          :total="total"
          :page-size="pageSize"
          :current-page="currentPage"
          :page-sizes="[10, 20, 30, 50]"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>

    <!-- 新建/编辑弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="520px" :close-on-click-modal="false">
      <el-form :model="dialogForm" :rules="dialogRules" ref="dialogFormRef" label-width="110px">
        <el-form-item label="门店">
          <el-select v-model="dialogForm.store_id" placeholder="请选择门店">
              <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="活动名称" prop="name">
          <el-input v-model="dialogForm.name" placeholder="请输入活动名称" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="dialogForm.type" placeholder="请选择类型">
            <el-option label="满减" value="1" />
            <el-option label="折扣" value="2" />
            <el-option label="赠品" value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker v-model="dialogForm.startTime" type="date" placeholder="选择开始日期" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker v-model="dialogForm.endTime" type="date" placeholder="选择结束日期" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="适用范围" prop="scope">
          <el-input v-model="dialogForm.scope" placeholder="请输入适用范围" />
        </el-form-item>
        <el-form-item v-if="dialogForm.type != '3'" label="最低消费金额" prop="scope">
          <el-input v-model="dialogForm.min_consumption" placeholder="不填默认折扣支持所有消费" />
        </el-form-item>
        <el-form-item v-if="dialogForm.type == '1'" label="优惠面值" prop="value">
          <el-input v-model="dialogForm.value" placeholder="请输入优惠面值" />
        </el-form-item>
        <el-form-item v-if="dialogForm.type == '2'" label="折扣" prop="value">
          <el-input v-model="dialogForm.value" placeholder="请输入折扣" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="dialogForm.status" placeholder="请选择状态">
            <el-option label="未开始" value="未开始" />
            <el-option label="进行中" value="进行中" />
            <el-option label="已结束" value="已结束" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleDialogConfirm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, nextTick } from 'vue';
import { dayjs, ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { getStoreList } from '../../../../api/login';
import { getPromotionList, addPromotion, updatePromotion, deletePromotion } from '../../../../api/Promotion';

// 筛选表单
const filterForm = reactive({
  name: '',
  type: '',
  status: '',
});

// 促销活动列表
interface Promotion {
  promotion_id: number;
  store_id: number;
  promotion_name: string;
  type: string | number;
  start_time: string;
  end_time: string;
  applicable_scope: string;
  status: string | number;
  min_consumption?: string;
  value?: string;
}
const promotionList = ref<Promotion[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const storeList = ref<any[]>([])
const selectedStore = ref('');
// 弹窗相关
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogFormRef = ref<FormInstance>();
const dialogForm = reactive({
  promotion_id: 0,
  store_id: '',
  name: '',
  type: '',
  startTime: '',
  endTime: '',
  scope: '',
  status: '',
  min_consumption: '',
  value: '',
});
const dialogRules = reactive<FormRules>({
  name: [{ required: true, message: '请输入活动名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  scope: [{ required: true, message: '请输入适用范围', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
});

// 状态标签类型
const statusTagType = (status: string | number) => {
  switch (status) {
    case 0:
    case '未开始': return 'info';
    case 1:
    case '进行中': return 'success';
    case 2:
    case '已结束': return 'warning';
    default: return '';
  }
};

// 查询、重置
const handleQuery = async () => {
  const typeMap: any = { '满减': 0, '折扣': 1, '赠品': 2, '': '' };
  const statusMap: any = { '未开始': 0, '进行中': 1, '已结束': 2, '': '' };
  const res = await getPromotionList(
    currentPage.value,
    pageSize.value,
    selectedStore.value,
    filterForm.name,
    typeMap[filterForm.type],
    statusMap[filterForm.status]
  );
  const data:any = res;
  if (data.success && data.response) {
    promotionList.value = data.response.map((item: any) => ({
      promotion_id: item.promotion_id,
      store_id: item.store_id,
      promotion_name: item.promotion_name,
      type: ['','满减', '折扣', '赠品'][item.type] ?? item.type,
      start_time: dayjs(item.start_time).format('YYYY-MM-DD HH:mm:ss'),
      end_time: dayjs(item.end_time).format('YYYY-MM-DD HH:mm:ss'),
      applicable_scope: item.applicable_scope,
      status: ['未开始', '进行中', '已结束'][item.status] ?? item.status,
      min_consumption: item.min_consumption ? item.min_consumption + '元' : '',
      value: item.type === 1 ? (item.value ? item.value + '元' :'') : (item.type === 2 ? (item.value ? item.value + '折' : '') : ''),
    }));
    total.value = data.count || data.response.length;
  } else {
    promotionList.value = [];
    total.value = 0;
  }
};
const handleReset = () => {
  filterForm.name = '';
  filterForm.type = '';
  filterForm.status = '';
  selectedStore.value = '';
  currentPage.value = 1;
  handleQuery();
};

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  handleQuery();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  handleQuery();
};

// 新建/编辑弹窗
const openDialog = (type: 'add' | 'edit', row?: Promotion) => {
  dialogTitle.value = type === 'add' ? '新建活动' : '编辑活动';
  dialogVisible.value = true;
  if (type === 'edit' && row) {
    Object.assign(dialogForm, {
      promotion_id: row.promotion_id,
      store_id: row.store_id,
      name: row.promotion_name,
      type: row.type === '满减' ? '1' : row.type === '折扣' ? '2' : row.type === '赠品' ? '3' : row.type,
      startTime: row.start_time,
      endTime: row.end_time,
      scope: row.applicable_scope,
      status: row.status,
      min_consumption: row.min_consumption ? row.min_consumption.replace('元','') : '',
      value: row.value ? (row.type === '折扣' ? row.value.replace('折','') : row.value.replace('元','')) : '',
    });
    // 触发 type 的响应式更新，确保表单项立即显示
    nextTick(() => {
      dialogForm.type = dialogForm.type;
    });
  } else {
    Object.assign(dialogForm, {
      promotion_id: 0,
      store_id: '',
      name: '',
      type: '',
      startTime: '',
      endTime: '',
      scope: '',
      status: '',
      min_consumption: '',
      value: '',
    });
  }
};
const handleDialogConfirm = async () => {
  dialogFormRef.value?.validate(async (valid) => {
    if (valid) {
      const typeMap: any = { '1': 1, '2': 2, '3': 3 };
      const statusMap: any = { '未开始': 0, '进行中': 1, '已结束': 2 };
      const payload = {
        promotion_id: dialogForm.promotion_id,
        store_id: dialogForm.store_id || 0,
        promotion_name: dialogForm.name,
        type: typeMap[dialogForm.type] ?? '',
        start_time: dayjs(dialogForm.startTime).format('YYYY-MM-DDTHH:mm:ss'),
        end_time: dayjs(dialogForm.endTime).format('YYYY-MM-DDTHH:mm:ss'),
        rule: '',
        applicable_scope: dialogForm.scope,
        status: statusMap[dialogForm.status] ?? '',
        min_consumption: dialogForm.min_consumption ? parseFloat(dialogForm.min_consumption) : 0,
        value: dialogForm.value ? parseFloat(dialogForm.value) : 0,
      };
      let res:any;
      if (dialogForm.promotion_id) {
        res = await updatePromotion(payload);
        if (res.success) ElMessage.success('编辑成功');
      } else {
        res = await addPromotion(payload);
        if (res.success) ElMessage.success('新建成功');
      }
      dialogVisible.value = false;
      handleQuery();
    }
  });
};
const handleDelete = async (row: Promotion) => {
  ElMessageBox.confirm('确定要删除该活动吗？', '提示', { type: 'warning' })
    .then(async () => {
      const res:any = await deletePromotion(row.promotion_id);
      if (res.success) ElMessage.success('删除成功');
      handleQuery();
    });
};

// 查询门店列表
onMounted(() => {
  handleQuery();
  fetchStoreList();
});


async function fetchStoreList() {
  await getStoreList().then((res:any)=> {
    if (res && res.response) {
      var storedata = res.response.filter((item: any) => item.store_name !== '管理员');
      storeList.value = storedata.map((item: any) => ({
        id: item.store_id,
        name: item.store_name
      }));
    }
  });
}
</script>

<style scoped>
.promotion-list-container {
  padding: 24px;
   background: #fff;
 height: 100%;
}
.filter-card {
  margin-bottom: 18px;
  box-shadow: 0 2px 8px 0 rgba(0,0,0,0.04);
}
.filter-form {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
}
.table-card {
      background: #fff;
  border-radius: 8px;
  margin-bottom: 18px;
  /* box-shadow: 0 2px 8px 0 rgba(0,0,0,0.04); */
}
.pagination-bar {
  display: flex;
  justify-content: flex-end;
  padding: 16px 0 0 0;
}
.custom-table .table-btn-edit {
  color: #409eff;
}
.custom-table .table-btn-status {
  color: #fc0303;
}
</style>
