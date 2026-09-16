---
name: skill-lifecycle
description: Use whenever a procedure specific to this project has just worked, has just been followed, or has just misled — capture it as a draft, promote it on its second run, amend it, or retire it. Also at session close, to reconcile the library. Triggers: "capture this", "write a skill", a session that solved something the next one would rediscover, a skill that turned out wrong.
---

# The skill lifecycle

> status: proven · revision: 2 · captured: 2026-09-16 · last-followed: 2026-09-16

Ported from deisis r3. Capture, promotion and amendment are instructions a model reads
and can talk itself out of. Only `scripts/skills.sh` is deterministic, and it checks
the library's *shape*, never its honesty.

## When a skill is owed

Two questions, and a skill is owed only when both answer yes.

1. **Does it serve building this library?** The package, its toolchain, its verification
   — not something the author asked for in passing that happens to touch the same repo.
2. **Will it be needed again?** A command sequence with a non-obvious argument, a trap
   that cost an hour, the shape of a verification, the reason an obvious approach does
   not work here.

**A skill can be owed late.** The rule is "capture after the first success", but a
procedure that succeeded in an earlier session and was never written down is still owed
— capture it on the next run rather than waiting for a first that already happened. Say
so in the journal, so the date does not claim more than it earned.

**Difficulty is not recurrence.** An hour of pain is worth writing down only if the next
session will hit it. A one-off errand produces nothing, however long it took.

Not owed, and writing one is a defect:

- General knowledge the model already carries (`git rebase`, TypeScript syntax).
- A rule or a design decision — those go in `AGENTS.md`, never in a skill.
- A one-off request. A library nobody re-reads is rot wearing a helpful hat.

## Capture — after the first success

In the session that learned it, before closing. Never "later".

1. `mkdir -p .agents/skills/<name>` — one procedure per skill. A skill that has to
   describe two unrelated things is two skills. Name it for what it does, in English.
2. Write `SKILL.md` with the front matter below, `disable-model-invocation: true`, and
   the lifecycle line marked `draft`.
3. Write what actually happened, not what should have: the commands as run, the traps
   hit, and a **What this does not cover** section. The traps are the reason the skill
   is worth more than the model's own priors.
4. Keep it short. A draft that reads like documentation is a draft nobody follows.

A draft is not trusted and is not loaded on its own: `disable-model-invocation: true`
means the model will not pull it into context by itself. Invoke it deliberately with
`/<name>` when the situation recurs. **Cost of that choice:** the name and description
still sit in every session's context. That is the price of keeping the draft reachable
enough to ever be exercised.

## Promote — on the second run

**The second run is the verification.** Not a review, not a re-read: following the draft
to do the work again is what exposes the implicit knowledge the first write left out.

1. Follow the draft, step by step, without improvising from memory.
2. Fix everything that misled — that is the promotion's whole content.
3. Flip the lifecycle line to `proven`, bump the revision, and **remove**
   `disable-model-invocation: true` so the model may load it on its own.
4. Add the journal row saying what the second run corrected.

If the second run showed the procedure was wrong in kind rather than in detail, do not
promote: rewrite the draft at revision 2 and wait for a third run.

## Amend — every time a skill is followed

A session that used a skill leaves it changed, or leaves its `last-followed` date moved.
There is no third option, and this is the step that decays first.

**Only amend what this session witnessed.** Rewording a skill you did not exercise, or
"improving" it from the model's own judgement, is the documented failure mode of this
whole idea: Hermes Agent's in-agent learning loop is reported to self-congratulate — the
agent believes it performed well when it did not, and overwrites hand-written
customisations with worse versions (Nous Research documentation, read 2026-08-31 via web
search, not by reading the source). Nothing here prevents that except a diff a human
reads. Keep the diff small enough to read.

A skill that actively misled costs its revision: fix it in the same session that found
the gap. A stale skill is worse than none, because it is trusted.

## Retire

Deleted, not archived — the repository's history keeps it, and a directory of dead
skills is exactly the accumulation this template refuses.

- A **draft** never followed within three months: delete it. It was an anecdote.
- A **proven** skill unexercised for three months: delete it. The procedure has probably
  moved and nobody noticed.
- A skill made obsolete by tooling: delete it in the session that made it obsolete.

`scripts/skills.sh` reports both ages; it does not delete anything.

## The file's shape

```markdown
---
name: <name>
description: <when to use it, with trigger phrases>
disable-model-invocation: true   # drafts only; removed on promotion
---

# <Title>

> status: draft · revision: 1 · captured: YYYY-MM-DD · last-followed: never

...the procedure...

## What this does not cover

...

## Journal

| Rev. | Date | What changed, and why |
|---|---|---|
| 1 | YYYY-MM-DD | Captured after <what was done>. |
```

The lifecycle line is a blockquote starting with `status:` so a single `grep` answers
"what is in this library and how old is it". The status lives in the body, not the front
matter: unknown front-matter keys are ignored by some tools and warned about by others,
and the status has to be visible to a human reading the file, not only to a parser.

## Where to write, and where not

Edit skills at `.agents/skills/`, **never** at `.claude/skills/` — that path is a
symlink and writing through it is unreliable in Claude Code.

## What this does not cover

- **Measurement.** A third status, `stable`, would require success rate, tokens and
  duration compared against the same task without the skill. Nothing here measures
  anything, so `stable` is unreachable and only `draft` and `proven` exist.
- **Context bloat.** A published benchmark found sixteen of eighty-four tasks
  *regressed* once skills were loaded, with context growth up to 450% in the worst
  cases (verified August 2026 and decaying). This procedure has no defence beyond
  keeping the library small by hand.
- **Enforcement.** `SessionStart` in `.claude/settings.json` reports the library.
  `PreToolUse` runs `scripts/commit-gate.sh`: it parses `git [global-opts] commit`
  (and `bash -c 'git commit'`), refuses while `scripts/skills.sh` is red, and
  **denies if `jq` is missing**. Neither makes the *loop* run. Cursor has no reliable
  equivalent: `sessionStart` `additional_context` is dropped (Cursor bugs, 2026-09).
  Trap: a grep for adjacent `git commit` misses `git -C . commit` and fails open
  without `jq`. GNU `sed '\\b'` / `date -d` make `skills.sh` lie on macOS — parse
  with awk, and try BSD `date -j` after GNU `date -d`.
- **Rollback of the library.** `git revert` on a skill commit is the whole of it.

## Journal

| Rev. | Date | What changed, and why |
|---|---|---|
| 1 | 2026-09-16 | Ported from deisis r3 into this template. Stripped P14, D-022, spec/, Nix, and product-thesis claims. First local follow is the template conversion itself. |
| 2 | 2026-09-16 | Review: GNU sed `\\b` and `date -d` made skills.sh lie on macOS; PreToolUse grep missed `git -C` / `bash -c`. Parser is awk + GNU/BSD date; the gate is `scripts/commit-gate.sh`, fail-closed without jq. |
