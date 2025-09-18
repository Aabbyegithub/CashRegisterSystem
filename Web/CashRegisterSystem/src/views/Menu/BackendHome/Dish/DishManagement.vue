<template>
  <div class="dish-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <label>菜品名称：</label>
      <el-input v-model="dishName" placeholder="请输入菜品名称" class="filter-item" clearable />
      <label>菜品分类：</label>
      <el-select v-model="selectedType" placeholder="请选择菜品分类" class="filter-item" clearable>
        <el-option v-for="store in dishcatageList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
      </el-select>
      <el-button @click="handleReset" style="margin-left: auto;">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
      <el-button type="primary" @click="openAddDialog">新增</el-button>
    </div>

    <!-- 菜品列表区域 -->
    <div class="dish-list">
      <el-table
        :data="dishList"
        border
        style="width: 100%;height: 100%;"
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
        <el-table-column prop="dish_name" label="菜品名称" align="center" />
        <el-table-column prop="category_id" label="分类" align="center">
            <template #default="scope">
                {{ dishcatageList.find(cat => cat.id === scope.row.category_id)?.name || '' }}
            </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" align="center" />
        <el-table-column prop="member_price" label="会员价" align="center" />
        <el-table-column prop="is_recommend" label="推荐" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_recommend === 1 ? 'success' : 'info'">
              {{ scope.row.is_recommend === 1 ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_temporary" label="临时菜" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.is_temporary === 1 ? 'warning' : 'info'">
              {{ scope.row.is_temporary === 1 ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" align="center" show-overflow-tooltip/>
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
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="cooking_time" label="烹饪时长(分钟)" align="center" />
        <el-table-column prop="kitchen_id" label="制作厨房" align="center">
            <template #default="scope">
                {{ kitchenList.find(cat => cat.id === scope.row.kitchen_id)?.name || '' }}
            </template>
        </el-table-column>
        <el-table-column label="操作" align="center" width="180">
          <template #default="scope">
            <el-button type="text" style="color: #f56c6c;" @click="handleDelete(scope.row)">删除</el-button>
            <el-button type="text" style="color: #67c23a;" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button type="text" style="color: #165DFF;" @click="openFormulaDialog(scope.row)">配方</el-button>
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
    <el-dialog v-model="addDialogVisible" width="500" title="新增菜品">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店">
          <el-select v-model="form.store_id" placeholder="门店特色必须选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="菜品名称" required>
          <el-input v-model="form.dish_name" />
        </el-form-item>
        <el-form-item label="分类" required>
          <el-select v-model="form.category_id" placeholder="请选择菜品分类" >
            <el-option v-for="store in dishcatageList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
         </el-select>
        </el-form-item>
        <el-form-item label="价格" required>
          <el-input v-model.number="form.price" />
        </el-form-item>
        <el-form-item label="会员价" required>
          <el-input v-model.number="form.member_price" />
        </el-form-item>
        <el-form-item label="推荐">
          <el-select v-model="form.is_recommend">
            <el-option label="是" :value="1" />
            <el-option label="否" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="临时菜">
          <el-select v-model="form.is_temporary">
            <el-option label="是" :value="1" />
            <el-option label="否" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" />
        </el-form-item>
        <el-form-item label="图片" required>
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
          <el-select v-model="form.status">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="烹饪时长(分钟)" required>
          <el-input v-model.number="form.cooking_time" />
        </el-form-item>
        <el-form-item label="制作厨房" required>
          <el-select v-model="form.kitchen_id" placeholder="请选择制作厨房" >
            <el-option v-for="kitchen in kitchenList" :key="kitchen.id" :value="kitchen.id" :label="kitchen.name">{{ kitchen.name }}</el-option>
         </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleAdd">确认新增</el-button>
      </template>
    </el-dialog>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="editDialogVisible" width="500" title="编辑菜品">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店">
          <el-select v-model="form.store_id" placeholder="门店特色必须选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="菜品名称" required>
          <el-input v-model="form.dish_name" />
        </el-form-item>
        <el-form-item label="分类" required>
            <el-select v-model="form.category_id" placeholder="请选择菜品分类" class="filter-item">
                <el-option v-for="store in dishcatageList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="价格" required>
          <el-input v-model.number="form.price" />
        </el-form-item>
        <el-form-item label="会员价" required>
          <el-input v-model.number="form.member_price" />
        </el-form-item>
        <el-form-item label="推荐">
          <el-select v-model="form.is_recommend">
            <el-option label="是" :value="1" />
            <el-option label="否" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="临时菜">
          <el-select v-model="form.is_temporary">
            <el-option label="是" :value="1" />
            <el-option label="否" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" />
        </el-form-item>
        <el-form-item label="图片" required>
          <el-upload
            class="avatar-uploader"
            action="api/Img/UpImg" 
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <img v-if="form.image_url" :src="form.image_url" class="avatar" style="width: 80px; height: 80px; object-fit: cover;" />
            <u-icon v-else class="avatar-uploader-icon" name="plus" size="50"></u-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="烹饪时长(分钟)" required>
          <el-input v-model.number="form.cooking_time" />
        </el-form-item>
        <el-form-item label="制作厨房" required>
          <el-select v-model="form.kitchen_id" placeholder="请选择制作厨房" >
            <el-option v-for="kitchen in kitchenList" :key="kitchen.id" :value="kitchen.id" :label="kitchen.name">{{ kitchen.name }}</el-option>
         </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleEditConfirm">确认编辑</el-button>
      </template>
    </el-dialog>

    <!-- 菜品配方弹窗 -->
    <el-dialog v-model="formulaDialogVisible" width="700" title="菜品配方配置">
      <el-form :model="formulaForm" inline>
        <el-form-item label="菜品">
          <el-input v-model="formulaForm.dish_name" disabled style="width:180px;" />
        </el-form-item>
        <el-form-item label="规格">
          <el-select v-model="formulaForm.spec_id" filterable clearable placeholder="全部规格" style="min-width:140px;">
            <el-option v-for="spec in specList" :key="spec.spec_id" :label="spec.spec_name" :value="spec.spec_id" />
          </el-select>
        </el-form-item>
        <el-button type="primary" @click="fetchFormulaList">查询</el-button>
        <el-button @click="openAddFormulaDialog">新增配料</el-button>
      </el-form>
      <el-table :data="formulaList" style="margin-top:18px;">
        <el-table-column prop="material_name" label="原材料" />
        <el-table-column prop="consumption" label="消耗数量" />
        <el-table-column prop="loss_rate" label="损耗率">
          <template #default="scope">{{ (scope.row.loss_rate * 100).toFixed(2) }}%</template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button @click="editFormula(scope.row)" size="small">编辑</el-button>
            <el-button @click="deleteFormula(scope.row)" type="danger" size="small">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-dialog v-model="addFormulaDialogVisible" title="新增原材料" width="400px">
        <el-form :model="addFormulaForm" label-width="90px">
          <el-form-item label="原材料">
            <el-select v-model="addFormulaForm.material_id" filterable placeholder="请选择原材料">
              <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_id" />
            </el-select>
          </el-form-item>
          <el-form-item label="消耗数量">
            <el-input v-model="addFormulaForm.consumption" placeholder="如200g" />
          </el-form-item>
          <el-form-item label="损耗率">
            <el-input-number v-model="addFormulaForm.loss_rate" :min="0" :max="1" :step="0.01" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="addFormulaDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleAddFormulaConfirm">确认新增</el-button>
        </template>
      </el-dialog>
      <el-dialog v-model="editFormulaDialogVisible" title="编辑原材料" width="400px">
        <el-form :model="editFormulaForm" label-width="90px">
          <el-form-item label="原材料">
            <el-select v-model="editFormulaForm.material_id" filterable disabled>
              <el-option v-for="m in materialList" :key="m.material_id" :label="m.material_name" :value="m.material_id" />
            </el-select>
          </el-form-item>
          <el-form-item label="消耗数量">
            <el-input v-model="editFormulaForm.consumption" />
          </el-form-item>
          <el-form-item label="损耗率">
            <el-input-number v-model="editFormulaForm.loss_rate" :min="0" :max="1" :step="0.01" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="editFormulaDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleEditFormulaConfirm">保存</el-button>
        </template>
      </el-dialog>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { getDishList, addDish, updateDish, deleteDish, getDishCategoryList, getkitchenList } from '../../../../api/dish';
import { getStoreList } from '../../../../api/login';
import config from '../../../../../public/config';
import { getFormulaList, addFormula, updateFormula, deleteFormula as apiDeleteFormula, type Formula } from '../../../../api/dishformula';
import { getAllRawMaterialList } from '../../../../api/RawMaterial';
import { getDishSpecList } from '../../../../api/dishspec';
const uploadUrl = config.apiBaseUrl + '/api/Img/UpImg';
const dishName = ref('');
const dishList = ref<any[]>([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const addDialogVisible = ref(false);
const editDialogVisible = ref(false);
const storeList = ref<any[]>([]);
const kitchenList = ref<any[]>([])
const selectedType = ref('');
const dishcatageList = ref<any[]>([]);
const form = ref({
  dish_id: 0,
  category_id: '',
  dish_name: '',
  price: 0,
  member_price: 0,
  is_recommend: 0,
  is_temporary: 0,
  description: '',
  image_url: '',
  status: 1,
  cooking_time: 0,
  store_id: null,
  kitchen_id:''
});
const formulaDialogVisible = ref(false);
const formulaForm = ref({ dish_id: '', dish_name: '', spec_id: '' });
const specList = ref<any[]>([]);
const formulaList = ref<any[]>([]);
const materialList = ref<any[]>([]);
const addFormulaDialogVisible = ref(false);
const addFormulaForm = ref({ material_id: '', consumption: '', loss_rate: 0 });
const editFormulaDialogVisible = ref(false);
const editFormulaForm = ref({ formula_id: '', material_id: '', consumption: '', loss_rate: 0 });

const getDishListData = async () => {
await getDishList(dishName.value,selectedType.value,currentPage.value - 1, pageSize.value).then((res: any) => {
  if (res && res.response) {
    dishList.value = res.response;
    total.value = res.count;
  }
});
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

async function fetchDishCategoryList() {
  await getDishCategoryList().then((res: any) => {
    if (res && res.response) {
      dishcatageList.value = res.response.map((item: any) => ({
        id: item.category_id,
        name: item.category_name
      }));
    }
  });
}

onMounted(() => {
  getDishListData();
  fetchStoreList();
  fetchDishCategoryList()
  fetchkitchenList()
});

async function fetchkitchenList(){
 await getkitchenList().then((res: any) => {
    if (res && res.response) {
      kitchenList.value = res.response.map((item: any) => ({
        id: item.id,
        name: item.kitchen_name
      }));
    }
  });
}

const handleQuery = () => {
  currentPage.value = 1;
  getDishListData();
};

const handleReset = () => {
  dishName.value = '';
  selectedType.value = '';
  handleQuery();
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  getDishListData();
};

const handlePageChange = (val: number) => {
  currentPage.value = val;
  getDishListData();
};

const openAddDialog = () => {
  form.value = {
    dish_id: 0,
    category_id: '',
    dish_name: '',
    price: 0,
    member_price: 0,
    is_recommend: 0,
    is_temporary: 0,
    description: '',
    image_url: '',
    status: 1,
    cooking_time: 0,
    store_id: null,
    kitchen_id:''
  };
  addDialogVisible.value = true;
};

const handleAdd = async () => {
  await addDish(form.value);
  ElMessage.success('新增成功');
  addDialogVisible.value = false;
  getDishListData();
};

const openEditDialog = (row: any) => {
  form.value = { ...row };
  editDialogVisible.value = true;
};

const handleEditConfirm = async () => {
  await updateDish(form.value);
  ElMessage.success('编辑成功');
  editDialogVisible.value = false;
  getDishListData();
};

const handleDelete = async (row: any) => {
  await deleteDish([row.dish_id]);
  ElMessage.success('删除成功');
  getDishListData();
};

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

function openFormulaDialog(row: any) {
  formulaForm.value = { dish_id: row.dish_id, dish_name: row.dish_name, spec_id: '' };
  fetchSpecList(row.dish_id);
  fetchFormulaList();
  formulaDialogVisible.value = true;
}
async function fetchSpecList(dish_id: any) {
  const res:any = await getDishSpecList(dish_id);
  specList.value = res?.response || [];
}
async function fetchFormulaList() {
  const params = {
    pageIndex: 1,
    pageSize: 9999,
    dishId: Number(formulaForm.value.dish_id),
    specId: formulaForm.value.spec_id ? Number(formulaForm.value.spec_id) : undefined
  };
  const res:any = await getFormulaList(params);
  formulaList.value = res?.response.map((item:any) => ({
        ...item,
        material_name: item.dish_material?.material_name  || '未知材料'
      })) || [];
}
async function fetchMaterialList() {
  const res:any = await getAllRawMaterialList();
  materialList.value =res.response ||[];
}
function openAddFormulaDialog() {
  addFormulaForm.value = { material_id: '', consumption: '', loss_rate: 0 };
  fetchMaterialList();
  addFormulaDialogVisible.value = true;
}
async function handleAddFormulaConfirm() {
  if (!formulaForm.value.dish_id || !addFormulaForm.value.material_id) {
    ElMessage.warning('请选择菜品和原材料');
    return;
  }
  const payload: Formula = {
    formula_id: 0,
    dish_id: Number(formulaForm.value.dish_id),
    spec_id: Number(formulaForm.value.spec_id) || 0,
    material_id: Number(addFormulaForm.value.material_id),
    consumption: Number(addFormulaForm.value.consumption),
    loss_rate: Number(addFormulaForm.value.loss_rate)
  };
  const res:any = await addFormula(payload);
  if (res?.success) {
    ElMessage.success('新增成功');
    addFormulaDialogVisible.value = false;
    fetchFormulaList();
  } else {
    ElMessage.error(res?.message || '新增失败');
  }
}
function editFormula(row: any) {
  editFormulaForm.value = { ...row };
  editFormulaDialogVisible.value = true;
}
async function handleEditFormulaConfirm() {
  const payload: Formula = {
    formula_id: Number(editFormulaForm.value.formula_id),
    dish_id: Number(formulaForm.value.dish_id),
    spec_id: Number(formulaForm.value.spec_id) || 0,
    material_id: Number(editFormulaForm.value.material_id),
    consumption: Number(editFormulaForm.value.consumption),
    loss_rate: Number(editFormulaForm.value.loss_rate)
  };
  const res:any = await updateFormula(payload);
  if (res?.success) {
    ElMessage.success('保存成功');
    editFormulaDialogVisible.value = false;
    fetchFormulaList();
  } else {
    ElMessage.error(res?.data?.message || '保存失败');
  }
}
async function deleteFormula(row: any) {
  const res:any = await apiDeleteFormula(row.formula_id);
  if (res?.success) {
    ElMessage.success('删除成功');
    fetchFormulaList();
  } else {
    ElMessage.error(res?.data?.message || '删除失败');
  }
}
</script>

<style scoped>
.dish-management-container {
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
.dish-list {
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
