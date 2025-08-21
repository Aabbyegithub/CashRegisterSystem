<template>
  <div class="set-meal-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <label>套餐名称：</label>
      <el-input v-model="mealName" placeholder="请输入套餐名称" class="filter-item" clearable />
      <label style="margin-left:16px;">状态：</label>
      <el-select v-model="status" placeholder="请选择状态" class="filter-item" style="min-width:120px;">
        <el-option value="" label="全部" />
        <el-option value="1" label="在售" />
        <el-option value="0" label="下架" />
      </el-select>
      <el-button @click="handleReset" style="margin-left: auto;">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
      <el-button type="primary" @click="openAddDialog">新增套餐</el-button>
    </div>

    <!-- 套餐列表区域 -->
    <div class="meal-list">
      <el-table
        :data="mealList"
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
        <el-table-column prop="store_id" label="门店ID" align="center" />
        <el-table-column prop="meal_name" label="套餐名称" align="center" />
        <el-table-column prop="price" label="售价" align="center">
          <template #default="scope">
            <span :style="{ color: scope.row.price > scope.row.original_price ? '#FF4D4F' : '' }">{{ scope.row.price.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="original_price" label="原价" align="center" />
        <el-table-column prop="is_fixed" label="类型" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_fixed === 1 ? 'success' : 'info'">
              {{ scope.row.is_fixed === 1 ? '固定套餐' : '自定义组合' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
              {{ scope.row.status === 1 ? '在售' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="start_time" label="生效时间" align="center" />
        <el-table-column prop="end_time" label="失效时间" align="center" />
        <el-table-column label="操作" align="center" width="180">
          <template #default="scope">
            <el-button type="text" style="color: #22A2B6;" @click="openItemDialog(scope.row)">菜品明细</el-button>
            <el-button type="text" style="color: #67c23a;" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.row)">删除</el-button>
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
        :page-sizes="[10, 20, 30, 40, 50]"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>

    <!-- 新增/编辑套餐弹窗 -->
    <el-dialog v-model="dialogVisible" width="600" :title="dialogTitle">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店ID">
          <el-input v-model.number="form.store_id" placeholder="请输入门店ID" />
        </el-form-item>
        <el-form-item label="套餐名称">
          <el-input v-model="form.meal_name" placeholder="如双人套餐" />
        </el-form-item>
        <el-form-item label="售价">
          <el-input v-model.number="form.price" type="number" placeholder="如99.00" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input v-model.number="form.original_price" type="number" placeholder="如128.00" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="套餐描述" />
        </el-form-item>
        <el-form-item label="类型">
          <el-radio-group v-model.number="form.is_fixed">
            <el-radio :label="1">固定套餐</el-radio>
            <el-radio :label="0">自定义组合</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model.number="form.status">
            <el-radio :label="1">在售</el-radio>
            <el-radio :label="0">下架</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="生效时间">
          <el-input v-model="form.start_time" placeholder="2025-08-22 00:00:00" />
        </el-form-item>
        <el-form-item label="失效时间">
          <el-input v-model="form.end_time" placeholder="2025-08-31 23:59:59" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 菜品明细弹窗 -->
    <el-dialog v-model="itemDialogVisible" width="700" title="套餐包含菜品">
      <el-table :data="itemList" border style="width:100%">
        <el-table-column prop="dish_id" label="菜品ID" align="center" />
        <el-table-column prop="spec_id" label="规格ID" align="center" />
        <el-table-column prop="quantity" label="数量" align="center" />
        <el-table-column prop="is_replaceable" label="可替换" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_replaceable === 1 ? 'success' : 'info'">
              {{ scope.row.is_replaceable === 1 ? '可替换' : '不可替换' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="replaceable_dishes" label="可替换菜品ID" align="center" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue';
import { ElMessage } from 'element-plus';

interface SetMeal {
  meal_id: number;
  store_id: number;
  meal_name: string;
  price: number;
  original_price: number;
  description?: string;
  is_fixed: number;
  status: number;
  start_time: string;
  end_time: string;
}
interface SetMealItem {
  item_id: number;
  meal_id: number;
  dish_id: number;
  spec_id?: number;
  quantity: number;
  is_replaceable: number;
  replaceable_dishes?: string;
}

const mealName = ref('');
const status = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const mealList = ref<SetMeal[]>([]);

const dialogVisible = ref(false);
const dialogTitle = ref('新增套餐');
const form = ref<SetMeal | any>({
  meal_id: 0,
  store_id: 0,
  meal_name: '',
  price: 0.00,
  original_price: 0.00,
  description: '',
  is_fixed: 1,
  status: 1,
  start_time: '',
  end_time: ''
});

const itemDialogVisible = ref(false);
const itemList = ref<SetMealItem[]>([]);

const handleQuery = () => {
  // 模拟数据筛选
  mealList.value = mockMeals.filter(meal => {
    return (
      (!mealName.value || meal.meal_name.includes(mealName.value)) &&
      (status.value === '' || meal.status === Number(status.value))
    );
  });
  total.value = mealList.value.length;
};

const handleReset = () => {
  mealName.value = '';
  status.value = '';
  handleQuery();
};

const openAddDialog = () => {
  dialogTitle.value = '新增套餐';
  form.value = {
    meal_id: 0,
    store_id: 0,
    meal_name: '',
    price: 0.00,
    original_price: 0.00,
    description: '',
    is_fixed: 1,
    status: 1,
    start_time: '',
    end_time: ''
  };
  dialogVisible.value = true;
};

const openEditDialog = (row: SetMeal) => {
  dialogTitle.value = '编辑套餐';
  form.value = { ...row };
  dialogVisible.value = true;
};

const handleSave = () => {
  if (!form.value.store_id || !form.value.meal_name || !form.value.price || !form.value.start_time || !form.value.end_time) {
    ElMessage.warning('请填写必填项');
    return;
  }
  if (form.value.meal_id === 0) {
    // 新增
    form.value.meal_id = Date.now();
    mockMeals.push({ ...form.value });
    ElMessage.success('新增成功');
  } else {
    // 编辑
    const idx = mockMeals.findIndex(m => m.meal_id === form.value.meal_id);
    if (idx !== -1) {
      mockMeals[idx] = { ...form.value };
      ElMessage.success('修改成功');
    }
  }
  dialogVisible.value = false;
  handleQuery();
};

const handleDelete = (row: SetMeal) => {
  const idx = mockMeals.findIndex(m => m.meal_id === row.meal_id);
  if (idx !== -1) {
    mockMeals.splice(idx, 1);
    ElMessage.success('删除成功');
    handleQuery();
  }
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  handleQuery();
};
const handlePageChange = (val: number) => {
  currentPage.value = val;
  handleQuery();
};

const openItemDialog = (row: SetMeal) => {
  itemList.value = mockMealItems.filter(item => item.meal_id === row.meal_id);
  itemDialogVisible.value = true;
};

// 模拟数据
const mockMeals: SetMeal[] = [
  { meal_id: 1, store_id: 1, meal_name: '双人套餐', price: 99.00, original_price: 128.00, description: '适合两人用餐', is_fixed: 1, status: 1, start_time: '2025-08-22 00:00:00', end_time: '2025-08-31 23:59:59' },
  { meal_id: 2, store_id: 1, meal_name: '家庭套餐', price: 188.00, original_price: 228.00, description: '适合家庭聚餐', is_fixed: 0, status: 1, start_time: '2025-08-22 00:00:00', end_time: '2025-08-31 23:59:59' }
];
const mockMealItems: SetMealItem[] = [
  { item_id: 1, meal_id: 1, dish_id: 101, spec_id: 1, quantity: 1, is_replaceable: 0, replaceable_dishes: '' },
  { item_id: 2, meal_id: 1, dish_id: 102, spec_id: 2, quantity: 2, is_replaceable: 1, replaceable_dishes: '103,104' },
  { item_id: 3, meal_id: 2, dish_id: 105, spec_id: 3, quantity: 1, is_replaceable: 0, replaceable_dishes: '' },
  { item_id: 4, meal_id: 2, dish_id: 106, spec_id: 4, quantity: 1, is_replaceable: 1, replaceable_dishes: '107' }
];

// 初始化
handleQuery();
</script>

<style scoped>
.set-meal-container {
  padding: 20px;
  background-color: #F5F7FA;
  min-height: 100%;
}
.filter-bar {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 18px;
}
.filter-item {
  min-width: 140px;
}
.meal-list {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 18px;
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
