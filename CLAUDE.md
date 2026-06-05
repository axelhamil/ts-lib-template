# ts-lib-template

<!-- One-line description of your library -->

ESM-only TypeScript library template. Zero runtime dependencies.

## Commands

- Build: `pnpm build` (tsdown → `dist/`, runs publint + attw)
- Test all: `pnpm test`
- Test single: `pnpm vitest run tests/<name>.test.ts`
- Test watch: `pnpm test:watch`
- Coverage: `pnpm test:coverage` (90% thresholds, all metrics)
- Typecheck: `pnpm typecheck`
- Lint: `pnpm lint` / fix: `pnpm lint:fix`
- Check (lint + typecheck): `pnpm check`

## Architecture

```
src/
  index.ts    Barrel export (public API surface)
```

## Toolchain

- Node >= 24, pnpm (via corepack), ESM only (`"type": "module"`)
- TypeScript 6 — `strict`, `noUncheckedIndexedAccess`, `isolatedDeclarations`, `verbatimModuleSyntax`, `erasableSyntaxOnly`
- tsdown (Rolldown) for build + `.d.ts` + minify + treeshake; `publint` + `attw` validate the published package
- Vitest 4 + V8 coverage
- Biome 2 for lint + format
- semantic-release (Conventional Commits) → npm publish with provenance

## Code Style

- Biome: single quotes, 2-space indent, 100-char lines, trailing commas, semicolons
- Files: `kebab-case.ts` · Classes: `PascalCase` · functions: `camelCase`
- `verbatimModuleSyntax` is on → use `import type` for type-only imports
- `isolatedDeclarations` is on → all public exports need explicit return/value types
- Internal imports use `.js` extension (ESM convention)
- Tests import from `../src/index.js` (public API only)
- No barrel re-exports beyond `src/index.ts`; no inline comments unless the WHY is non-obvious

## Testing

- Vitest with V8 coverage, thresholds 90% (statements/branches/functions/lines)
- Tests in `tests/**/*.test.ts`, organized by module then by method category
- Explicit imports from `vitest` (no globals)

## Releases

- Conventional Commits drive semantic-release: `feat` → minor, `fix` → patch, `docs(readme)` → patch
- Releases run on push to `main` via `.github/workflows/release.yml`
- Publishing requires removing `"private": true` and setting `NPM_TOKEN` + `GH_TOKEN` secrets
