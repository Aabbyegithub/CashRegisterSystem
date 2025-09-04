
import axios from '../common/axios';

// 获取订单列表
export function getOrderList(page: number = 0, size: number = 10) {
    return axios.get('/api/Order/GetOrderList', { params: { page, size } });
}
// 订单列表
export function getAllOrderList(params: {
  page: number;
  size: number;
  store_Id?: string | number;
  OrdderNo?: string;
  tableId?: string | number;
}) {
  return axios.get('/api/Order/GetOrderList', { params });
}

// 新增预定
export function reserveOrder(data: any) {
  return axios.post('/api/Order/ReserveOrder', data);
}
/// 挂单
export function handOrder(order: number) {
  return axios.get('/api/Order/HangOrder', { params: { order } });
}