<template>
  <div class="promotion-list-container">
    <!-- 筛选区 -->
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="活动名称">
          <el-input v-model="filterForm.name" placeholder="请输入活动名称" clearable />
        </el-form-item>
        <el-form-item label="活动类型">
          <el-select v-model="filterForm.type" placeholder="请选择类型" clearable style="width: 150px;">
            <el-option label="全部" value="" />
            <el-option label="满减" value="满减" />
            <el-option label="折扣" value="折扣" />
            <el-option label="赠品" value="赠品" />
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
      <el-table :data="promotionList" border stripe style="width: 100%;height: 67vh;">
        <el-table-column prop="name" label="活动名称" min-width="120"  align="center"/>
        <el-table-column prop="type" label="类型" min-width="100"  align="center"/>
        <el-table-column prop="startTime" label="开始时间" min-width="160"  align="center"/>
        <el-table-column prop="endTime" label="结束时间" min-width="160"  align="center"/>
        <el-table-column prop="scope" label="适用范围" min-width="120"  align="center"/>
        <el-table-column prop="status" label="状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="statusTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="180" align="center">
          <template #default="scope">
            <el-button type="primary" size="small" @click="openDialog('edit', scope.row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(scope.row)">删除</el-button>
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
        <el-form-item label="活动名称" prop="name">
          <el-input v-model="dialogForm.name" placeholder="请输入活动名称" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="dialogForm.type" placeholder="请选择类型">
            <el-option label="满减" value="满减" />
            <el-option label="折扣" value="折扣" />
            <el-option label="赠品" value="赠品" />
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
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';

// 筛选表单
const filterForm = reactive({
  name: '',
  type: '',
  status: '',
});

// 促销活动列表模拟数据
interface Promotion {
  id: number;
  name: string;
  type: string;
  startTime: string;
  endTime: string;
  scope: string;
  status: string;
}
const promotionList = ref<Promotion[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);

// 弹窗相关
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogFormRef = ref<FormInstance>();
const dialogForm = reactive({
  id: 0,
  name: '',
  type: '',
  startTime: '',
  endTime: '',
  scope: '',
  status: '',
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
const statusTagType = (status: string) => {
  switch (status) {
    case '未开始': return 'info';
    case '进行中': return 'success';
    case '已结束': return 'warning';
    default: return '';
  }
};

// 查询、重置
const handleQuery = () => {
  // 模拟筛选
  let list = mockPromotions.filter(p => {
    return (
      (!filterForm.name || p.name.includes(filterForm.name)) &&
      (!filterForm.type || p.type === filterForm.type) &&
      (!filterForm.status || p.status === filterForm.status)
    );
  });
  total.value = list.length;
  promotionList.value = list.slice((currentPage.value-1)*pageSize.value, currentPage.value*pageSize.value);
};
const handleReset = () => {
  filterForm.name = '';
  filterForm.type = '';
  filterForm.status = '';
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
    Object.assign(dialogForm, row);
  } else {
    Object.assign(dialogForm, {
      id: 0,
      name: '',
      type: '',
      startTime: '',
      endTime: '',
      scope: '',
      status: '',
    });
  }
};
const handleDialogConfirm = () => {
  dialogFormRef.value?.validate((valid) => {
    if (valid) {
      if (dialogForm.id) {
        // 编辑
        const idx = mockPromotions.findIndex(p => p.id === dialogForm.id);
        if (idx > -1) Object.assign(mockPromotions[idx], { ...dialogForm });
        ElMessage.success('编辑成功');
      } else {
        // 新建
        dialogForm.id = Date.now();
        mockPromotions.unshift({ ...dialogForm });
        ElMessage.success('新建成功');
      }
      dialogVisible.value = false;
      handleQuery();
    }
  });
};
const handleDelete = (row: Promotion) => {
  ElMessageBox.confirm('确定要删除该活动吗？', '提示', { type: 'warning' })
    .then(() => {
      const idx = mockPromotions.findIndex(p => p.id === row.id);
      if (idx > -1) mockPromotions.splice(idx, 1);
      ElMessage.success('删除成功');
      handleQuery();
    });
};

// 模拟数据
const mockPromotions: Promotion[] = [
  {
    id: 1,
    name: '满100减20活动',
    type: '满减',
    startTime: '2025-08-01',
    endTime: '2025-08-31',
    scope: '全场商品',
    status: '进行中',
  },
  {
    id: 2,
    name: '8折限时折扣',
    type: '折扣',
    startTime: '2025-09-01',
    endTime: '2025-09-15',
    scope: '指定菜品',
    status: '未开始',
  },
  {
    id: 3,
    name: '赠品活动',
    type: '赠品',
    startTime: '2025-07-01',
    endTime: '2025-07-31',
    scope: '部分商品',
    status: '已结束',
  },
];

onMounted(() => {
  handleQuery();
});
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
</style>
