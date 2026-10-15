# AGENTS.md

**This file is the source of truth for agent instructions.** Claude Code, Cursor, Codex
and the tools that follow the AGENTS.md convention read it directly. Add agent guidance
here and nowhere else.

Never create a `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md`, at the root or
below: Claude Code reads `AGENTS.md` only when no `CLAUDE.md` exists, so one such file
silently hides this one. What Claude Code writes on its own (auto-memory, the `#`
shortcut, any "note that down" during a session) goes here too.

## Session bootstrap

Read this file, then the skill table in § Agent configuration. Do not explore the
codebase at random.

## What this is

ESM-only TypeScript library template. Zero runtime dependencies. A starting point for a
publishable package, not an application.

## Stack

- Node `^24.11.0 || >=26.0.0`, pnpm (pinned in `packageManager`), ESM only
- TypeScript 7: `strict`, `noUncheckedIndexedAccess`, `isolatedDeclarations`,
  `verbatimModuleSyntax`, `erasableSyntaxOnly`
- tsdown (Rolldown): ESM, `.d.ts`, minify, treeshake; publint + attw on build
- Vitest 5 + V8 coverage (90% thresholds on statements, branches, functions, lines)
- Biome 2: lint + format
- release-please: Conventional Commits → release PR, then npm trusted publishing with provenance

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
src/index.ts       public barrel, the only re-export surface
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

Conventional Commits drive release-please (`release-please-config.json`,
`.release-please-manifest.json`): `feat` → minor, `fix` → patch, breaking → minor while in
`0.x`. Each push to `main` updates a release PR; merging it tags, releases and writes
`CHANGELOG.md`. Never edit `version`, the manifest or the changelog by hand. Publishing
requires removing `"private": true`, the `NPM_PUBLISH=true` repository variable and an npm
trusted publisher for `release.yml` (OIDC, no `NPM_TOKEN`). The release PR uses the Bot
GitHub App (`BOT_CLIENT_ID` variable, `BOT_PRIVATE_KEY` secret). Setup: README § Releases.

## The skill loop

Everything specific to this project that a future session would rediscover is a skill in
`.agents/skills/<name>/SKILL.md`. Two questions, both yes: does it serve *this* library,
and will it be needed again? Difficulty is not recurrence. Rules stay in this file.

Full procedure: `.agents/skills/skill-lifecycle/SKILL.md`. Read it before capturing.

- **Capture** after the first success: draft, `disable-model-invocation: true`.
- **Promote** on the second run by *following the draft*: `proven`, flag off.
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
| `.agents/skills/<name>/SKILL.md` | Procedures. Source. |
| `.claude/skills` | Symlink to `../.agents/skills`. Claude Code scans no other path. |
| `.claude/settings.json`, `.cursor/cli.json` | Permissions. Twins; edit together. Skill-loop hooks live in the Claude file alone. |
| `scripts/skills.sh` | Shape check. Must exit zero before a commit. |
| `scripts/commit-gate.sh` | Claude PreToolUse: deny `git commit` unless skills.sh is green. |
| `scripts/agents-check.sh` | Topology (no `CLAUDE.md`, skills symlink) + skills.sh. CI runs it. |

Claude Code (2.1.277 and later), Cursor and Codex load `AGENTS.md` natively. Claude Code
falls back to `AGENTS.md` only when no `CLAUDE.md` exists, and loads skills from
`.claude/skills/` only. `scripts/agents-check.sh` fails on any `CLAUDE.md` or
`CLAUDE.local.md`. Re-measure before trusting.

Edit skills at `.agents/skills/`, never through the symlink. The symlink is git mode
`120000`; Windows without `core.symlinks=true` gets a dead text file.

## What not to do

- Do not create a `CLAUDE.md` or `CLAUDE.local.md`: Claude Code would ignore this file.
- Do not commit secrets, even in examples.
- Do not mention an agent tool in commit messages.
- Do not add a skill for a one-off, or for something this file already says.
- Do not run `rm`. Use `trash <path>`.

## Scope discipline

Do what was asked. An adjacent problem is reported, not fixed in passing.

## Session close

- Run the skill loop in full. `scripts/skills.sh` must exit zero.
- Run `pnpm check`, `pnpm test`, and `pnpm build` when code or config changed.
- Update this file if tooling or a cross-cutting rule moved. Never a `CLAUDE.md`.
