# Writing a stack file

A stack file teaches the agent two things about one technology: what to
**check** in an existing repo (AUDIT) and what to **generate** in a new one
(SCAFFOLD). One YAML file per stack, in this directory. Several stacks can
apply to the same repo — `atlantis.yml` deliberately loads alongside
`terraform.yml` and adds only what the base stack lacks. Don't duplicate a
rule another stack already carries.

## Schema

```yaml
# One-line comment saying what the stack covers and any scope caveats.
detect: ["go.mod"]             # glob patterns; any match loads the stack (AUDIT only —
                               # SCAFFOLD selects stacks in the interview)

files:                         # optional: files whose absence is an audit fail
  - .golangci.yml

rules:
  - id: kebab-case-id          # stable; report rows reference it
    check: "one sentence: the condition that passes, checkable from the repo tree"
    tool: golangci-lint        # optional: the tool that decides it — if the tool is
                               # absent at audit time the result is not_run, never pass
    baseline: [OSPS-VM-05.03]  # optional: Baseline control IDs this rule serves, verbatim
    solo_exempts: [approved]   # optional: requirement waived when
                               # house.ruleset.solo_admin_bypass is true

required_status_checks: ["build", "test"]   # merged into the ruleset's required checks

scaffold:                      # omit nothing silently: a stack that generates nothing
  ask: [module_path]           #   declares `scaffold: none` with a comment saying why
  files:
    - path: go.mod
      content: "declarative content requirement — what the file must satisfy, not a template"
  prove: "go build ./..."      # run during SCAFFOLD's Phase 2 re-check; must pass
```

## Design rules

1. **Every rule must be decidable.** Either checkable from the repo tree /
   GitHub API, or explicitly a *documentation check* — a server-side or
   out-of-repo setting the repo can only document (see the fork-PR and
   webhook rules in `atlantis.yml`). A documentation check records `not_run`
   when nothing documents it. Never write a rule that passes on absence of
   evidence.
2. **`check` text is the contract.** The agent quotes it and records evidence
   against it. Write the passing condition, not advice.
3. **Baseline IDs verbatim** (`OSPS-XX-NN.NN`), only where the rule genuinely
   serves the control.
4. **Scaffold content is declarative.** Requirements the generated file must
   meet — never literal templates, and never example values that look real
   (rule 6: nothing secret-shaped). Values expensive to get wrong (module
   paths, backends, image digests) go in `ask`, not defaults.
5. **`prove` must run offline-ish.** Prefer commands that work without
   credentials (`terraform validate` after `init -backend=false`); name the
   limitation in a comment when full validation needs a live system.
6. **Keep it small.** A stack file is policy, not a tutorial. If a rule needs
   a paragraph, its scope is wrong.

New stack files are picked up automatically: `detect` drives AUDIT loading,
CI (`yamllint --strict`, `check-refs.sh`) validates the file, and the
interview offers the stack for SCAFFOLD. Propose new stacks via the proposal
issue template.
