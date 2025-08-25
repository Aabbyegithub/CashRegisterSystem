
import axios from '../common/axios';

//根据桌台获取订单明细
export function getOrderDetailsByTableId(tableId: string) {
  return axios.get('/api/Order/GetOrderDetailsByTableId', {
    params: { tableId }
  });
}
//转桌
export function changeTable(orderId: string, newTableId: string) {
  return axios.post('/api/Order/ChangeTable', {
    orderId,
    newTableId
  });
}
//并桌
export function mergeTables(orderId: string, tableIds: string[]) {
  return axios.post('/api/Order/MergeTables', {
    orderId,
    tableIds
  });
}