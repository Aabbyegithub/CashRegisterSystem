import axios from '../common/axios'
//获取门店列表
export function getStoreList(StoreName:string='',phone:string='',address:string='',page:number=1,size:number=10) {
    return axios.get('/api/Store/GetStoreList',{params: { StoreName,phone,address,page,size } })
}

//添加门店
export function addStoreApi(store_name:string,phone:string,address:string,business_hours:string='',total_tables:number=0,status:number=1) {
    return axios.post('/api/Store/AddStore',{ store_name,phone,address,business_hours,total_tables  ,status})
}

//编辑门店
export function editStoreApi(store_id:string,store_name:string,phone:string,address:string,business_hours:string='',total_tables:number=0,status:number=1) {
    return axios.post('/api/Store/UpdateStore',{ store_id,store_name,phone,address,business_hours,total_tables ,status })
}

//删除门店
export function deleteStoreApi( storeIds:number[] ) {
    return axios.post('/api/Store/DeleteStore', storeIds )
}

//更新门店状态
export function updateStoreStatusApi(storeId:string,status:number) {
    return axios.get('/api/Store/UpdateStoreStatus',{ params: { storeId, status } })
}

export function getDashboardData() {
  return axios.get('/api/CoreKPIReport/GetDashboardData');
}