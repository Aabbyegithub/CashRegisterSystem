<template>
  <div class="dish-spec-container">
    <!-- 筛选区域 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="菜品">
          <el-select v-model="selecteddish" class="store-select" placeholder="请选择菜品"style="min-width: 120px;">
            <el-option value="">全部菜品</el-option>
            <el-option v-for="dish in dishList" :key="dish.id" :value="dish.name">{{ dish.name }}</el-option>
          </el-select>
      </el-form-item>
      <el-form-item label="规格名称：">
        <el-input v-model="specName" placeholder="请输入规格名称" clearable style="min-width:140px;" />
      </el-form-item>
      <el-form-item label="规格类型：">
        <el-select v-model="specType" placeholder="请选择规格类型" style="min-width:200px;">
          <el-option value="" label="全部类型" />
          <el-option value="分量" label="分量" />
          <el-option value="辣度" label="辣度" />
          <el-option value="做法" label="做法" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增</el-button>
      </el-form-item>
    </el-form>

    <!-- 规格列表区域 -->
    <div class="spec-list">
      <el-table
        :data="specList"
        border
        style="width: 100%;height: 65vh;"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="序号" align="center" width="60">
          <template #default="scope">
            {{ (currentPage - 1) * pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column prop="dish_id" label="菜品名称" align="center">
          <template #default="scope">
            <span>
              {{
                dishList.find((dish) => dish.id === scope.row.dish_id)
                  ?.name || '未知菜品'
              }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="spec_type" label="规格类型" align="center" />
        <el-table-column prop="spec_name" label="规格名称" align="center" />
        <el-table-column prop="price_diff" label="价格" align="center">
          <template #default="scope">
            <span :style="{ color: scope.row.price_diff > 0 ? '#FF4D4F' : '' }">{{ scope.row.price_diff.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="sort_order" label="排序序号" align="center" />
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
        :page-sizes="[10, 20, 30, 40, 50]"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
      />
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" width="500" :title="dialogTitle">
      <el-form :model="form" label-width="120px">
        <el-form-item label="菜品名称">
          <el-select v-model="form.dish_id" placeholder="请选择菜品">
            <el-option v-for="dish in dishList" :key="dish.id" :label="dish.name" :value="dish.id" />
          </el-select> 
        </el-form-item>
        <el-form-item label="规格类型">
          <el-select v-model="form.spec_type" placeholder="请选择类型">
            <el-option value="分量" label="分量" />
            <el-option value="辣度" label="辣度" />
            <el-option value="做法" label="做法" />
          </el-select>
        </el-form-item>
        <el-form-item label="规格名称">
          <el-input v-model="form.spec_name" placeholder="如大份/中份/小份" />
        </el-form-item>
        <el-form-item label="价格">
          <el-input v-model.number="form.price_diff" type="number" placeholder="如0.00" />
        </el-form-item>
        <el-form-item label="排序序号">
          <el-input v-model.number="form.sort_order" type="number" placeholder="如0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue';
import { getSpecList, getSpecById, addSpec, updateSpec, deleteSpec } from '../../../../api/dishspec';
import { ElMessage } from 'element-plus';
import { getAllDishList } from '../../../../api/dish';

interface Spec {
  spec_id: number;
  dish_id: number;
  spec_name: string;
  spec_type: string;
  price_diff: number;
  sort_order: number;
}

const specName = ref('');
const specType = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const specList = ref<Spec[]>([]);
const selecteddish = ref('');
const dishList = ref<any[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('新增规格');
const form = ref<Spec | any>({
  spec_id: 0,
  dish_id: '',
  spec_name: '',
  spec_type: '',
  price_diff: 0.00,
  sort_order: 0
});

const handleQuery = async () => {
  const params = {
    pageIndex: currentPage.value,
    pageSize: pageSize.value,
    dishId: selecteddish.value || undefined,
    specName: specName.value,
    specType: specType.value
  };
  const res:any = await getSpecList(params);
  if (res?.success) {
    specList.value = res.response || [];
    total.value = res.count || 0;
  } else {
    specList.value = [];
    total.value = 0;
  }
};

const handleReset = () => {
  specName.value = '';
  specType.value = '';
  handleQuery();
};

const openAddDialog = () => {
  dialogTitle.value = '新增规格';
  form.value = {
    spec_id: 0,
    dish_id: '',
    spec_name: '',
    spec_type: '',
    price_diff: 0.00,
    sort_order: 0
  };
  dialogVisible.value = true;
};

const openEditDialog = async (row: Spec) => {
  dialogTitle.value = '编辑规格';
  const res:any = await getSpecById(row.spec_id);
  if (res?.success) {
    form.value = res.response;
  } else {
    form.value = { ...row };
  }
  dialogVisible.value = true;
};

const handleSave = async () => {
  if (!form.value.dish_id || !form.value.spec_name || !form.value.spec_type) {
    ElMessage.warning('请填写必填项');
    return;
  }
  let res:any;
  if (!form.value.spec_id || form.value.spec_id === 0) {
    // 新增
    res = await addSpec(form.value);
    if (res?.success) ElMessage.success('新增成功');
  } else {
    // 编辑
    res = await updateSpec(form.value);
    if (res?.success) ElMessage.success('修改成功');
  }
  dialogVisible.value = false;
  handleQuery();
};

const handleDelete = async (row: Spec) => {
  const res:any = await deleteSpec(row.spec_id);
  if (res?.success) {
    ElMessage.success('删除成功');
    handleQuery();
  } else {
    ElMessage.error(res?.message || '删除失败');
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
onMounted(() => {
  handleQuery();
  fetchDishList();
});
async function fetchDishList() {
  await getAllDishList().then((res:any)=> {
    if (res && res.response) {
      dishList.value = res.response.map((item: any) => ({
        id: item.dish_id,
        name: item.dish_name
      }));
    }
  });
}
</script>

<style scoped>
.dish-spec-container {
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
.spec-list {
  background: #fff;
  border-radius: 8px;
  /* box-shadow: 0 2px 8px rgba(0,0,0,0.08); */
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
