
import axios from '../common/axios';

// 获取订单详情
export function getOrderDetail(orderId: string) {
  return axios.get('/api/Order/GetOrderDetails', {
    params: { orderId }
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

//订单退款
export function refundOrder(orderId: string) {
  return axios.post('/api/Order/OrderRefund', {
    orderId
  });
}

//订单子项退款
export function refundOrderItem(orderItemId: string) {
  return axios.post('/api/Order/OrderItemRefund', {
    orderItemId
  });
}

//订单重做
export function redoOrder(orderId: string) {
  return axios.post('/api/Order/OrderRedo', {
    orderId
  });
}

export function OrderCheckout(orderId: string,type:string,CouponsId:number=0) {
  return axios.get('/api/Order/OrderCheckout',{params:{orderId,type,CouponsId}} );
}
