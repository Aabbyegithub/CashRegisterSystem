import { createSSRApp } from "vue";
import App from "./App.vue";
import NutUI from '@nutui/nutui';
import '@nutui/nutui/dist/style.css';

export function createApp() {
  const app = createSSRApp(App);
  // 全局注册NutUI组件
  app.use(NutUI);
  return {
    app,
  };
}
