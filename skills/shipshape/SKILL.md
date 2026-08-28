---
name: shipshape
description: Use when asked to audit, scaffold, or bring a repository up to standard — "audit this repo", "run shipshape", "scaffold a new repo", "check this repo against the baseline / OSPS", or any request to evaluate a repo's security and hygiene posture against a defined standard.
---

# shipshape

This skill is a launcher. **The standard is not in this file and not in your memory** — it lives in the shipshape checkout this skill directory sits in:

| File | Relative to this skill directory |
|------|----------------------------------|
| `AGENTS.md` — behavior: modes, hard rules, phases | `../../AGENTS.md` |
| `standard.yml` — all policy: Baseline pin, profiles, tiers, house rules | `../../standard.yml` |
| `stacks/*.yml` — per-stack rules | `../../stacks/` |

## Steps

1. Read `../../AGENTS.md` (resolve the path from this SKILL.md's real location; the directory may be symlinked into your skills folder). Follow it exactly — it defines AUDIT vs SCAFFOLD, the hard rules, and every phase.
2. Answer every policy question from `standard.yml` and `stacks/*.yml` only. If a rule you want to apply is not in those files, stop and say so — do not improvise policy, and do not substitute your own idea of a "repo standard".
3. AGENTS.md requires fetching the pinned OSPS Baseline checklist at the start of the run. Never audit from memory of what the controls say.
4. Arguments: `audit` or `scaffold` select the mode intent; a profile (`public-oss` | `internal`) may follow. AGENTS.md still requires detecting the mode and confirming the profile with the user.

## Red flags — stop, you are off the rails

- Answering "what does the standard require?" without having read `standard.yml` this session
- Producing a control list without having fetched the pinned Baseline checklist
- Applying a rule you cannot point to in `standard.yml` or a stack file
