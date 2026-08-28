# Contributing

Thanks for your interest in improving this repository standard.

## What lives where

- `AGENTS.md` — agent behavior only. **No policy.** If your change adds an opinion (a required file, a review count, a tool), it belongs in `standard.yml` or a stack file, not here.
- `standard.yml` — policy: Baseline pin, profiles, tiers, house rules.
- `stacks/*.yml` — per-stack rules. To add or extend a stack, follow the schema and design rules in [stacks/README.md](stacks/README.md).

## Process

1. Open an issue describing the change before large edits — policy changes deserve discussion.
2. Fork and branch from `main`.
3. Make your change. Run the checks locally:
   ```sh
   python3 -m pip install yamllint
   yamllint .
   ./.github/scripts/check-refs.sh
   ```
4. Open a pull request using the template. CI must pass.

## Developer Certificate of Origin (DCO)

Every commit must be signed off, asserting the [Developer Certificate of Origin](https://developercertificate.org/):

```sh
git commit -s
```

This adds a `Signed-off-by:` trailer certifying you have the right to submit the work under this repository's license (Apache-2.0). Pull requests with unsigned commits will be asked to amend.

## Recommended local git configuration

The repository can enforce platform-side controls (rulesets, CI, signed-off
commits); it cannot see your git client. These settings close the client-side
gaps — they complement the [OWASP CI/CD Security](https://cheatsheetseries.owasp.org/cheatsheets/CI_CD_Security_Cheat_Sheet.html)
and [Software Supply Chain Security](https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html)
cheat sheets, which stop at the SCM/pipeline layer. Recommended, not required:

```sh
git config --global transfer.fsckObjects true   # reject malformed objects on transfer
git config --global fetch.fsckObjects true
git config --global receive.fsckObjects true
git config --global user.useConfigOnly true     # fail if identity unset — no wrong-email commits
git config --global protocol.file.allow user    # limit file:// submodule tricks (CVE-2022-39253 class)
git config --global protocol.ext.allow never    # block ext:: transport (command-execution vector)
git config --global commit.gpgsign true         # sign commits; gpg.format=ssh for SSH signing
git config format.signOff true                  # per-repo: DCO trailer added automatically
git config --global pull.ff only                # no surprise merge commits
```

The three with the highest value if you only pick some: `transfer.fsckObjects`,
`user.useConfigOnly`, `protocol.file.allow`.

## Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be excellent to each other.
