import axios from '../common/axios';

// 获取促销列表
export function getPromotionList(pageIndex = 1, pageSize = 10, storeId = '', name = '', type = '', status = '') {
  return axios.get('/api/Promotion/GetPromotionList', {
    params: { pageIndex, pageSize, storeId, name, type, status }
  });
}

// 获取促销详情
export function getPromotionById(promotionId: number) {
  return axios.get('/api/Promotion/GetPromotionById', {
    params: { promotionId }
  });
}

// 新增促销
export function addPromotion(promotion: any) {
  return axios.post('/api/Promotion/AddPromotion', promotion);
}

// 编辑促销
export function updatePromotion(promotion: any) {
  return axios.post('/api/Promotion/UpdatePromotion', promotion);
}

// 删除促销（支持批量）
export function deletePromotion(ids: number[] | number) {
  return axios.post('/api/Promotion/DeletePromotion', ids);
}
