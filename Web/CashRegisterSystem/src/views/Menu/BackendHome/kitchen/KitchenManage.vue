<template>
  <div class="kitchen-manage-container">
    <!-- 筛选区 -->
    <el-form class="filter-bar" :inline="true">
      <!-- <el-form-item label="门店：">
        <el-select v-model="selectedStore" placeholder="请选择门店" style="min-width:140px;">
          <el-option value="">全部门店</el-option>
          <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
        </el-select>
      </el-form-item> -->
      <!-- <el-form-item label="厨房类型：">
        <el-select v-model="kitchenType" placeholder="全部类型" style="min-width:120px;">
          <el-option value="">全部</el-option>
        </el-select>
      </el-form-item> -->
      <el-form-item>
        <!-- <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button> -->
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增厨房</el-button>
      </el-form-item>
    </el-form>

    <!-- 厨房列表 -->
    <el-table :data="filteredKitchens" border style="width:100%;height: 67vh;" :header-cell-style="{ background: '#f8f9fa', color: '#606266' }" class="custom-table">
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column prop="kitchen_name" label="厨房名称" align="center"  width="120"/>
      <el-table-column prop="kitchen_type" label="厨房类型" align="center"  width="120"/>
      <!-- <el-table-column prop="store_id" label="所属门店" align="center">
        <template #default="scope">
          {{ getStoreName(scope.row.store_id) }}
        </template>
      </el-table-column> -->
      <el-table-column prop="kitchen_description" label="描述" align="center" />
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
        <!-- <el-form-item label="所属门店">
          <el-select v-model="form.store_id" placeholder="请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :label="store.name" :value="store.id" />
          </el-select>
        </el-form-item> -->
        <el-form-item label="厨房名称">
          <el-input v-model="form.kitchen_name" placeholder="请输入厨房名称" />
        </el-form-item>
        <el-form-item label="厨房类型">
            <el-input v-model="form.kitchen_type" placeholder="请输入厨房类型" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.kitchen_description" placeholder="可填写厨房说明" />
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
import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getKitchenList, addKitchen, updateKitchen, deleteKitchen } from '../../../../api/KitchenManage';

interface Kitchen {
  id: number;
  kitchen_name: string;
  kitchen_type: string;
  kitchen_description?: string;
}


const kitchenType = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('新增厨房');
const form = ref<Kitchen | any>({
  id: 0,
  kitchen_name: '',
  kitchen_type: '',
  kitchen_description: '',
});
const kitchenList = ref<Kitchen[]>([]);

const filteredKitchens = computed(() => {
  let result = kitchenList.value.filter(k => {
    const matchType = !kitchenType.value || k.kitchen_type === kitchenType.value;
    return  matchType;
  });
  total.value = result.length;
  const startIdx = (currentPage.value - 1) * pageSize.value;
  return result.slice(startIdx, startIdx + pageSize.value);
});



const fetchKitchenList = async () => {
    await getKitchenList(currentPage.value, pageSize.value)
    .then((res:any)=>{
      if (res.success) {
        kitchenList.value = res.response || [];
        total.value = res.count || 0;
      } else {
        ElMessage.error(res.message || '获取厨房列表失败');
      }
    }).catch(e=>{
      ElMessage.error('获取厨房列表失败'+e);
    });
}



const openAddDialog = () => {
  dialogTitle.value = '新增厨房';
  form.value = {
    id: 0,
    kitchen_name: '',
    kitchen_type: '',
    kitchen_description: '',
    store_id: ''
  };
  dialogVisible.value = true;
};

const openEditDialog = (row: Kitchen) => {
  dialogTitle.value = '编辑厨房';
  form.value = { ...row };
  dialogVisible.value = true;
};

const handleSave = async () => {
  if (!form.value.kitchen_name || !form.value.kitchen_type) {
    ElMessage.warning('请填写必填项');
    return;
  }
  try {
    if (form.value.id === 0) {
      // 新增
      const res:any = await addKitchen({
        kitchen_name: form.value.kitchen_name,
        kitchen_type: form.value.kitchen_type,
        kitchen_description: form.value.kitchen_description,
      });
      if (res.success) {
        ElMessage.success('新增成功');
        dialogVisible.value = false;
        fetchKitchenList();
      } else {
        ElMessage.error(res.message || '新增失败');
      }
    } else {
      // 编辑
      const res:any = await updateKitchen({
        id: form.value.id,
        kitchen_name: form.value.kitchen_name,
        kitchen_type: form.value.kitchen_type,
        kitchen_description: form.value.kitchen_description,
      });
      if (res.success) {
        ElMessage.success('修改成功');
        dialogVisible.value = false;
        fetchKitchenList();
      } else {
        ElMessage.error(res.message || '修改失败');
      }
    }
  } catch (e) {
    ElMessage.error('操作失败');
  }
};

const handleDelete = (row: Kitchen) => {
  ElMessageBox.confirm('确定要删除该厨房吗？', '提示', { type: 'warning' })
    .then(async () => {
      try {
        const res:any = await deleteKitchen(row.id);
        if (res.success) {
          ElMessage.success('删除成功');
          fetchKitchenList();
        } else {
          ElMessage.error(res.message || '删除失败');
        }
      } catch (e) {
        ElMessage.error('删除失败');
      }
    });
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchKitchenList();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  fetchKitchenList();
};

onMounted(() => {
  fetchKitchenList();
});
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
