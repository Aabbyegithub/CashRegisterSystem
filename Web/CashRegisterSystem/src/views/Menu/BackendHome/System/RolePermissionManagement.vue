<template>
  <div class="table-management-container">
    <!-- 筛选区域 -->
    <div class="filter-bar">
      <el-button type="primary" style="background-color: #22A2B6;" @click="addRole">新增角色</el-button>
      <el-button @click="refreshRoles">刷新</el-button>
      <el-input v-model="searchRole" placeholder="搜索角色名称" clearable class="filter-item" @input="filterRoles" />
    </div>

    <!-- 角色列表区域 -->
    <div class="table-list">
      <el-table
        :data="roles"
        border
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column
          prop="role_name"
          label="角色名称"
          width="180"
          align="center"
        />
        <el-table-column
          prop="description"
          label="角色描述"
          align="center"
        />
        <el-table-column
          label="操作"
          width="260"
          align="center"
        >
          <template #default="{ row }">
            <el-button
              type="text"
              style="color: #67c23a;"
              @click="editRole(row)"
            >编辑</el-button>
            <el-button
              type="text"
              @click="assignPermissions(row)"
            >分配权限</el-button>
            <el-button
              type="text"
              style="color: #f56c6c;"
              @click="deleteRole(row)"
            >删除</el-button>
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
          :current-page="page"
          :prev-text="'<'"
          :next-text="'>'"
          :page-sizes="[10, 20, 30, 40, 50]"
          :display-page-count="5"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>

    <!-- 角色新增/编辑弹窗 -->
    <el-dialog v-model="showRoleDialog" :title="roleForm.role_id ? '编辑角色' : '新增角色'" width="500">
      <el-form :model="roleForm" label-width="120px">
        <el-form-item label="角色名称">
          <el-input v-model="roleForm.role_name" maxlength="50" />
        </el-form-item>
        <el-form-item label="角色描述">
          <el-input v-model="roleForm.description" maxlength="255" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button class="cancel-btn" @click="showRoleDialog = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="saveRole">保存</el-button>
      </template>
    </el-dialog>

    <!-- 权限分配弹窗 -->
    <el-dialog v-model="showPermissionDialog" title="分配权限" width="500px">
      <el-tree
        :data="permissionTree"
        show-checkbox
        node-key="permission_id"
        :default-checked-keys="checkedPermissionIds"
        :props="treeProps"
        ref="permissionTreeRef"
        style="max-height: 400px; overflow: auto;"
      />
      <template #footer>
        <el-button class="cancel-btn" @click="showPermissionDialog = false">取消</el-button>
        <el-button type="primary" class="Btn-Save" @click="savePermissions">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { addRolePermissionApi, deleteRolePermissionApi, editRolePermissionApi, getAllPermissions, getRolePermissionList, saveRolePermissions } from '../../../../api/RolePermission'
import { ElMessage } from 'element-plus'
// 角色列表
const roles = ref([
  { role_id: 1, role_name: '店长', description: '管理全店' },
  { role_id: 2, role_name: '收银员', description: '负责收银' },
])
const searchRole = ref('')
const page = ref(1)
const pageSize = ref(10)
const total = ref(10)

// 角色表单
const showRoleDialog = ref(false)
const roleForm = reactive({ role_id: null, role_name: '', description: '' })
function editRole(row: any) {
  Object.assign(roleForm, row)
  showRoleDialog.value = true
}
function addRole() {
  Object.assign(roleForm, { role_id: null, role_name: '', description: '' })
  showRoleDialog.value = true
}

onMounted(() => {
  refreshRoles()
});
async function saveRole() {
  // TODO: 调用保存API
   if (roleForm.role_id) {
    // 编辑
    const idx = roles.value.findIndex(item => item.role_id === roleForm.role_id);
    if (idx > -1) {
      await editRolePermissionApi(roleForm.role_id, roleForm.role_name, roleForm.description)
      ElMessage.success('编辑成功');
    }
  } else {
    // 新增
    await addRolePermissionApi(roleForm.role_name, roleForm.description)
    ElMessage.success('新增成功');
  }
  
  refreshRoles()
  showRoleDialog.value = false
}
async function deleteRole(row: any) {
  // TODO: 调用删除API
  await deleteRolePermissionApi(row.role_id)
  refreshRoles()
}
async function refreshRoles() {
  await getRolePermissionList(searchRole.value, page.value, pageSize.value).then((res: any) => {
    if (res && res.response) {
      roles.value = res.response.map((item: any) => ({
        role_id: item.role_id,
        role_name: item.role_name,
        description: item.description
      }));
      total.value = res.response.total
    }
  })
}
function filterRoles() {
  page.value = 1
}

// 权限树
// 递归权限树示例数据
const permissionTree = ref([
  {
    permission_id: 1,
    permission_name: '订单管理',
    permission_key: 'order:manage',
    parent_id: 0,
    children: [
      {
        permission_id: 11,
        permission_name: '订单查询',
        permission_key: 'order:query',
        parent_id: 1,
        children: []
      },
      {
        permission_id: 12,
        permission_name: '订单编辑',
        permission_key: 'order:edit',
        parent_id: 1,
        children: []
      }
    ]
  },
  {
    permission_id: 2,
    permission_name: '会员管理',
    permission_key: 'member:manage',
    parent_id: 0,
    children: [
      {
        permission_id: 21,
        permission_name: '会员查询',
        permission_key: 'member:query',
        parent_id: 2,
        children: []
      }
    ]
  }
])
const checkedPermissionIds = ref<number[]>([])
const permissionTreeRef = ref<any>(null);
const showPermissionDialog = ref(false)
const currentRole = ref<any>(null)
const treeProps = { label: 'permission_name', children: 'children' }
async function assignPermissions(row: any) {
  currentRole.value = row
  // TODO: 获取当前角色已分配权限
  checkedPermissionIds.value = []
  showPermissionDialog.value = true
  await getAllPermissions(currentRole.value.role_id).then((res: any) => {
    if (res && res.response) {
      permissionTree.value = res.response.map((item: any) => ({
        permission_id: item.permissionId,
        permission_name: item.groupTitle,
        permission_key: item.groupKey,
        parent_id: item.parent_id,
        isselect :item.isselect, 
        children: item.children.map((item1: any) =>({
          permission_id: item1.permissionId,
          permission_name: item1.title,
          permission_key: item1.key,
          parent_id: item1.parent_id,
          isselect :item1.isselect, 
        })) || []
      }));
      checkedPermissionIds.value =getCheckedPermissionIds(permissionTree.value)
    }
  });
}

function getCheckedPermissionIds(tree:any[]) {
  let result: any[] = [];
  tree.forEach(item => {
    // 如果当前项被选中，添加其 permission_id
    if (item.isselect) {
      result.push(item.permission_id);
    }
    // 递归处理子项（如果有 children）
    if (item.children && item.children.length > 0) {
      result = result.concat(getCheckedPermissionIds(item.children));
    }
  });
  return result;
}
async function savePermissions() {
  // TODO: 保存权限分配API
   const checkedIds = permissionTreeRef.value.getCheckedKeys(false, false);
  await saveRolePermissions(currentRole.value.role_id,checkedIds)
  ElMessage.success('权限分配成功')
  showPermissionDialog.value = false
}
function handleSizeChange(val: number) {
  pageSize.value = val
}

function handlePageChange(val: number) {
  page.value = val
}
</script>

<style scoped>
.table-management-container {
  padding: 24px;
}
.filter-bar {
  display: flex;
  align-items: center;
  gap: 12px;
}
.filter-item {
  width: 200px;
}
.table-list {
  margin-top: 16px;
}
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 16px 0 0;
  font-size: 14px;
}
.cancel-btn {
  margin-right: 10px;
}
</style>