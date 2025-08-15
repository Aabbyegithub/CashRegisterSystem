
import axios from '../common/axios';

// 获取订单列表
export function getOrderList(page: number = 0, size: number = 10) {
    return axios.get('/api/Order/GetOrderList', { params: { page, size } });
}
