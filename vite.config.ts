import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    include: ['@stripe/stripe-js'],
    exclude: ['lucide-react'],
  },
  define: {
    // Ensure environment variables are available at build time
    'process.env': process.env,
  },
  server: {
    // Proxy Edge Functions during development
    proxy: {
      '/functions': {
        target: process.env.VITE_SUPABASE_URL || 'https://kazatbfpvpalauoshzti.supabase.co',
        changeOrigin: true,
        secure: true,
        headers: {
          'Authorization': `Bearer ${process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvYXVyZmljeGNwemJxaGFlcHRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0MTM2NzAsImV4cCI6MjA3NDk4OTY3MH0.i30uYs_5b_F0GHUEdu9uQ67hHgEaOLcNIbjfMbQ5vh8'}`,
        },
      },
    },
  },
});
