import { defineConfig } from 'tsdown';

export default defineConfig({
  entry: ['src/index.ts'],
  format: 'esm',
  dts: { isolatedDeclarations: true },
  sourcemap: true,
  clean: true,
  minify: true,
  treeshake: true,
  target: 'es2024',
  publint: true,
  attw: { profile: 'esm-only' },
});
