import axios from '../common/axios'

//获取桌台列表
export function gettableList(status:string='',tableCode:string='',page:number=1,size:number=10) {
    return axios.get('/api/Table/GetTableList',{params: { status,tableCode,page,size } })
}

// 添加桌台
export function AddTable(data: {
    store_id: string;
    table_no: string;
    capacity: number;
    status: number;
    desc: string;
    // min_consumption: number;
}) {
    return axios.post('/api/Table/AddTable', data);
}

// 删除桌台
export function DeleteTable(ids: number[]) {
    return axios.post('/api/Table/DeleteTable', ids);
}

// 更新桌台
export function UpdateTable(data: {
    table_id: number;
    store_id: string;
    table_no: string;
    capacity: number;
    status: number;
    desc: string;
}) {
    return axios.post('/api/Table/UpdateTable', data);
}

