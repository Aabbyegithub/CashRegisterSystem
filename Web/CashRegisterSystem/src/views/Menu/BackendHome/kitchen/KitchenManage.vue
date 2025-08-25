<template>
  <div class="kitchen-manage-container">
    <!-- 筛选区 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店：">
        <el-select v-model="selectedStore" placeholder="请选择门店" style="min-width:140px;">
          <el-option value="">全部门店</el-option>
          <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="厨房类型：">
        <el-select v-model="kitchenType" placeholder="全部类型" style="min-width:120px;">
          <el-option value="">全部</el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增厨房</el-button>
      </el-form-item>
    </el-form>

    <!-- 厨房列表 -->
    <el-table :data="filteredKitchens" border style="width:100%;height: 67vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="kitchen_name" label="厨房名称" align="center" />
      <el-table-column prop="kitchen_type" label="厨房类型" align="center" />
      <el-table-column prop="store_id" label="所属门店" align="center">
        <template #default="scope">
          {{ getStoreName(scope.row.store_id) }}
        </template>
      </el-table-column>
      <el-table-column prop="desc" label="描述" align="center" />
      <el-table-column label="操作" align="center" width="180">
        <template #default="scope">
          <el-button type="text" class="table-btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
          <el-button type="text" class="table-btn-status" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

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

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" width="500" :title="dialogTitle">
      <el-form :model="form" label-width="120px">
        <el-form-item label="所属门店">
          <el-select v-model="form.store_id" placeholder="请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="厨房名称">
          <el-input v-model="form.kitchen_name" placeholder="请输入厨房名称" />
        </el-form-item>
        <el-form-item label="厨房类型">
            <el-input v-model="form.kitchen_type" placeholder="请输入厨房类型" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.desc" placeholder="可填写厨房说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleSave" class="Btn-Save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { ElMessage } from 'element-plus';

interface Store { id: string; name: string; }
interface Kitchen {
  kitchen_id: number;
  kitchen_name: string;
  kitchen_type: string;
  store_id: string;
  desc?: string;
}

const storeList = ref<Store[]>([
  { id: '1', name: '旗舰店' },
  { id: '2', name: '分店A' }
]);
const selectedStore = ref('');
const kitchenType = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('新增厨房');
const form = ref<Kitchen | any>({
  kitchen_id: 0,
  kitchen_name: '',
  kitchen_type: '',
  store_id: '',
  desc: ''
});
const kitchenList = ref<Kitchen[]>([
  { kitchen_id: 1, kitchen_name: '热菜厨房', kitchen_type: '热菜', store_id: '1', desc: '主营热菜' },
  { kitchen_id: 2, kitchen_name: '凉菜厨房', kitchen_type: '凉菜', store_id: '1', desc: '主营凉菜' },
  { kitchen_id: 3, kitchen_name: '饮品厨房', kitchen_type: '饮品', store_id: '2', desc: '主营饮品' }
]);

const filteredKitchens = computed(() => {
  let result = kitchenList.value.filter(k => {
    const matchStore = !selectedStore.value || k.store_id === selectedStore.value;
    const matchType = !kitchenType.value || k.kitchen_type === kitchenType.value;
    return matchStore && matchType;
  });
  total.value = result.length;
  const startIdx = (currentPage.value - 1) * pageSize.value;
  return result.slice(startIdx, startIdx + pageSize.value);
});

const getStoreName = (id: string) => {
  const store = storeList.value.find(s => s.id === id);
  return store ? store.name : '-';
};

const handleQuery = () => {
  // 仅模拟筛选，实际可扩展为接口请求
};
const handleReset = () => {
  selectedStore.value = '';
  kitchenType.value = '';
  handleQuery();
};
const openAddDialog = () => {
  dialogTitle.value = '新增厨房';
  form.value = {
    kitchen_id: 0,
    kitchen_name: '',
    kitchen_type: '',
    store_id: '',
    desc: ''
  };
  dialogVisible.value = true;
};
const openEditDialog = (row: Kitchen) => {
  dialogTitle.value = '编辑厨房';
  form.value = { ...row };
  dialogVisible.value = true;
};
const handleSave = () => {
  if (!form.value.kitchen_name || !form.value.kitchen_type || !form.value.store_id) {
    ElMessage.warning('请填写必填项');
    return;
  }
  if (form.value.kitchen_id === 0) {
    form.value.kitchen_id = Date.now();
    kitchenList.value.push({ ...form.value });
    ElMessage.success('新增成功');
  } else {
    const idx = kitchenList.value.findIndex(k => k.kitchen_id === form.value.kitchen_id);
    if (idx !== -1) {
      kitchenList.value[idx] = { ...form.value };
      ElMessage.success('修改成功');
    }
  }
  dialogVisible.value = false;
};
const handleDelete = (row: Kitchen) => {
  const idx = kitchenList.value.findIndex(k => k.kitchen_id === row.kitchen_id);
  if (idx !== -1) {
    kitchenList.value.splice(idx, 1);
    ElMessage.success('删除成功');
  }
};
const handleSizeChange = (val: number) => {
  pageSize.value = val;
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
};
</script>

<style scoped>
.kitchen-manage-container {
  padding: 20px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
  margin-bottom: 18px;
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
.table-btn-edit {
  color: #67c23a !important;
  font-weight: 500;
  margin-right: 8px;
}
.table-btn-status {
  color: #f56c6c !important;
  font-weight: 500;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
  padding: 18px 24px 0 0;
  font-size: 15px;
}
</style>
