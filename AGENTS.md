# AGENTS.md

**This file is the source of truth for agent instructions.** Every agent working here
reads it — Claude Code through the `@AGENTS.md` import in `CLAUDE.md`, Cursor and the
tools that follow the AGENTS.md convention directly. Add agent guidance here and nowhere
else: `CLAUDE.md` is a pointer. Anything written there instead is seen by one tool and
drifts without a signal.

## Session bootstrap

Read this file, then the skill table in § Agent configuration. Do not explore the
codebase at random.

## What this is

ESM-only TypeScript library template. Zero runtime dependencies. A starting point for a
publishable package, not an application.

## Stack

- Node `^24.11.0 || >=26.0.0`, pnpm (pinned in `packageManager`), ESM only
- TypeScript 7 — `strict`, `noUncheckedIndexedAccess`, `isolatedDeclarations`,
  `verbatimModuleSyntax`, `erasableSyntaxOnly`
- tsdown (Rolldown) — ESM, `.d.ts`, minify, treeshake; publint + attw on build
- Vitest 5 + V8 coverage (90% thresholds on statements, branches, functions, lines)
- Biome 2 — lint + format
- semantic-release — Conventional Commits → npm publish with provenance

## Commands

| Goal | Command |
|---|---|
| Install | `pnpm install` |
| Lint + typecheck | `pnpm check` |
| Test all | `pnpm test` |
| Test one file | `pnpm vitest run tests/<name>.test.ts` |
| Coverage | `pnpm test:coverage` |
| Build | `pnpm build` |
| Skill library shape | `pnpm skills` |
| Agent topology | `pnpm agents-check` |

## Architecture

```
src/index.ts       public barrel — the only re-export surface
tests/*.test.ts    import from `../src/index.js` only
```

Nothing else is a public API. No barrel re-exports beyond `src/index.ts`.

## Cross-cutting rules

### 1. Explicit types on public exports
Why: `isolatedDeclarations` is on; tsdown emits `.d.ts` from signatures, not inference.
Verify: `pnpm typecheck` and `pnpm build`.
Trap: exporting a function whose return type is inferred.

### 2. Type-only imports use `import type`
Why: `verbatimModuleSyntax`.
Verify: `pnpm lint`.
Trap: a value import of a type.

### 3. Internal imports use the `.js` extension
Why: ESM convention under TypeScript bundler resolution.
Verify: `pnpm typecheck`.
Trap: importing `./foo.ts` or omitting the extension.

### 4. Tests hit the public API only
Why: the published surface is `src/index.ts`; testing internals freezes private shape.
Verify: every test file imports from `../src/index.js`.
Trap: `import { x } from '../src/foo.js'`.

### 5. Coverage floors are 90%
Why: a template that ships untested code teaches the wrong default.
Verify: `pnpm test:coverage`.
Trap: lowering a threshold to land a change.

### 6. Delete via trash, never rm
Why: `rm` is irreversible. `trash` / `trash-put` (trash-cli) send files to the
FreeDesktop trash, recoverable with `trash-restore`.
Verify: deny lists in `.claude/settings.json` and `.cursor/cli.json` (twins).
Trap: `unlink`, `find -delete`, `trash-rm` (permanent). `trash-empty` asks on
Claude and is denied on Cursor.

## Code style

Biome: single quotes, 2-space indent, 100-char lines, trailing commas, semicolons.
Files: `kebab-case.ts`. Classes: `PascalCase`. Functions: `camelCase`.
No inline comments unless the WHY is non-obvious. Explicit `vitest` imports, no globals.

## Releases

Conventional Commits drive semantic-release: `feat` → minor, `fix` → patch,
`docs(readme)` → patch. Releases run on push to `main`. Publishing requires removing
`"private": true` and setting `NPM_TOKEN` + `GH_TOKEN`.

## The skill loop

Everything specific to this project that a future session would rediscover is a skill in
`.agents/skills/<name>/SKILL.md`. Two questions, both yes: does it serve *this* library,
and will it be needed again? Difficulty is not recurrence. Rules stay in this file.

Full procedure: `.agents/skills/skill-lifecycle/SKILL.md`. Read it before capturing.

- **Capture** after the first success — draft, `disable-model-invocation: true`.
- **Promote** on the second run by *following the draft* — `proven`, flag off.
- **Amend or retire** every session that follows a skill: change it, or move
  `last-followed`. Stale 90 days → delete, do not archive. Only amend what this session
  witnessed.

Hooks in `.claude/settings.json` inject the library at `SessionStart`. `PreToolUse`
runs `scripts/commit-gate.sh`, which refuses `git commit` (including `git -C` /
`git -c` / `bash -c 'git commit'`) while `scripts/skills.sh` is red, and denies if
`jq` is missing. They do not make the loop run.
Cursor has no reliable equivalent (`sessionStart` `additional_context` is dropped as of
2026-09). The loop holds here, in this file.

Say the limit: `scripts/skills.sh` checks shape, never truth, never whether a date was
earned.

## Agent configuration

| Path | Role |
|---|---|
| `AGENTS.md` | Instructions. Source, read by every agent. |
| `CLAUDE.md` | `@AGENTS.md` and a write ban. Pointer. |
| `.agents/skills/<name>/SKILL.md` | Procedures. Source. |
| `.claude/skills` | Symlink to `../.agents/skills`. Claude Code scans no other path. |
| `.claude/settings.json`, `.cursor/cli.json` | Permissions. Twins; edit together. Skill-loop hooks live in the Claude file alone. |
| `scripts/skills.sh` | Shape check. Must exit zero before a commit. |
| `scripts/commit-gate.sh` | Claude PreToolUse: deny `git commit` unless skills.sh is green. |
| `scripts/agents-check.sh` | Topology + skills.sh. CI runs it. |

Measured 2026-09-16 from deisis (2026-08-31, Claude Code 2.1.251 / cursor-agent
2026.08.25) and the agent-agnostic matrix (2026-09-02): Claude Code loads `CLAUDE.md`
and `.claude/skills/` only; Cursor loads `AGENTS.md` natively. Re-measure before trusting.

Edit skills at `.agents/skills/`, never through the symlink. The symlink is git mode
`120000`; Windows without `core.symlinks=true` gets a dead text file.

## What not to do

- Do not write project instructions in `CLAUDE.md`.
- Do not commit secrets, even in examples.
- Do not mention an agent tool in commit messages.
- Do not add a skill for a one-off, or for something this file already says.
- Do not run `rm`. Use `trash <path>`.

## Scope discipline

Do what was asked. An adjacent problem is reported, not fixed in passing.

## Session close

- Run the skill loop in full. `scripts/skills.sh` must exit zero.
- Run `pnpm check`, `pnpm test`, and `pnpm build` when code or config changed.
- Update this file if tooling or a cross-cutting rule moved. Never `CLAUDE.md`.
