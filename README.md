# ts-lib-template

<!-- One-line description of your library -->

[![TypeScript](https://img.shields.io/badge/TypeScript-strict-blue)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-0-brightgreen)](#)

<!-- After renaming to <pkg> and publishing (public repo), re-add:
[![NPM Version](https://img.shields.io/npm/v/<pkg>)](https://www.npmjs.com/package/<pkg>)
[![CI](https://img.shields.io/github/actions/workflow/status/<owner>/<pkg>/ci.yml)](https://github.com/<owner>/<pkg>/actions)
[![NPM Downloads](https://img.shields.io/npm/dm/<pkg>)](https://npmtrends.com/<pkg>)
[![Bundle size](https://deno.bundlejs.com/badge?q=<pkg>&treeshake=[*])](https://bundlejs.com/?q=<pkg>)
-->

A batteries-included TypeScript library template. ESM-only, type-safe, zero-config publishing.

## Stack

- **TypeScript 6** — `strict` + `noUncheckedIndexedAccess` + `isolatedDeclarations` + `verbatimModuleSyntax`
- **[tsdown](https://tsdown.dev)** — Rolldown-powered bundler (ESM, `.d.ts`, minify, treeshake) with built-in [`publint`](https://publint.dev) + [`are-the-types-wrong`](https://arethetypeswrong.github.io)
- **[Vitest 4](https://vitest.dev)** — tests + V8 coverage (90% thresholds)
- **[Biome 2](https://biomejs.dev)** — lint + format in one fast pass
- **[semantic-release](https://semantic-release.gitbook.io)** — automated versioning & npm publish with provenance

## Using this template

1. Click **Use this template** on GitHub (or clone).
2. Find & replace `ts-lib-template` → your package name across the repo.
3. Update the description, `author`, and `repository` in `package.json`.
4. Remove `"private": true` from `package.json` when ready to publish.
5. Add the `NPM_TOKEN` and `GH_TOKEN` secrets in GitHub for releases.
6. Write your code in `src/`, export it from `src/index.ts`.

## Install

```bash
pnpm add ts-lib-template  # or npm i ts-lib-template
```

## Quick Start

```typescript
import {} from 'ts-lib-template';
```

## Scripts

| Command              | What it does                          |
| -------------------- | ------------------------------------- |
| `pnpm build`         | Bundle to `dist/` (+ publint + attw)  |
| `pnpm test`          | Run tests                             |
| `pnpm test:coverage` | Tests with coverage report            |
| `pnpm typecheck`     | `tsc --noEmit`                        |
| `pnpm lint`          | Biome check                           |
| `pnpm lint:fix`      | Biome check + autofix                 |
| `pnpm check`         | Lint + typecheck                      |

## Architecture

```
src/
  index.ts     # public barrel — export everything from here
```

## LLM / AI Integration

Ships with [llms.txt](https://llmstxt.org/) files for AI-assisted development:

- **`llms.txt`** — Concise index following the llms.txt standard
- **`llms-full.txt`** — Complete API reference optimized for LLM context windows

Compatible with [Context7](https://context7.com/) and any tool supporting the llms.txt standard.

## Compatibility

- Node.js >= 24
- TypeScript >= 6.0
- ESM only

## License

MIT
