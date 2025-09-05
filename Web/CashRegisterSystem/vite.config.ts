import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import copy from 'vite-plugin-copy'; // 引入插件

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue(),
    copy({
      targets: [
        {
          src: 'src/assets/**/*.{png,jpg,jpeg,gif}', // 匹配 src/assets 下所有图片格式
          dest: 'dist/assets', // 复制到 dist/assets（与后端路径替换后的目标目录一致）
          // 可选：保持原文件结构（如 src/assets/icons/xxx.png → dist/assets/icons/xxx.png）
          // flatten: false 
        }
      ]
    })],
})
