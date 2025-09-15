<template>
  <div class="set-meal-container">
    <!-- 筛选区域表单化 -->
    <el-form class="filter-bar" :inline="true">
      <el-form-item label="门店">
          <el-select v-model="selectedStore" class="store-select" placeholder="请选择门店"style="min-width: 120px;">
            <el-option value="">全部门店</el-option>
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
      </el-form-item>
      <el-form-item label="套餐名称：">
        <el-input v-model="mealName" placeholder="请输入套餐名称" class="filter-item" clearable />
      </el-form-item>
      <el-form-item label="状态：">
        <el-select v-model="status" placeholder="请选择状态" class="filter-item" style="min-width:120px;">
          <el-option value="" label="全部" />
          <el-option value="1" label="在售" />
          <el-option value="0" label="下架" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleReset" class="cancel-btn">重置</el-button>
        <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
        <el-button type="primary" @click="openAddDialog" class="Btn-Save">新增套餐</el-button>
      </el-form-item>
    </el-form>

    <!-- 套餐列表区域 -->
    <div class="meal-list">
      <el-table
        :data="mealList"
        border
        style="width: 100%; height: 65vh;"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="序号" align="center" width="60">
          <template #default="scope">
            {{ (currentPage - 1) * pageSize + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column label="门店名称" prop="store_id" align="center">
            <template #default="scope">
             {{ storeList.find(cat => cat.id === scope.row.store_id)?.name || '' }}
            </template>
        </el-table-column>
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
        <el-table-column prop="image_url" label="图片" align="center">
          <template #default="scope">
            <el-image
            v-if="scope.row.image_url"
            :src="scope.row.image_url"
            style="width:40px;height:40px;object-fit:cover;cursor:pointer"
            :preview-src-list="[scope.row.image_url]"
            fit="cover"
            :preview-teleported="true"
          />
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
        <el-form-item label="门店">
        <el-select v-model="form.store_id" placeholder="请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
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
        <el-form-item label="图片">
          <el-upload
            class="avatar-uploader"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <img v-if="form.image_url" :src="form.image_url" class="avatar" style="width: 80px; height: 80px; object-fit: cover;" />
            <u-icon v-else class="avatar-uploader-icon" name="plus" size="50"></u-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model.number="form.status">
            <el-radio :label="1">在售</el-radio>
            <el-radio :label="0">下架</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="生效时间">
          <el-date-picker
            v-model="form.start_time"
            type="datetime"
            placeholder="请选择生效时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="失效时间">
          <el-date-picker
            v-model="form.end_time"
            type="datetime"
            placeholder="请选择失效时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%;"
          />
        </el-form-item>
      </el-form>
      <!-- 新增/编辑套餐弹窗内，表单后面添加 -->
<div style="margin-top: 18px;">
  <div style="font-weight: bold; margin-bottom: 8px;">套餐菜品明细</div>
  <!-- 固定套餐 -->
  <template v-if="form.is_fixed === 1">
    <el-button type="primary" @click="openDialogItemEdit('add')" style="margin-bottom: 8px;">新增菜品</el-button>
    <el-table :data="form.items || []" border style="width:100%">
      <el-table-column prop="dish_id" label="菜品名称" align="center">
        <template #default="scope">
          {{ dishOptions.find(cat => cat.id === scope.row.dish_id)?.name || '' }}
        </template>
      </el-table-column>
      <el-table-column prop="spec_id" label="规格" align="center">
        <template #default="scope">
          {{ specOptions.find(cat => cat.id === scope.row.spec_id)?.name || '' }}
        </template>
      </el-table-column>
      <el-table-column prop="quantity" label="数量" align="center" />
      <el-table-column label="操作" align="center" width="120">
        <template #default="scope">
          <el-button type="text" @click="openDialogItemEdit('edit', scope.row, scope.$index)">编辑</el-button>
          <el-button type="text" style="color:#f56c6c" @click="removeDialogItem(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </template>
  <!-- 自定义组合 -->
  <template v-else>
    <div v-for="(group, idx) in form.groups || []" :key="group.groupName" style="margin-bottom: 24px;">
      <div style="display: flex; align-items: center;">
        <div style="font-weight: bold; margin-bottom: 8px;">{{ group.groupName }}</div>
        <div style="margin-left: auto; display: flex; gap: 8px;">
          <el-button type="danger" size="small" @click="removeGroup(idx)">删除分组</el-button>
          <el-button type="primary" size="small" style="background: #22A2B6;" @click="openDialogItemEdit('add', undefined, idx)">新增菜品</el-button>
        </div>
      </div>
      <el-table :data="group.items" border style="width:100%">
        <el-table-column prop="dish_id" label="菜品名称" align="center">
          <template #default="scope">
            {{ dishOptions.find(cat => cat.id === scope.row.dish_id)?.name || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="spec_id" label="规格" align="center">
          <template #default="scope">
            {{ specOptions.find(cat => cat.id === scope.row.spec_id)?.name || '' }}
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" align="center" />
        <el-table-column label="操作" align="center" width="120">
          <template #default="scope">
            <el-button type="text" @click="openDialogItemEdit('edit', scope.row, idx, scope.$index)">编辑</el-button>
            <el-button type="text" style="color:#f56c6c" @click="removeGroupItem(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    <div style="text-align:right;margin-top:12px;">
      <el-button type="primary" @click="openGroupDialog1">新增组合分组</el-button>
    </div>
  </template>
</div>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 菜品明细弹窗 -->
    <el-dialog v-model="itemDialogVisible" width="760" title="套餐包含菜品">
      <div v-if="currentMealIsFixed" style="margin-bottom: 12px; text-align: right;">
        <el-button type="primary" @click="openItemEditDialog('add')">新增菜品</el-button>
      </div>
      <template v-if="currentMealIsFixed">
        <el-table :data="itemList" border style="width:100%">
          <el-table-column prop="dish_id" label="菜品名称" align="center">
              <template #default="scope">
              {{ dishOptions.find(cat => cat.id === scope.row.dish_id)?.name || '' }}
              </template>
          </el-table-column>
          <el-table-column prop="spec_id" label="规格" align="center" >
              <template #default="scope">
              {{ specOptions.find(cat => cat.id === scope.row.spec_id)?.name || '' }}
              </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" align="center" />
          <el-table-column label="操作" align="center" width="160">
            <template #default="scope">
              <el-button type="text" style="color:#22A2B6" @click="openItemEditDialog('edit', scope.row)">编辑</el-button>
              <el-button type="text" style="color:#f56c6c" @click="handleItemDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </template>
      <template v-else>
        <div v-for="(group, idx) in customGroups" :key="group.groupName" style="margin-bottom: 24px;">
          <div style="display: flex; align-items: center;">
            <div style="font-weight: bold; margin-bottom: 8px;">{{ group.groupName }}</div>
            <div style="margin-left: auto; display: flex; gap: 8px;">
              <el-button type="danger" size="small" @click="deleteGroup(idx)">删除分组</el-button>
              <el-button type="primary" size="small" style="background: #22A2B6;" @click="openItemEditDialog('add', undefined, group.groupName)">新增菜品</el-button>
            </div>
          </div>
          <el-table :data="group.items" border style="width:100%">
            <el-table-column prop="dish_id" label="菜品名称" align="center" >
              <template #default="scope">
              {{ dishOptions.find(cat => cat.id === scope.row.dish_id)?.name || '' }}
              </template>
            </el-table-column>
            <el-table-column prop="spec_id" label="规格" align="center" >
              <template #default="scope">
              {{ specOptions.find(cat => cat.id === scope.row.spec_id)?.name || '' }}
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="数量" align="center" />
            <el-table-column label="操作" align="center" width="160">
              <template #default="scope">
                <el-button type="text" style="color:#22A2B6" @click="openItemEditDialog('edit', scope.row, group.groupName)">编辑</el-button>
                <el-button type="text" style="color:#f56c6c" @click="handleItemDelete(scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div style="text-align:right;margin-top:12px;">
          <el-button type="primary" @click="openGroupDialog">新增组合分组</el-button>
        </div>
      </template>
      <!-- 新增/编辑菜品弹窗（分组选择仅自定义组合时显示） -->
      <el-dialog v-model="itemEditDialogVisible" width="420" :title="itemEditDialogTitle">
        <el-form :model="itemForm" label-width="100px">
          <el-form-item label="菜品">
            <el-select v-model.number="itemForm.dish_id" placeholder="请选择菜品" style="width:100%" @change="fetchSpecOptions(itemForm.dish_id)">
              <el-option v-for="dish in dishOptions" :key="dish.id" :label="dish.name" :value="dish.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="规格">
            <el-select v-model.number="itemForm.spec_id" placeholder="请选择规格" style="width:100%">
              <el-option v-for="spec in specOptions" :key="spec.id" :label="spec.name" :value="spec.id" />
            </el-select>
          </el-form-item>
          <el-form-item label="数量">
            <el-input v-model.number="itemForm.quantity" type="number" placeholder="请输入数量" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="itemEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleItemSave">保存</el-button>
        </template>
      </el-dialog>
      <!-- 新增分组弹窗 -->
      <el-dialog v-model="groupDialogVisible" width="320" title="新增组合分组">
        <el-form :model="groupForm" label-width="80px">
          <el-form-item label="分组名">
            <el-input v-model="groupForm.groupName" placeholder="请输入分组名" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="groupDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleGroupSave">保存</el-button>
        </template>
      </el-dialog>
    </el-dialog>

    <el-dialog v-model="dialogItemEditVisible" width="420" :title="dialogItemEditTitle">
    <el-form :model="dialogItemForm" label-width="100px">
      <el-form-item label="菜品">
        <el-select v-model.number="dialogItemForm.dish_id" placeholder="请选择菜品" style="width:100%" @change="fetchSpecOptions(dialogItemForm.dish_id)">
          <el-option v-for="dish in dishOptions" :key="dish.id" :label="dish.name" :value="dish.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="规格">
        <el-select v-model.number="dialogItemForm.spec_id" placeholder="请选择规格" style="width:100%">
          <el-option v-for="spec in specOptions" :key="spec.id" :label="spec.name" :value="spec.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="数量">
        <el-input v-model.number="dialogItemForm.quantity" type="number" placeholder="请输入数量" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogItemEditVisible = false">取消</el-button>
      <el-button type="primary" @click="saveDialogItem">保存</el-button>
    </template>
  </el-dialog>

  <el-dialog v-model="dialogGroupVisible" width="320" title="新增组合分组">
  <el-form :model="dialogGroupForm" label-width="80px">
    <el-form-item label="分组名">
      <el-input v-model="dialogGroupForm.groupName" placeholder="请输入分组名" />
    </el-form-item>
  </el-form>
  <template #footer>
    <el-button @click="dialogGroupVisible= false">取消</el-button>
    <el-button type="primary" @click="saveGroupDialog">保存</el-button>
  </template>
</el-dialog>
      <!-- 菜品编辑弹窗 ...existing code... -->
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue';
import { dayjs, ElMessage } from 'element-plus';
import { getStoreList } from '../../../../api/login';
import {
  getMealList,
  getMealById,
  getMealItemList,
  addMeal,
  updateMeal,
  deleteMeal,
  saveMealItem,
  deleteMealItem,
  DeleteMealGroup
} from '../../../../api/setmeal';
import { getAllDishList } from '../../../../api/dish';
import { GetAllDishSpec, GetDishSpec } from '../../../../api/dishspec';
import config from '../../../../../public/config';
const uploadUrl = config.apiBaseUrl + '/api/Img/UpImg';

// 图片上传相关
function handleUploadSuccess(res: any) {
  if (res && res.response) {
    form.value.image_url = res.response;
    ElMessage.success('图片上传成功');
  } else {
    ElMessage.error('图片上传失败');
  }
}

function beforeUpload(file: File) {
  const isImage = file.type.startsWith('image/');
  if (!isImage) {
    ElMessage.error('只能上传图片文件');
  }
  return isImage;
}
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
  groupName?: string;
}

const mealName = ref('');
const status = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const mealList = ref<SetMeal[]>([]);
const storeList = ref<any[]>([]);
const dishOptions = ref<any[]>([]);
const specOptions = ref<any[]>([]);
const selectedStore = ref('');
const dialogVisible = ref(false);
const dialogTitle = ref('新增套餐');
const form = ref<SetMeal | any>({
  meal_id: 0,
  store_id: '',
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
const itemEditDialogVisible = ref(false);
const itemEditDialogTitle = ref('新增菜品');
const itemForm = ref<any>({
  item_id: '',
  meal_id: '',
  dish_id: '',
  spec_id: '',
  quantity: 1,
  groupName: ''
});
const groupDialogVisible = ref(false);
const groupForm = ref({ groupName: '' });
const customGroups = ref<{ groupName: string, items: SetMealItem[] }[]>([]);

const handleQuery = async () => {
  const res:any = await getMealList({
    pageIndex: currentPage.value,
    pageSize: pageSize.value,
    storeId: selectedStore.value,
    mealName: mealName.value,
    status: status.value
  });
  if (res && res.success) {
    mealList.value = res.response || [];
    mealList.value.forEach(meal => {
      meal.start_time = dayjs(meal.start_time).format('YYYY-MM-DD HH:mm:ss');
      meal.end_time = dayjs(meal.end_time).format('YYYY-MM-DD HH:mm:ss');
    });
    total.value = res.count || 0;
  }
};

const handleReset = () => {
  mealName.value = '';
  status.value = '';
  selectedStore.value = '';
  handleQuery();
};

const openAddDialog = () => {
  dialogTitle.value = '新增套餐';
  form.value = {
    meal_id: 0,
    store_id: '',
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

const openEditDialog = async (row: SetMeal) => {
  dialogTitle.value = '编辑套餐';
  // 获取套餐详情
  const res:any = await getMealById(row.meal_id);
  if (res && res.success) {
    form.value = res.response
    form.value.start_time = dayjs(form.value.start_time).format('YYYY-MM-DD HH:mm:ss');
    form.value.end_time = dayjs(form.value.end_time).format('YYYY-MM-DD HH:mm:ss');
    form.value.items = res.response.item || [];
    form.value.groups = res.response.item || [];
    if (form.value.is_fixed !== 1) {
    // 构建分组结构（后端字段 meal_group）
    const groupMap: Record<string, SetMealItem[]> = {};
    form.value.groups.forEach((item:any) => {
      const groupName = item.meal_group || '组合' + (Object.keys(groupMap).length + 1);
      if (!groupMap[groupName]) groupMap[groupName] = [];
      groupMap[groupName].push(item);
    });
    form.value.groups = Object.entries(groupMap).map(([groupName, items]) => ({ groupName, items }));
  }
  } else {
    form.value = { ...row };
  }
  dialogVisible.value = true;
};

const handleSave = async () => {
  if (!form.value.store_id || !form.value.meal_name || !form.value.price || !form.value.start_time || !form.value.end_time) {
    ElMessage.warning('请填写必填项');
    return;
  }
  let res:any;
  if (!form.value.meal_id || form.value.meal_id === 0) {
    // 新增
    form.value.start_time = dayjs(form.value.start_time, 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DDTHH:mm:ss');
    form.value.end_time = dayjs(form.value.end_time, 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DDTHH:mm:ss');
    if (form.value.is_fixed === 1) {
      form.value.meal_item = form.value.items || [];
    console.log(form.value.meal_item);
      form.value.groups = [];
    } else {
      form.value.meal_item = form.value.groups.flatMap((group:any) =>
        group.items.map((item:any) => ({
            dish_id: item.dish_id,
            spec_id: item.spec_id || 0,
            quantity: item.quantity,
            meal_group: group.groupName || ''
        }))
    ) || [];
      form.value.items = [];
    }
    res = await addMeal(form.value);

    if (res?.success) ElMessage.success('新增成功');
  } else {
    // 编辑
    form.value.start_time = dayjs(form.value.start_time, 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DDTHH:mm:ss');
    form.value.end_time = dayjs(form.value.end_time, 'YYYY-MM-DD HH:mm:ss').format('YYYY-MM-DDTHH:mm:ss');
    if (form.value.is_fixed === 1) {
      form.value.meal_item = form.value.items || [];
      form.value.groups = [];
    } else {
      form.value.meal_item = form.value.groups || [];
      form.value.items = [];
    }
    res = await updateMeal(form.value);
    if (res?.success) ElMessage.success('修改成功');
  }
  dialogVisible.value = false;
  handleQuery();
};

const handleDelete = async (row: SetMeal) => {
  const res:any = await deleteMeal(row.meal_id);
  if (res?.success) {
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



const openItemDialog = async (row: SetMeal) => {
   fetchAllDishSpec()
  // 获取套餐菜品明细
  const res:any = await getMealItemList(row.meal_id);
  itemList.value = res?.response || [];
  itemDialogVisible.value = true;
  currentMealId.value = row.meal_id;
  currentMealIsFixed.value = row.is_fixed === 1;
  if (row.is_fixed !== 1) {
    // 构建分组结构（后端字段 meal_group）
    const groupMap: Record<string, SetMealItem[]> = {};
    itemList.value.forEach((item:any) => {
      const groupName = item.meal_group || '组合' + (Object.keys(groupMap).length + 1);
      if (!groupMap[groupName]) groupMap[groupName] = [];
      groupMap[groupName].push(item);
    });
    customGroups.value = Object.entries(groupMap).map(([groupName, items]) => ({ groupName, items }));
  }
};

const currentMealId = ref<number>(0);
const currentMealIsFixed = ref<boolean>(true);


const openItemEditDialog = (type: 'add' | 'edit', row?: SetMealItem, groupName?: string) => {
  itemEditDialogTitle.value = type === 'add' ? '新增菜品' : '编辑菜品';
  itemEditDialogVisible.value = true;
  if (type === 'edit' && row) {
    itemForm.value = { ...row, groupName };
  } else {
    itemForm.value = {
      item_id: 0,
      meal_id: currentMealId.value,
      dish_id: '',
      spec_id: '',
      quantity: 1,
      groupName: groupName || (customGroups.value[0]?.groupName || '')
    };
  }
};

const handleItemSave = async () => {
  if (!itemForm.value.dish_id || !itemForm.value.quantity) {
    ElMessage.warning('请填写必填项');
    return;
  }
  // meal_group 字段用于分组
  const payload = {
    ...itemForm.value,
    spec_id: itemForm.value.spec_id || null,
    meal_id: currentMealId.value,
    meal_group: itemForm.value.groupName
  };
  const res:any = await saveMealItem(payload);
  if (res?.success) {
    ElMessage.success(itemForm.value.item_id === 0 ? '新增成功' : '修改成功');
    // 刷新明细
    const mealRes:any = await getMealById(currentMealId.value);
    if (mealRes?.response) {
      openItemDialog(mealRes.response);
    }
  }
  itemEditDialogVisible.value = false;
};

const handleItemDelete = async (row: SetMealItem) => {
  const res:any = await deleteMealItem(row.item_id);
  if (res?.success) {
    ElMessage.success('删除成功');
    // 刷新明细
    const mealRes:any = await getMealById(currentMealId.value);
    if (mealRes?.response) {
      openItemDialog(mealRes.response);
    }
  }
};
const openGroupDialog = () => {
  groupForm.value.groupName = '';
  groupDialogVisible.value = true;
};

const handleGroupSave = () => {
  if (!groupForm.value.groupName) {
    ElMessage.warning('请输入分组名');
    return;
  }
  // 检查分组名重复
  if (customGroups.value.some(g => g.groupName === groupForm.value.groupName)) {
    ElMessage.warning('分组名已存在');
    return;
  }
  customGroups.value.push({ groupName: groupForm.value.groupName, items: [] });
  groupDialogVisible.value = false;
};

const deleteGroup = async (idx: number) => {
  const groupName = customGroups.value[idx].groupName;
  // 调用后端分组删除接口
  const res:any = await DeleteMealGroup({ MealId: currentMealId.value, GroupName: groupName });
  if (res?.success) {
    ElMessage.success('分组已删除');
    // 刷新分组和明细
    const mealRes:any = await getMealById(currentMealId.value);
    if (mealRes?.response) {
      openItemDialog(mealRes.response);
    }
  } else {
    ElMessage.error(res?.data?.message || '分组删除失败');
  }
};

// 用于套餐弹窗内新增/编辑菜品
const dialogItemEditVisible = ref(false);
const dialogItemEditTitle = ref('新增菜品');
const dialogItemForm = ref<any>({
  dish_id: '',
  spec_id: '',
  quantity: 1,
  groupName: ''
});
const dialogItemEditIndex = ref(-1);
const dialogItemEditGroupIdx = ref(-1);

// 打开新增/编辑菜品弹窗（套餐弹窗内）
function openDialogItemEdit(type: 'add' | 'edit', row?: any, groupOrIdx?: number, itemIdx?: number) {
  dialogItemEditTitle.value = type === 'add' ? '新增菜品' : '编辑菜品';
  dialogItemEditVisible.value = true;
  if (form.value.is_fixed === 1) {
    // 固定套餐
    if (type === 'edit' && row) {
      dialogItemForm.value = { ...row };
      dialogItemEditIndex.value = groupOrIdx ?? -1;
    } else {
      dialogItemForm.value = { dish_id: '', spec_id: '', quantity: 1 };
      dialogItemEditIndex.value = -1;
    }
    dialogItemEditGroupIdx.value = -1;
  } else {
    // 自定义组合
    if (type === 'edit' && row !== undefined && groupOrIdx !== undefined && itemIdx !== undefined) {
      dialogItemForm.value = { ...row };
      dialogItemEditGroupIdx.value = groupOrIdx;
      dialogItemEditIndex.value = itemIdx;
    } else {
      dialogItemForm.value = { dish_id: '', spec_id: '', quantity: 1 };
      dialogItemEditGroupIdx.value = groupOrIdx ?? -1;
      dialogItemEditIndex.value = -1;
    }
  }
}

// 保存菜品（套餐弹窗内）
function saveDialogItem() {
  if (!dialogItemForm.value.dish_id || !dialogItemForm.value.quantity) {
    ElMessage.warning('请填写必填项');
    return;
  }
  if (form.value.is_fixed === 1) {
    if (!form.value.items) form.value.items = [];
    if (dialogItemEditIndex.value === -1) {
      form.value.items.push({ ...dialogItemForm.value });
    } else {
      form.value.items.splice(dialogItemEditIndex.value, 1, { ...dialogItemForm.value });
    }
  } else {
    if (!form.value.groups) form.value.groups = [];
    const groupIdx = dialogItemEditGroupIdx.value;
    if (groupIdx === -1) {
      ElMessage.warning('未指定分组');
      return;
    }
    if (!form.value.groups[groupIdx].items) form.value.groups[groupIdx].items = [];
    if (dialogItemEditIndex.value === -1) {
      form.value.groups[groupIdx].items.push({ ...dialogItemForm.value });
    } else {
      form.value.groups[groupIdx].items.splice(dialogItemEditIndex.value, 1, { ...dialogItemForm.value });
    }
  }
  dialogItemEditVisible.value = false;
}

// 删除菜品（套餐弹窗内，固定套餐）
async function removeDialogItem(row: any) {
  const res:any = await deleteMealItem(row.item_id);
  if (res?.success) {
    ElMessage.success('删除成功');
    // 刷新明细
    const mealRes:any = await getMealById(currentMealId.value);
    if (mealRes?.response) {
      openItemDialog(mealRes.response);
    }
  }
}

// 删除分组（套餐弹窗内，自定义组合）
function removeGroup(idx: number) {
  form.value.groups.splice(idx, 1);
}

// 删除分组内菜品（套餐弹窗内，自定义组合）
async function removeGroupItem(row: any) {
  const res:any = await deleteMealItem(row.item_id);
  if (res?.success) {
    ElMessage.success('删除成功');
    // 刷新明细
    const mealRes:any = await getMealById(currentMealId.value);
    if (mealRes?.response) {
      openItemDialog(mealRes.response);
    }
  }
}

const dialogGroupVisible = ref(false);
const dialogGroupForm = ref({ groupName: '' });

// 打开套餐弹窗内分组新增弹窗
function openGroupDialog1() {
  console.log('openGroupDialog1');
  dialogGroupForm.value.groupName = '';
  dialogGroupVisible.value = true;
}

// 保存套餐弹窗内分组
function saveGroupDialog() {
  if (!dialogGroupForm.value.groupName) {
    ElMessage.warning('请输入分组名');
    return;
  }
  if (!form.value.groups) form.value.groups = [];
  if (form.value.groups.some((g:any) => g.groupName === dialogGroupForm.value.groupName)) {
    ElMessage.warning('分组名已存在');
    return;
  }
  form.value.groups.push({ groupName: dialogGroupForm.value.groupName, items: [] });
  dialogGroupVisible.value = false;
}

onMounted(() => {
  handleQuery();
  fetchStoreList()
  fetchDishList()
  fetchAllDishSpec()
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
async function fetchAllDishSpec() {
  await GetAllDishSpec().then((res:any)=> {
    if (res && res.response) {
      specOptions.value = res.response.map((item: any) => ({
        id: item.spec_id,
        name: item.spec_name
      }));
    }
  });
}
async function fetchDishList() {
  await getAllDishList().then((res:any)=> {
    if (res && res.response) {
      dishOptions.value = res.response.map((item: any) => ({
        id: item.dish_id,
        name: item.dish_name
      }));
    }
  });
}

const fetchSpecOptions = async (dishId: number) => {
  await GetDishSpec(dishId).then((res:any)=> {
    if (res && res.response) {
      specOptions.value = res.response.map((item: any) => ({
        id: item.spec_id,
        name: item.spec_name
      }));
    }
  });
};

</script>

<style scoped>
.set-meal-container {
  padding: 20px;
  background: #fff;
  min-height: 100%;
}
.filter-bar {
  margin-bottom: 18px;
}
.cancel-btn {
  margin-right: 8px;
}
.Btn-Save {
  background: #22A2B6;
  color: #fff;
}
.meal-list {
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

.avatar-uploader {
  display: flex;
  align-items: center;
}
.avatar-uploader .avatar {
  width: 80px;
  height: 80px;
  display: block;
  border-radius: 6px;
  object-fit: cover;
}
.avatar-uploader-icon {
  font-size: 32px;
  color: #8c939d;
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
}
</style>
