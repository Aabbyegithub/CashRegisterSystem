
import axios from '../common/axios';

//获取桌台列表
export function getTableList() {
    return axios.get('/api/Table/GetAllTableList');
}

// 获取订单列表
export function getFlatOrderList(
  tableCode: string = '',
  orderNo: string = '',
  page: number = 0,
  size: number = 10
) {
  return axios.get('/api/FlatOrder/GetFlatOrderList', {
    params: { tableCode, orderNo, page, size }
  });
}