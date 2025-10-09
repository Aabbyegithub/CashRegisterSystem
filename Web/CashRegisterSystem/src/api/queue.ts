import axios from '../common/axios';


// 获取排队分页列表
export function getQueuePageList(params: {
  page?: number;
  size?: number;
  storeId?: string;
  status?: string;
  partySize?: string;
  keyword?: string;
}) {
  return axios.get('/api/Queue/GetQueuePageList', { params });
}

// 获取排队统计
export function getQueueStats(params: { storeId?: string }) {
  return axios.get('/api/Queue/GetQueueStats', { params });
}

// 新增排队
export function addQueue(queue: {
  store_id  : string;
  customer_name: string;
  customer_phone: string;
  party_size: number;
  status: number;
  remark: string;
}) {
  return axios.post('/api/Queue/AddQueue', queue);
}

// 叫号
export function callQueue(params: { queueId: string | number }) {
  return axios.post('/api/Queue/CallQueue', null, { params });
}

// 过号
export function skipQueue(params: { queueId: string | number }) {
  return axios.post('/api/Queue/SkipQueue', null, { params });
}

// 取消排队
export function cancelQueue(params: { queueId: string | number }) {
  return axios.post('/api/Queue/CancelQueue', null, { params });
}