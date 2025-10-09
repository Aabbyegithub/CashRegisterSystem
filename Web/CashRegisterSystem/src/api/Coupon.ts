import axios from '../common/axios';

// 获取优惠券列表
export function getCouponList(pageIndex = 1, pageSize = 10, storeId = '', name = '', type = '', status = '') {
  return axios.get('/api/Coupon/GetCouponList', {
    params: { pageIndex, pageSize, storeId, name, type, status }
  });
}

// 获取优惠券详情
export function getCouponById(couponId: number) {
  return axios.get('/api/Coupon/GetCouponById', {
    params: { couponId }
  });
}

// 新增优惠券
export function addCoupon(coupon: any) {
  return axios.post('/api/Coupon/AddCoupon', coupon);
}

// 编辑优惠券
export function updateCoupon(coupon: any) {
  return axios.post('/api/Coupon/UpdateCoupon', coupon);
}

// 删除优惠券（支持批量）
export function deleteCoupon(ids: number[] | number) {
  return axios.post('/api/Coupon/DeleteCoupon', ids);
}
