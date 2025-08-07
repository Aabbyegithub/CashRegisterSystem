
export function loginApi(username: string, password: string) {
  // 模拟请求
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (username === 'admin' && password === '123456') {
        resolve({ token: 'mock-token-abc123' })
      } else {
        reject(new Error('用户名或密码错误'))
      }
    }, 1000)
  })
}
// 查询备份列表
// get('/backup/list').then(res => {
//   // 处理数据
// })

// // 新增备份
// post('/backup/create', { name: 'xxx' }).then(res => {
//   // 处理数据
// })