<template>
  <div class="table-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <!-- <label>桌台类型：</label>
      <el-select v-model="selectedType" placeholder="请选择桌台类型" class="filter-item">
        <el-option
          v-for="item in typeOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value"
        />
      </el-select> -->
      <label>桌台状态：</label>
      <el-select v-model="selectedStatus" placeholder="请选择桌台状态" class="filter-item">
        <el-option
          v-for="item in statusOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value"
        />
      </el-select>
      <label>桌台编号：</label>
      <el-input
        v-model="tableNo"
        placeholder="桌台编号"
        class="filter-item"
        clearable
      />
      <el-button @click="handleReset" style="margin-left: auto;">重置</el-button>
      <el-button type="primary" @click="handleQuery" style="background-color: #22A2B6;">查询</el-button>
      <el-button type="primary" @click="openAddDialog">新增</el-button>
    </div>

    <!-- 桌台列表区域 -->
    <div class="table-list">
      <el-table
        :data="tableList"
        border
        style="width: 100%;height: 100%;"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column
          type="selection"
          width="55"
        />
        <el-table-column
          label="序号"
          align="center"
          width="60"
        >
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
            {{ storeList.find(store => store.id === scope.row.store_id)?.name || scope.row.store_id }}
          </template>
        </el-table-column>
        <!-- <el-table-column
          prop="tableType"
          label="桌台类型"
          align="center"
        /> -->
        <el-table-column
          prop="table_no"
          label="桌台编号"
          align="center"
        />
        <el-table-column
          prop="status"
          label="桌台状态"
          align="center"
        >
          <template #default="scope">
            <el-tag :type="
              scope.row.status === 1 ? 'success' :
              scope.row.status === 2 ? 'warning' :
              scope.row.status === 3 ? 'info' :
              scope.row.status === 4 ? 'danger' : undefined
            ">
              {{ statusOptions.find(a => a.value === scope.row.status).label || scope.row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="capacity"
          label="容纳人数"
          align="center"
        />
        <el-table-column
          prop="min_consumption"
          label="包间最低消费"
          align="center"
        />
        <el-table-column
          prop="desc"
          label="桌台描述"
          align="center"
        />
        <el-table-column
          prop="lastUseTime"
          label="最后使用时间"
          align="center"
        />
        <el-table-column prop="qrcode_url" label="门店桌台二维码" align="center">
          <template #default="scope">
            <el-image
              v-if="scope.row.qrcode_url"
              :src="scope.row.qrcode_url"
              style="width:40px;height:40px;object-fit:cover;cursor:pointer"
              :preview-src-list="[scope.row.qrcode_url]"
              fit="cover"
              :preview-teleported="true"
            />
          </template>
        </el-table-column>
        <el-table-column
          label="操作"
          align="center"
          width="180"
        >
          <template #default="scope">
            <el-button
              type="text"
              style="color: #22A2B6;"
              @click="handleRegenerate(scope.row)"
            >重新生成</el-button>
            <el-button
              type="text"
              style="color: #f56c6c;"
              @click="handleDelete(scope.row)"
            >删除</el-button>
            <el-button
              type="text"
              style="color: #67c23a;"
              @click="openEditDialog(scope.row)"
            >编辑</el-button>
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
    <el-dialog v-model="addDialogVisible" width="500" title="新增桌台">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店" required>
          <el-select v-model="form.store_id" placeholder="请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="桌台编号" required>
          <el-input v-model="form.table_no" />
        </el-form-item>
        <!-- <el-form-item label="桌台类型">
          <el-select v-model="form.tableType" placeholder="请选择桌台类型">
            <el-option
              v-for="item in typeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>  
        </el-form-item> -->
        <el-form-item label="桌台状态" required>
          <el-select v-model="form.status" placeholder="请选择桌台状态">
            <el-option
              v-for="item in statusOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="容纳人数" required>
          <el-input v-model.number="form.capacity" />
        </el-form-item>
        <el-form-item label="桌台描述">
          <el-input v-model="form.desc" />
        </el-form-item>
        <el-form-item label="包间最低消费">
          <el-input v-model="form.min_consumption" />
        </el-form-item>
        <!-- <el-form-item label="最后使用时间">
          <el-input v-model="form.lastUseTime" />
        </el-form-item> -->
      </el-form>
      <template #footer>
        <el-button  class="cancel-btn" @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="handleAdd">确认新增</el-button>
      </template>
    </el-dialog>

    <!-- 编辑弹窗 -->
    <el-dialog v-model="editDialogVisible"width="500" title="编辑桌台">
      <el-form :model="form" label-width="120px">
        <el-form-item label="门店" required>
          <el-select v-model="form.store_id" placeholder="请选择门店">
            <el-option v-for="store in storeList" :key="store.id" :value="store.id" :label="store.name">{{ store.name }}</el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="桌台编号" required>
          <el-input v-model="form.table_no" disabled />
        </el-form-item>
        <!-- <el-form-item label="桌台类型">
          <el-select v-model="form.tableType" >
            <el-option
              v-for="item in typeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item> -->
        <el-form-item label="桌台状态" required>
          <el-select v-model="form.status">
            <el-option
              v-for="item in statusOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="容纳人数" required>
          <el-input v-model.number="form.capacity" />
        </el-form-item>
        <el-form-item label="包间最低消费">
          <el-input v-model="form.min_consumption" />
        </el-form-item>
        <el-form-item label="桌台描述">
          <el-input v-model="form.desc" />
        </el-form-item>
        <!-- <el-form-item label="最后使用时间">
          <el-input v-model="form.lastUseTime" />
        </el-form-item> -->
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
import QRCode from 'qrcode';
import { 
  ElSelect, ElInput, ElButton, ElTable, ElTableColumn, 
  ElPagination, ElTag, ElDialog, ElForm, ElFormItem, 
  ElMessage
} from 'element-plus';
import type { Options } from 'element-plus';
import { useRouter } from 'vue-router';
import { AddTable, DeleteTable, gettableList, RegenerateTable, UpdateTable } from '../../../../api/tablemanage';
import { getStoreList } from '../../../../api/login';

const router = useRouter();

// 筛选条件
const selectedType = ref<string>('');
const selectedStatus = ref<string>('');
const tableNo = ref<string>('');
const storeList = ref<any[]>([]); 
// 下拉选项
// const typeOptions = ref<Options[]>([
//   { label: '全部', value: '' },
//   { label: '圆桌', value: '圆桌' },
//   { label: '方桌', value: '方桌' },
//   { label: '卡座', value: '卡座' },
// ]);
const statusOptions = ref<any[]>([
  { label: '全部', value: '' },
  { label: '空闲', value: 1 },
  { label: '占用', value: 2},
  { label: '预订', value: 3},
  { label: '清洁中', value: 4 },
]);

// 表格数据
interface Table {
  table_id: number;
  store_id: string;
  table_no: string;          
  status: number;        
  capacity: number;
  desc: string;      
  lastUseTime: string; 
  min_consumption:string  
}
const tableList = ref<Table[]>([
  // { tableNo: 'A01', tableType: '圆桌', status: '空闲', capacity: 8, lastUseTime: '2025.3.15 12:00' },
  // { tableNo: 'A02', tableType: '方桌', status: '占用', capacity: 6, lastUseTime: '2025.3.15 11:30' },
  // { tableNo: 'A03', tableType: '卡座', status: '空闲', capacity: 4, lastUseTime: '2025.3.14 18:00' },
  // { tableNo: 'A04', tableType: '圆桌', status: '维护中', capacity: 10, lastUseTime: '2025.3.13 14:00' },
  // { tableNo: 'A05', tableType: '方桌', status: '占用', capacity: 6, lastUseTime: '2025.3.15 12:10' },
]);

// 分页相关
const total = ref(50);       
const pageSize = ref(10);    
const currentPage = ref(1);  

// 新增、编辑弹窗相关
const addDialogVisible = ref(false);
const editDialogVisible = ref(false);
const form = ref<Table>({
  table_id: 0,
  store_id: '',
  table_no: '',
  status: 1, // 默认状态为空闲
  capacity: 0,
  desc: '',
  lastUseTime: '',
  min_consumption:''
});

// 模拟接口请求
const getTableList = async () => {

  await gettableList(selectedStatus.value,tableNo.value,currentPage.value,pageSize.value).then(async (res:any)=> {
    if (res && res.response) {
      tableList.value = res.response;
      total.value = res.count;
    }
  });
};

onMounted(() => {
  getTableList();
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
// 查询
const handleQuery = () => {
  currentPage.value = 1; 
  getTableList();
};

// 重置
const handleReset = () => {
  selectedType.value = '';
  selectedStatus.value = '';
  tableNo.value = '';
  handleQuery();
};

// 每页条数改变
const handleSizeChange = (val: number) => {
  pageSize.value = val;
  getTableList();
};

// 当前页码改变
const handlePageChange = (val: number) => {
  currentPage.value = val;
  getTableList();
};

// 查看详情
const handleDetail = (row: Table) => {
  console.log('查看桌台详情：', row);
};

// 删除桌台
const handleDelete = async (row: Table) => {
    console.log('删除桌台：', row);
    await DeleteTable([row.table_id]).then(() => {
    ElMessage.success('删除成功');
    getTableList();
  })
};

const handleRegenerate = async (row: Table) => {
    console.log('重新生成桌台二维码：', row);
    await RegenerateTable(row.table_id).then(() => {
    ElMessage.success('重新生成成功');
    getTableList();
  })
};

// 打开新增弹窗
const openAddDialog = () => {
  form.value = {
    table_id: 0,
    store_id: '',
    table_no: '',
    status: 1, // 默认状态为空闲
    capacity: 0,
    desc: '',
    lastUseTime: '',
    min_consumption:'0'
  };
  addDialogVisible.value = true;
};

// 确认新增
const handleAdd = async () => {
   await AddTable({
    store_id: form.value.store_id,
    table_no: form.value.table_no,
    capacity: form.value.capacity,
    status: form.value.status,
    desc: form.value.desc,
    min_consumption: form.value.min_consumption,
   })
    ElMessage.success('新增成功');
    addDialogVisible.value = false;
    getTableList();
};

// 打开编辑弹窗
const openEditDialog = (row: Table) => {
  form.value = { ...row };
  editDialogVisible.value = true;
};

// 确认编辑
const handleEditConfirm = async () => {
  const index = tableList.value.findIndex(item => item.table_no === form.value.table_no);
  if (index !== -1) {
    tableList.value[index] = { ...form.value };
  }
  editDialogVisible.value = false;
  await UpdateTable({
    table_id: form.value.table_id,
    store_id: form.value.store_id,
    table_no: form.value.table_no,
    status: form.value.status,
    capacity: form.value.capacity,
    desc: form.value.desc,
    min_consumption:form.value.min_consumption,
  });
  ElMessage.success('编辑成功');
  getTableList();
};
</script>

<style scoped>
.table-management-container {
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
.table-list {
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
  /* margin-top: -100px; */
}

</style>