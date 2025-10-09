import axios from '../common/axios';

// 获取损耗记录列表
export function getLossList(pageIndex = 1, pageSize = 10, storeId = '', materialId = '', lossType = '') {
  return axios.get('/api/InventoryLoss/GetLossList', {
    params: { pageIndex, pageSize, storeId, materialId, lossType }
  });
}

// 获取损耗详情
export function getLossDetail(lossId: number) {
  return axios.get('/api/InventoryLoss/GetLossDetail', {
    params: { lossId }
  });
}

// 新增损耗记录
export function addLoss(data: any) {
  return axios.post('/api/InventoryLoss/AddLoss', data);
}

export function updateLoss(data: any) {
  return axios.post('/api/InventoryLoss/UpdateLoss', data);
}

export function delLossDetail(lossId: number) {
  return axios.get(`/api/InventoryLoss/DelLossDetail?lossId=${lossId}`);
}
