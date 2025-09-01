import { createSSRApp } from "vue";
import App from "./App.vue";

import uviewPlus from 'uview-plus';
// import '../node_modules/uview-plus/theme.scss';

export function createApp() {
  const app = createSSRApp(App);
  // 全局注册uView-plus组件
  app.use(uviewPlus);
  return {
    app,
  };
}
