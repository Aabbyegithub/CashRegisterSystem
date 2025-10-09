import axios from '../common/axios';

// 获取原材料列表
export function getRawMaterialList(pageIndex = 1, pageSize = 10, storeId = '', name = '', category = '', status = '') {
  return axios.get('/api/RawMaterials/GetRawMaterialList', {
    params: { pageIndex, pageSize, storeId, name, category, status }
  });
}

//获取库存
export function getInventoryAlertList(pageIndex = 1, pageSize = 10, storeId = '', materialId = '', category = '') {
  return axios.get('/api/InventoryAlert/GetInventoryAlertList', {
    params: { pageIndex, pageSize, storeId, materialId, category }
  });
}

export function getAllRawMaterialList() {
  return axios.get('/api/RawMaterials/GetAllRawMaterialList');
}

// 新增原材料
export function addRawMaterial(data: any) {
  return axios.post('/api/RawMaterials/AddRawMaterial', data);
}

// 编辑原材料
export function updateRawMaterial(data: any) {
  return axios.post('/api/RawMaterials/UpdateRawMaterial', data);
}

// 修改原材料状态
export function changeRawMaterialStatus(materialId: number, status: number) {
  return axios.post(`/api/RawMaterials/ChangeStatus?materialId=${materialId}&status=${status}`);
}
// 采购原材料
export function PurchaseMaterial(materialId: string, quantity: number,remark:string) {
  return axios.post(`/api/InventoryAlert/PurchaseMaterial?materialId=${materialId}&quantity=${quantity}&remark=${remark}`);
}
