# repo-standard

An agent-executable repository standard. Point a coding agent at `AGENTS.md` and it audits an existing repository against the [OpenSSF OSPS Baseline](https://baseline.openssf.org/) plus house policy, or scaffolds a new repository to the same standard.

## Layout

| Path | Purpose |
|---|---|
| `AGENTS.md` | The agent prompt: modes, hard rules, phases. Contains **no policy**. |
| `standard.yml` | All policy: pinned Baseline version, profiles (`public-oss` / `internal`), tiers, house merge/review rules, required files. |
| `stacks/*.yml` | Per-stack rules (Go, TypeScript, Terraform, Docker, shell): detection patterns, required checks, CI status checks. |

## Install and run

1. Clone this repository, or vendor `AGENTS.md`, `standard.yml`, and `stacks/` into the repository you want audited.
2. Ensure the agent's environment has:
   - `git` and an authenticated `gh` CLI (repo settings are checked and applied via the GitHub API),
   - `gitleaks` for secret scanning (a missing tool is recorded `not_run`, never `pass`),
   - network access to `baseline.openssf.org` (the pinned checklist is fetched at the start of every run).
3. Start an agent session in the target repository and instruct it: *"Read the standard at AGENTS.md and follow it. Audit this repo."* — or *"Scaffold this repo."* for an empty one.
4. The agent resolves profile and tier from `standard.yml`, asks the profile's open questions, evaluates every applicable control, and writes an audit report to `../<repo>-audit.md` (never into the repo tree).

Before first use, fill the placeholders in `standard.yml` (`org.owner`, `shared_workflows_ref`) and edit the `house:` section to taste — it is policy, not standard.

## Tests

CI runs `yamllint` over all YAML files and verifies that every path `AGENTS.md` references exists in the tree:

```sh
python3 -m pip install yamllint
yamllint .
./.github/scripts/check-refs.sh
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security issues: see [SECURITY.md](SECURITY.md). Maintainer: [@dcotelo](https://github.com/dcotelo).
