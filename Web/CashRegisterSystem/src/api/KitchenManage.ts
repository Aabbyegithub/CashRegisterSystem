import axios from '../common/axios';

export function getKitchenList(page: number, size: number) {
  return axios.get(`/api/KitchenManage/GetKitchenList`, {
    params: { page, size }
  });
}

export function addKitchen(data: any) {
  return axios.post(`/api/KitchenManage/AddKitchen`, data);
}

export function updateKitchen(data: any) {
  return axios.post(`/api/KitchenManage/UpdateKitchen`, data);
}

export function deleteKitchen(id: number) {
  return axios.post(`/api/KitchenManage/DeleteKitchen`, id);
}

export function getKitchenOrderList(params: { storeId?: string; kitchenType?: string; status?: string }) {
  return axios.get('/api/KitchenDashboard/GetKitchenOrderList', { params });
}

export function getOrderStatusStats(params: { storeId?: string; kitchenType?: string }) {
  return axios.get('/api/KitchenDashboard/GetOrderStatusStats', { params });
}

export function updateOrderStatus(params: { kitchenOrderId: number; status: number }) {
  return axios.post('/api/KitchenDashboard/UpdateOrderStatus', null, { params });
}

export function getAllKitchenOrderList(params: {
  storeId?: string;
  kitchenType?: string;
  status?: string;
  StartTime?: string;
  EndTime?: string;
  page?: number;
  size?: number;
}) {
  return axios.get('/api/ServingFood/GetKitchenOrderList', { params });
}
