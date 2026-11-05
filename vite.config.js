import react from '@vitejs/plugin-react'
import inertia from '@inertiajs/vite'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    tailwindcss(),
    RubyPlugin(),
    inertia(),
    react(),
  ],
  server: {
    // In docker compose, Rails reaches the dev server at http://vite:3036.
    allowedHosts: ['vite', 'localhost'],
    // The browser connects to the dev server directly for hot reload.
    hmr: { host: 'localhost', clientPort: 3036 },
  },
})
