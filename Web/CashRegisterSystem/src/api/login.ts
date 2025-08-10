import axios from '../common/axios'
export function loginApi(UserName: string, PassWord: string,orgid:string) {
    return axios.get('/api/User/Login', {params: { UserName, PassWord,orgid } })
}

//获取门店列表
export function getStoreList() {
    return axios.get('/api/Store/GetAllStoreList')
}