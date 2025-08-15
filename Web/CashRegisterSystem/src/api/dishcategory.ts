
import axios from '../common/axios';

// 获取菜品分类列表
export function getDishCategoryList(name:string,page: number = 0, size: number = 10) {
    return axios.get('/api/Dishcategory/GetDishCategoryList', { params: {name, page, size } });
}

// 添加菜品分类
export function addDishCategory(dishCategory: {
    store_id: null;
    category_name: string;
    sort_order: number;
    status: number;
}) {
    return axios.post('/api/Dishcategory/AddDishCategory', dishCategory);
}

// 删除菜品分类
export function deleteDishCategory(ids: number[]) {
    return axios.post('/api/Dishcategory/DeleteDishCategory', ids);
}

// 更新菜品分类
export function updateDishCategory(dishCategory: {
    category_id: number;
    store_id: null;
    category_name: string;
    sort_order: number;
    status: number;
}) {
    return axios.post('/api/Dishcategory/UpdateDishCategory', dishCategory);
}
