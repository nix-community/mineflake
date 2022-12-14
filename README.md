# Mineflake package repository

Mineflake can work in 2 modes: with Nix, where packages are provided by Nix itself,
and without Nix, where Mineflake itself downloads and manages dependencies via
external repositories.

This branch contains an automatically updated package repository for non-Nix mode of work.
Packages are automatically built with Nix, archived and uploaded to IPFS.

## Repository setup

Get the latest raw link to the `repo.json` file. It should look something like this:
`https://raw.githubusercontent.com/nix-community/mineflake/421319e2bbe2ed98286b02e576035ca1ad479b4a/repo.json`.

After that add the repository to your `mineflake.yml` file:

```yaml
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/421319e2bbe2ed98286b02e576035ca1ad479b4a/repo.json"

package:
  type: repository
  repo: *repo
  name: "paper"

plugins:
  - type: repository
    repo: *repo
    name: "authme"
```

This works through yaml anchors. `&repo` creates an anchor to the `repo.json` link, `*repo`
gets it and substitutes the value.
