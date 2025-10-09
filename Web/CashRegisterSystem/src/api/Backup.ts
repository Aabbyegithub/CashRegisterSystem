import axios from '../common/axios';

// 获取备份列表
export function getBackupList(page = 1, size = 10, name = '') {
  return axios.get('/api/DataBackUp/GetBackUpList', {
    params: { page, size, name }
  });
}

// 新增备份（GET请求，无参数）
export function addBackup() {
  return axios.get('/api/DataBackUp/AddBackUp');
}