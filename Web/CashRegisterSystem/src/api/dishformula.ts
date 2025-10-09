import axios from '../common/axios';

export interface Formula {
  formula_id: number;
  dish_id: number;
  spec_id: number;
  material_id: number;
  consumption: number;
  loss_rate: number;
}

export function getFormulaList(params: { pageIndex: number; pageSize: number; dishId?: number; materialId?: number }) {
  return axios.get('/api/DishConfig/GetFormulaList', { params });
}

export function addFormula(data: Formula) {
  return axios.post('/api/DishConfig/AddFormula', data);
}

export function updateFormula(data: Formula) {
  return axios.post('/api/DishConfig/UpdateFormula', data);
}

export function deleteFormula(formulaId: number) {
  return axios.post('/api/DishConfig/DeleteFormula', null, { params: { formulaId } });
}
