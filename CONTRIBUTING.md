# Contributing

Thanks for your interest in contributing!

## Quick Setup

```bash
git clone https://github.com/axelhamil/ts-lib-template.git
cd ts-lib-template && pnpm install
pnpm check
```

Requires Node.js >= 24 (see `.nvmrc`) and pnpm (managed via `corepack`).

## Development Commands

| Command            | What it does                       |
| ------------------ | ---------------------------------- |
| `pnpm check`       | Lint + typecheck (run this first)  |
| `pnpm test`        | Run all tests                      |
| `pnpm test:watch`  | Tests in watch mode                |
| `pnpm build`       | Build (tsdown + publint + attw)    |
| `pnpm lint:fix`    | Auto-fix lint + format             |

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) — this drives automated releases via semantic-release.

```
feat: add async resolver
fix: handle empty input
docs: clarify API examples
```

`feat` bumps minor, `fix` bumps patch, `docs(readme)` bumps patch, others don't release.

## Submitting a Pull Request

1. Fork the repo and create a branch from `main`
2. Make your changes (add tests)
3. Run `pnpm check` and `pnpm test`
4. Open a PR against `main`

Biome handles all formatting and linting — no style guide to memorize.
