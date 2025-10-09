<template>
  <div class="dish-category-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <label>分类名称：</label>
      <el-input v-model="categoryName" placeholder="请输入分类名称" class="filter-item" clearable />
      <el-button @click="handleReset" style="margin-left: auto;">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
      <el-button type="primary" @click="openAddDialog">新增</el-button>
    </div>

    <!-- 分类列表区域 -->
    <div class="category-list">
      <el-table
        :data="categoryList"
        border
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="序号" align="center" width="60">
          <template #default="scope">
            {{ (currentPage - 1) * pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column
          prop="store_id"
          label="门店名称"
          align="center"
        >
          <template #default="scope">
            {{ storeList.find(store => store.id === scope.row.store_id)?.name || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="category_name" label="分类名称" align="center" />
        <el-table-column prop="sort_order" label="排序" align="center" />
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="180">
          <template #default="scope">
            <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.row)">删除</el-button>
            <el-button type="text" style="color: #67c23a;" @click="openEditDialog(scope.row)">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 分页区域 -->
    <div class="pagination-bar">
      <el-pagination
        layout="prev, pager, next, ->, sizes, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="currentPage"
        :prev-text="'<'"
        :next-text="'>'"
        :page-sizes="[10, 20, 30, 40, 50]"
        :display-page-count="5"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>

    <!-- 新增弹窗 -->
    <el-dialog v-model="addDialogVisible" width="400" title="新增分类">
      <el-form :model="form" label-width="100px">
        <el-form-item label="门店">
          <el-select v-model="form.store_id" placeholder="门店特色必须选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="分类名称">
          <el-input v-model="form.category_name" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input v-model.number="form.sort_order" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleAdd">确认新增</el-button>
      </template>
    </el-dialog>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="editDialogVisible" width="400" title="编辑分类">
      <el-form :model="form" label-width="100px">
        <el-form-item label="门店">
          <el-select v-model="form.store_id" placeholder="门店特色必须选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="分类名称">
          <el-input v-model="form.category_name" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input v-model.number="form.sort_order" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleEditConfirm">确认编辑</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { getDishCategoryList, addDishCategory, updateDishCategory, deleteDishCategory } from '../../../../api/dishcategory';
import { getStoreList } from '../../../../api/login';

const categoryName = ref('');
const categoryList = ref<any[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const addDialogVisible = ref(false);
const editDialogVisible = ref(false);
const storeList = ref<any[]>([]); 
const form = ref({
  category_id: 0,
  store_id: null,
  category_name: '',
  sort_order: 0,
  status: 1
});

const getCategoryList = async () => {
   await getDishCategoryList(categoryName.value,currentPage.value, pageSize.value).then((res: any) => {
    if (res && res.response) {
      categoryList.value = res.response;
      total.value = res.count;
    }});
};

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

onMounted(() => {
  getCategoryList();
  fetchStoreList()
});

const handleQuery = () => {
  currentPage.value = 1;
  getCategoryList();
};

const handleReset = () => {
  categoryName.value = '';
  handleQuery();
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  getCategoryList();
};

const handlePageChange = (val: number) => {
  currentPage.value = val;
  getCategoryList();
};

const openAddDialog = () => {
  form.value = {
    category_id: 0,
    store_id: null,
    category_name: '',
    sort_order: 0,
    status: 1
  };
  addDialogVisible.value = true;
};

const handleAdd = async () => {
  await addDishCategory(form.value);
  ElMessage.success('新增成功');
  addDialogVisible.value = false;
  getCategoryList();
};

const openEditDialog = (row: any) => {
  form.value = { ...row };
  editDialogVisible.value = true;
};

const handleEditConfirm = async () => {
  await updateDishCategory(form.value);
  ElMessage.success('编辑成功');
  editDialogVisible.value = false;
  getCategoryList();
};

const handleDelete = async (row: any) => {
  await deleteDishCategory([row.category_id]);
  ElMessage.success('删除成功');
  getCategoryList();
};
</script>

<style scoped>
.dish-category-container {
  padding: 20px;
  height: calc(100vh - 140px);
}
.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}
.filter-item {
  margin-right: 20px;
  width: 180px;
}
.category-list {
  margin-bottom: 20px;
  height: 83%;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.Btn-Save{
  align-self: flex-start;
  width: 20%;
  background-color: #22a2b6;
  border-color: #22a2b6;
  height: 40px;
}
.cancel-btn {
  align-self: flex-start;
  width: 20%;
  background-color: #fff;
  border-color: #6b5d5d;
  color: #000;
  margin-left: 25%;
  height: 40px;
}
</style>
