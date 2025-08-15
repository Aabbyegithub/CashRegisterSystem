
import axios from '../common/axios';

// 获取菜品列表
export function getDishList(dishname:string,type:string, page: number = 0, size: number = 10) {
    return axios.get('/api/Dish/GetDishList', { params: {dishname,type, page, size } });
}

//获取菜品分类
export function getDishCategoryList() {
    return axios.get('/api/Dishcategory/GetAllDishCategoryList');
}

// 添加菜品
export function addDish(data: {
    category_id: string;
    dish_name: string;
    price: number;
    member_price: number;
    is_recommend: number;
    is_temporary: number;
    description: string;
    image_url: string;
    status: number;
    cooking_time: number;
    store_id: null;
}) {
    return axios.post('/api/Dish/AddDish', data);
}

// 删除菜品
export function deleteDish(ids: number[]) {
    return axios.post('/api/Dish/DeleteDish', ids);
}

// 更新菜品
export function updateDish(data: {
    dish_id: number;
    category_id: string;
    dish_name: string;
    price: number;
    member_price: number;
    is_recommend: number;
    is_temporary: number;
    description: string;
    image_url: string;
    status: number;
    cooking_time: number;
    store_id: null;
}) {
    return axios.post('/api/Dish/UpdateDish', data);
}
