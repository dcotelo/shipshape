<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1b27,50:414868,100:7aa2f7&height=200&section=header&text=shipshape&fontSize=52&fontColor=c0caf5&animation=fadeIn&fontAlignY=35&desc=Bring%20any%20repo%20up%20to%20standard%20%E2%80%94%20agent-executed%2C%20OSPS%20Baseline%20inside&descSize=16&descAlignY=55" width="100%" alt="shipshape" />

<div align="center">

[![CI](https://img.shields.io/github/actions/workflow/status/dcotelo/shipshape/ci.yml?style=for-the-badge&label=CI&labelColor=1a1b27&color=7aa2f7)](https://github.com/dcotelo/shipshape/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-1a1b27?style=for-the-badge&logoColor=7aa2f7&color=414868)](LICENSE)
[![OSPS Baseline](https://img.shields.io/badge/OSPS_Baseline-2026.02.19-1a1b27?style=for-the-badge&color=7aa2f7)](https://baseline.openssf.org/)

</div>

**shipshape** is an agent-executable repository standard: point a coding agent at `AGENTS.md` and it **audits** an existing repository against the [OpenSSF OSPS Baseline](https://baseline.openssf.org/) plus your house policy, or **scaffolds** a new repository to the same standard. All policy lives in YAML — the prompt contains none.

The security control set is the OSPS Baseline; the house rules align with the [OWASP CI/CD Security](https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html), [GitHub Actions Security](https://cheatsheetseries.owasp.org/cheatsheets/GitHub_Actions_Security_Cheat_Sheet.html), and [Software Supply Chain Security](https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html) cheat sheets (SHA-pinned actions, least-privilege workflow tokens, SCM hardening), and the standard adds contributor-side [git client hardening](CONTRIBUTING.md#recommended-local-git-configuration) that platform controls cannot reach.

---

## How it works

| Path | Purpose |
|------|---------|
| `AGENTS.md` | The agent prompt: modes, hard rules, phases. Contains **no policy**. |
| `standard.yml` | All policy: pinned Baseline version, profiles (`public-oss` / `internal`), tiers, house merge/review rules, required files. |
| `stacks/*.yml` | Per-stack rules (Go, TypeScript, Terraform, Docker, shell): detection patterns, required checks, CI status checks. |

The agent resolves profile and tier, fetches the pinned Baseline checklist (never from memory), evaluates every applicable control with evidence, and writes the audit report to `../<repo>-audit.md` — never into the repo tree.

---

## What a run looks like

```mermaid
flowchart LR
    A[Detect mode<br/>AUDIT / SCAFFOLD] --> B[Resolve profile,<br/>tier & stacks]
    B --> C[Fetch pinned<br/>Baseline checklist]
    C --> D[Evaluate every control<br/>with evidence]
    D --> E[Report to<br/>../repo-audit.md]
    E --> F{You pick<br/>the fixes}
    F --> G[Fix in commits<br/>grouped by concern]
    G --> H[Apply GitHub config<br/>rulesets in evaluate mode]
```

1. **Detect mode** — repo with commits → AUDIT; empty → SCAFFOLD. Announced, never assumed.
2. **Resolve profile, tier, stacks** — profile is asked every run, never inferred from visibility; stacks are detected from the tree and confirmed.
3. **Fetch the pinned Baseline** — control IDs come from the versioned checklist, verbatim, never from model memory.
4. **Evaluate** — every control records `pass | fail | n/a | not_run` with the file, setting, or command output that decided it. A missing scanner is `not_run`, never `pass`.
5. **Report, then stop** — in AUDIT mode nothing changes until you choose what to fix.
6. **Fix and configure** — separate commits per concern; GitHub rulesets start in `evaluate` enforcement so nothing breaks mid-flight.

The agent never invents a license, security contact, or owner; never makes a repo public; never force-pushes or rewrites history. Those are your decisions — it asks.

---

## Install and run

**As a Claude Code plugin (recommended):**

```
/plugin marketplace add dcotelo/shipshape
/plugin install shipshape@shipshape
```

Then in any repository: `/shipshape audit` (or `/shipshape scaffold`). The repo serves as its own single-plugin marketplace; the whole tree is installed, so the skill launcher and the standard files travel together and the standard stays single-source (the skill contains no policy). Update with `/plugin marketplace update shipshape`.

**As a symlinked skill (development):**

```sh
git clone https://github.com/dcotelo/shipshape.git ~/dev/shipshape
ln -s ~/dev/shipshape/skills/shipshape ~/.claude/skills/shipshape
```

`git pull` in the clone keeps the skill current.

**Manually:**

1. Clone this repository, or vendor `AGENTS.md`, `standard.yml`, and `stacks/` into the repository you want audited.
2. Ensure the agent's environment has:
   - `git` and an authenticated `gh` CLI (repo settings are checked and applied via the GitHub API),
   - `gitleaks` for secret scanning (a missing tool is recorded `not_run`, never `pass`),
   - network access to `baseline.openssf.org` (the pinned checklist is fetched at the start of every run).
3. Start an agent session in the target repository and instruct it:

   > Read the standard at AGENTS.md and follow it. Audit this repo.

   — or *"Scaffold this repo."* for an empty one.

4. Answer the profile's open questions (license, security contact, owners); the agent evaluates, reports, and fixes only what you approve.

Before first use, fill the placeholders in `standard.yml` (`org.owner`, `shared_workflows_ref`) and edit the `house:` section to taste — it is policy, not standard.

---

## Tests

CI runs `yamllint` over all YAML files, verifies that every path `AGENTS.md` references exists in the tree, and lints the scripts:

```sh
python3 -m pip install yamllint
yamllint --strict .
./.github/scripts/check-refs.sh
shellcheck .github/scripts/*.sh
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — DCO sign-off required. Security issues: [SECURITY.md](SECURITY.md).

<div align="center">

**Maintained by [@dcotelo](https://github.com/dcotelo)** · [dcotelo.dev](https://dcotelo.dev)

</div>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:7aa2f7,50:414868,100:1a1b27&height=120&section=footer" width="100%" alt="" />
