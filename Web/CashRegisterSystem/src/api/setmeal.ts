import axios from '../common/axios';

export function getMealList(params: { pageIndex: number; pageSize: number; storeId?: number|string; mealName?: string; status?: number|string }) {
  return axios.get('/api/SetMeal/GetMealList', { params });
}

export function getMealById(mealId: number) {
  return axios.get('/api/SetMeal/GetMealById', { params: { mealId } });
}

export function getMealItemList(mealId: number) {
  return axios.get('/api/SetMeal/GetMealItemList', { params: { mealId } });
}

export function addMeal(meal: any) {
  return axios.post('/api/SetMeal/AddMeal', meal);
}

export function updateMeal(meal: any) {
  return axios.post('/api/SetMeal/UpdateMeal', meal);
}

export function deleteMeal(mealId: number) {
  return axios.post('/api/SetMeal/DeleteMeal', mealId);
}

export function saveMealItem(item: any) {
  return axios.post('/api/SetMeal/SaveMealItem', item);
}

export function deleteMealItem(itemId: number) {
  return axios.post('/api/SetMeal/DeleteMealItem', itemId);
}

export function DeleteMealGroup(params: { MealId: number; GroupName: string }) {
  return axios.post('/api/SetMeal/DeleteMealGroup', null, {
    params
  });
}
