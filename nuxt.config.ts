export default defineNuxtConfig({
  extends: 'nebula',
  devtools: { enabled: true },
  ssr: false,
  srcDir: './src',
  css: [
    '@/assets/main.css',
  ],
  vite: {
    // Better support for Tauri CLI output
    clearScreen: false,
    // Enable environment variables
    // Additional environment variables can be found at
    // https://tauri.app/2/reference/environment-variables/
    envPrefix: ['VITE_', 'TAURI_'],
    server: {
      strictPort: true,
      hmr: {
        protocol: 'ws',
        host: '0.0.0.0',
        port: 5183,
      },
    },
  },
});