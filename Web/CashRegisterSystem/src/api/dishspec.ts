import axios from '../common/axios';

// 获取规格列表
export function getSpecList(params: { pageIndex: number; pageSize: number; dishId?: string; specName?: string; specType?: string }) {
  return axios.get('/api/DishSpecifications/GetSpecList', { params });
}

export function getDishSpecList(dishId: number) {
  return axios.get('/api/DishSpecifications/GetDishSpecList', { params:{dishId} });
}
// 获取规格详情
export function getSpecById(specId: number) {
  return axios.get('/api/DishSpecifications/GetSpecById', { params: { specId } });
}

// 新增规格
export function addSpec(spec: any) {
  return axios.post('/api/DishSpecifications/AddSpec', spec);
}

// 编辑规格
export function updateSpec(spec: any) {
  return axios.post('/api/DishSpecifications/UpdateSpec', spec);
}

// 删除规格
export function deleteSpec(specId: number) {
  return axios.post('/api/DishSpecifications/DeleteSpec', specId);
}

export function GetDishSpec(dishId: number) {
  return axios.get('/api/DishSpecifications/GetSpecListByDishId', {params:{dishId}});
}

export function GetAllDishSpec() {
  return axios.get('/api/DishSpecifications/GetAllSpecList');
}
