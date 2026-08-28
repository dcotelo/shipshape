# Contributing

Thanks for your interest in improving this repository standard.

## What lives where

- `AGENTS.md` — agent behavior only. **No policy.** If your change adds an opinion (a required file, a review count, a tool), it belongs in `standard.yml` or a stack file, not here.
- `standard.yml` — policy: Baseline pin, profiles, tiers, house rules.
- `stacks/*.yml` — per-stack rules. To add a stack, copy the shape of an existing file: `detect` patterns, `rules` with `id`/`check` (and `tool`/`baseline` where applicable), and `required_status_checks`.

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

## Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be excellent to each other.
