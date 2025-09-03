import axios from '../common/axios';

export interface Supplier {
  supplier_id: number;
  supplier_name: string;
  contact_person: string;
  contact_phone: string;
  address: string;
  status: number;
}

export interface SupplierListParams {
  pageIndex: number;
  pageSize: number;
  name?: string;
  status?: number;
}

export function getSupplierList(params: SupplierListParams) {
  return axios.get('/api/Supplier/GetSupplierList', { params });
}

export function getAllSupplierList() {
  return axios.get('/api/Supplier/GetAllSupplierList');
}

export function getSupplierDetail(supplierId: number) {
  return axios.get('/api/Supplier/GetSupplierDetail', { params: { supplierId } });
}

export function addSupplier(data: Supplier) {
  return axios.post('/api/Supplier/AddSupplier', data);
}

export function updateSupplier(data: Supplier) {
  return axios.post('/api/Supplier/UpdateSupplier', data);
}

export function deleteSupplier(supplierId: number) {
  return axios.post('/api/Supplier/DeleteSupplier', null, { params: { supplierId } });
}
