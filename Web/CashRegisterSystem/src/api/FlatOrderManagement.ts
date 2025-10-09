
import axios from '../common/axios';

//获取桌台列表
export function getTableList() {
    return axios.get('/api/Table/GetTableListInfo');
}

// 获取订单列表
export function getFlatOrderList(
  tableId: string,
  orderno: string = '',
  page: number = 0,
  size: number = 10
) {
  return axios.get('/api/Order/GetNotCheckoutOrderList', {
    params: { tableId, orderno, page, size }
  });
}