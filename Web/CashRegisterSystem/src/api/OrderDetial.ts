
import axios from '../common/axios';

// 获取订单详情
export function getOrderDetail(orderId: string) {
  return axios.get('/api/Order/GetOrderDetails', {
    params: { orderId }
  });
}

//转桌
export function changeTable(orderId: string, newTableId: string) {
  return axios.get('/api/Order/ChangeTable', {params: {
    orderId,
    newTableId
  }});
}

//并桌
export function mergeTables(orderId: string, tableIds: string[]) {
  return axios.get('/api/Order/MergeTables', {params:{
    orderId,
    tableIds
  }});
}

//订单退款
export function refundOrder(orderId: string) {
  return axios.get('/api/Order/OrderRefund', {params:{
    orderId
  }});
}

//订单子项退款
export function refundOrderItem(orderItemId: string) {
  return axios.get('/api/Order/OrderItemRefund', {params:{orderItemId}});
}

//订单重做
export function redoOrder(orderId: string) {
  return axios.get('/api/Order/OrderRedo', {params:{
    orderId
  }});
}

export function OrderCheckout(orderId: string,type:string,payCode:string,CouponsId:number=0) {
  return axios.get('/api/Order/OrderCheckout',{params:{orderId,type,payCode,CouponsId}} );
}
