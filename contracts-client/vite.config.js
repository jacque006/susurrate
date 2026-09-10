import { defineConfig } from 'vite';

export default defineConfig({
    build: {
        lib: {
            formats: ['es'], 
            entry: 'src/index.ts',
            name: 'contracts-client',
            fileName: (format, entryName) => `contracts-client-${entryName}.${format}.js`,
        },
        rollupOptions: {
            output: {
                manualChunks(id) {
                    if (id.includes('node_modules')) {
                        return 'vendor';
                    }
                    return undefined; 
                },
                entryFileNames: '[name]-[hash].js', 
                chunkFileNames: '[name]-[hash].js',
            },
        },
        sourcemap: true
    },
});