// request.ts
// 封装小程序/APP请求接口方法
import { BASE_URL, TIMEOUT, DEFAULT_HEADERS } from '../config';

interface RequestOptions {
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  data?: any;
  headers?: Record<string, string>;
  timeout?: number;
}
export function request(options: RequestOptions): Promise<any> {
  return new Promise((resolve, reject) => {
    const token = uni.getStorageSync('token') || '' // 每次请求都获取最新 token
    const headers = {
      ...DEFAULT_HEADERS,
      ...(options.headers || {}),
      // 注意后端要求的字段大小写
      Authorization: token ? `Bearer ${token}` : '',
    }
    // 登录接口不带 token
    // if (options.url.includes('/login')) {
    //   delete headers.Authorization
    // }
    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header: headers,
      timeout: options.timeout || TIMEOUT,
      success: (res:any) => {
        if (res.statusCode === 200) {
          resolve(res.data);
        } else if (res.statusCode === 401) {
          // 登录失效，跳转到登录页或做相关处理
          uni.showToast({ title: '登录失效，请重新登录', icon: 'none' });
          uni.removeStorageSync('token'); // 清除过期 token
          uni.removeStorageSync('userInfo'); // 清除用户信息
          // 可根据实际情况跳转页面
          setTimeout(() => {
            uni.redirectTo({ url: '/pages/my/Login' });
          }, 500);
          
        } else {
            // 其他错误处理
            uni.showToast({ title: res.data.message || '请求失败', icon: 'none' });
        }
      },
      fail: (err) => {
        reject(err);
      },
    });
  });
}
