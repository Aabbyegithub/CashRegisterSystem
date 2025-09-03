import axios from '../common/axios';

export interface TimerTask {
  id: number;
  timerName: string;
  timerClass: string;
  addUser: number;
  orgId: number;
  isStart: number;
  isDelete: number;
  corn: string;
  startNumber: number;
}

export interface TimerTaskListParams {
  pageIndex: number;
  pageSize: number;
  jobName?: string;
}

export function getTimerTaskList(params: TimerTaskListParams) {
  return axios.get('/api/Task/GetTimerTaskList', { params });
}

export function getTimerTaskDetail(taskId: number) {
  return axios.get('/api/Task/GetTimerTaskDetail', { params: { taskId } });
}

export function addTimerTask(data: TimerTask) {
  return axios.post('/api/Task/AddTimerTask', data);
}

export function updateTimerTask(data: TimerTask) {
  return axios.post('/api/Task/UpdateTimerTask', data);
}

export function deleteTimerTask(taskId: number) {
  return axios.post('/api/Task/DeleteTimerTask', null, { params: { taskId } });
}

export function startTask(taskId: number) {
  return axios.post('/api/Task/StartTask', null, { params: { taskId } });
}

export function stopTask(taskId: number) {
  return axios.post('/api/Task/StopTask', null, { params: { taskId } });
}
export function AddTask(jobId: number,jobName:string,cronExpression:string) {
  return axios.post('/api/Task/AddJob', null, { params: { jobId, jobName,cronExpression} });
}

export function pauseJob(taskId: number) {
  return axios.post('/api/Task/PauseJob', null, { params: { taskId } });
}

export function resumeJob(taskId: number) {
  return axios.post('/api/Task/ResumeJob', null, { params: { taskId } });
}
