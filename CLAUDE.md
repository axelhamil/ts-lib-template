# my-lib

<!-- One-line description -->

## Commands

- Build: `pnpm build`
- Test all: `pnpm test`
- Test single: `pnpm vitest run tests/<name>.test.ts`
- Test watch: `pnpm test:watch`
- Coverage: `pnpm test:coverage`
- Lint: `pnpm lint`
- Lint fix: `pnpm lint:fix`
- Typecheck: `pnpm typecheck`

## Architecture

```
src/
  index.ts    Barrel export (public API surface)
```

## Code Style

- ESM only (`"type": "module"`)
- Biome for lint + format (single quotes, 2-space indent, 100-char lines, trailing commas, semicolons)
- Files: `kebab-case.ts`
- Classes: `PascalCase`, functions: `camelCase`
- Internal imports use `.js` extension (ESM convention)
- Tests import from `../src/index.js` (public API only)
- Conventional Commits for semantic-release

## Testing

- Vitest with V8 coverage
- Tests are organized by module then by method category
