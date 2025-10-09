import axios from '../common/axios';

// 获取采购单列表
export function getPurchaseOrderList(pageIndex = 1, pageSize = 10, storeId = '', poNo = '', supplierId = '', status = '') {
  return axios.get('/api/PurchaseOrder/GetPurchaseOrderList', {
    params: { pageIndex, pageSize, storeId, poNo, supplierId, status }
  });
}

// 获取采购单详情
export function getPurchaseOrderDetail(poId: number) {
  return axios.get('/api/PurchaseOrder/GetPurchaseOrderDetail', {
    params: { poId }
  });
}

// 新增采购单
export function addPurchaseOrder(data: any) {
  return axios.post('/api/PurchaseOrder/AddPurchaseOrder', data);
}

// 取消采购单
export function cancelPurchaseOrder(poId: number) {
  return axios.post('/api/PurchaseOrder/CancelPurchaseOrder', null, {
    params: { poId }
  });
}

export function ArrivedPurchaseOrder(poId: number) {
  return axios.post('/api/PurchaseOrder/ArrivedPurchaseOrder', null, {
    params: { poId }
  });
}

export function SavePurchaseOrder(poId: number,supplier_id:number) {
  return axios.post('/api/PurchaseOrder/SavePurchaseOrder', null, {
    params: { poId,supplier_id}
  });
}
