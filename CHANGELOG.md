# Changelog

All notable changes to this project will be documented in this file.

We do not have a specific release cycle for new versions, we release
new versions as soon as we feel it is necessary.

## Format

```text
## {version} - {release date}

- {change} ([#{pull request/issue number}]({link}))
```

## Unreleased

- CoreProtect now builds with Nix ([#34](https://github.com/nix-community/mineflake/pull/34))

## 0.2.2 - 22 Dec 2022

- Parallel package vendoring ([#13](https://github.com/nix-community/mineflake/pull/13))
- Split common module into separate files ([#14](https://github.com/nix-community/mineflake/pull/14))
- Fix CHANGELOG.md links to PRs ([#15](https://github.com/nix-community/mineflake/pull/15))
- Run CI/CD checks only on changed files ([#16](https://github.com/nix-community/mineflake/pull/16))
- Use import-cargo instead of naersk ([#18](https://github.com/nix-community/mineflake/pull/18))
- Add Spiget/Spigot repository support ([#19](https://github.com/nix-community/mineflake/pull/19))
- Refactor code to use `clippy` ([#21](https://github.com/nix-community/mineflake/pull/21)) _Not fully compatible with previous versions_
- Update `nixpkgs` from `2022-12-08` to `2022-12-20` ([#32](https://github.com/nix-community/mineflake/pull/32))

## 0.2.1 - 15 Dec 2022

- Fix yaml anchors parsiong in bungee config

## 0.2 - 15 Dec 2022

- **Repository moved to nix-community GitHub organization**
- Updated contribution guides ([#57](https://git.frsqr.xyz/firesquare/mineflake/pulls/57))
- Relicense from GPL3 to MIT ([#57](https://git.frsqr.xyz/firesquare/mineflake/pulls/57))
- Rewrite main logic from Nix to Rust ([#9](https://github.com/nix-community/mineflake/pull/9)) **BREAKING CHANGE**

## 0.1 - 2 Sep 2022

- First release
