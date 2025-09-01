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
    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header: { ...DEFAULT_HEADERS, ...(options.headers || {}) },
      timeout: options.timeout || TIMEOUT,
      success: (res:any) => {
        if (res.statusCode === 200) {
          resolve(res.data);
        } else if (res.statusCode === 401) {
          // 登录失效，跳转到登录页或做相关处理
          uni.showToast({ title: '登录失效，请重新登录', icon: 'none' });
          // 可根据实际情况跳转页面
          setTimeout(() => {
            uni.redirectTo({ url: '/pages/login/index' });
          }, 1500);
          
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

// 示例用法：
// request({ url: '/user/login', method: 'POST', data: { username, password } })
//   .then(res => { ... })
//   .catch(err => { ... })
