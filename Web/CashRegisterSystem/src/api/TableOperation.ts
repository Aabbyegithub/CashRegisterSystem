
import axios from '../common/axios';

//根据桌台获取订单明细
export function getOrderDetailsByTableId(tableId: string) {
  return axios.get('/api/Order/GetOrderDetailsByTableId', {
    params: { tableId }
  });
}
//转桌
export function changeTable(oldTableId: string, newTableId: number,orderId: string,remark?:string) {
  return axios.get('/api/Order/ChangeTable', {params:{
    orderId,
    newTableId,
    oldTableId,
    remark: remark || ''}
  });
}
//并桌
export function mergeTables(oldTableId: string, newTableId: number,orderId: string,remark?:string) {
  return axios.get('/api/Order/MergeTable', {params:{
    orderId,
    newTableId,
    oldTableId,
    remark: remark || ''}
  });
}

//获取所有桌台
export function getAllTables() {
  return axios.get('/api/Table/GetTableListInfo');
}

export function getStoreTables(store_id:number) {
  return axios.get('/api/Client/GetTableListInfo',{params:{store_id}});
}