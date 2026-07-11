import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig(({ mode }) => ({
  plugins: [react(), tailwindcss()],
  // GitHub Pages serves the app from /target334/ — built with `vite build --mode pages`.
  base: mode === 'pages' ? '/target334/' : '/',
  server: { port: 5173, strictPort: true },
}));
