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
