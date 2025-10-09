import axios from '../common/axios';

// 分页查询会员
export function getMemberPageList(params: { page: number; size: number; phone?: string; name?: string; status?: string; startDate?: string; endDate?: string }) {
  return axios.get('/api/Member/GetMemberPageList', { params });
}

// 新增会员
export function addMember(data: any) {
  return axios.post('/api/Member/AddMember', data);
}

// 编辑会员
export function updateMember(data: any) {
  return axios.post('/api/Member/UpdateMember', data);
}

// 切换会员状态
export function toggleMemberStatus(params: { memberId: number; status: number }) {
  return axios.post('/api/Member/ToggleStatus', null, { params });
}

export function getBalanceRecordList(params: { page: number; size: number; keyword?: string; startDate?: string; endDate?: string; operatorId?: string }) {
  return axios.get('/api/MemberBalance/GetBalanceRecordList', { params });
}

export function addMemberBalance(member_id:number, recharge_amount:number, give_amount:number,type:string) {
  return axios.post('/api/Member/AddBalance', null,{params: { member_id, recharge_amount, give_amount, type }});
}