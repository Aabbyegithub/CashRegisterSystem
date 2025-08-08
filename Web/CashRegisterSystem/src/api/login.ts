import axios from '../common/axios'
export function loginApi(username: string, password: string) {
    return axios.post('/api/login', { username, password })
}

//获取门店列表
export function getStoreList() {
    return axios.get('/api/Store/GetAllStoreList')
}