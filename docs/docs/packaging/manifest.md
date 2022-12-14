# Package manifest

All packages must have a manifest file. It's a `package.yml` file in the root of the package directory.

Manifest file contains information about the package. It's used to show friendly package name.

``` yaml title="package.yml"
name: "paper"
version: "1.19.3r392" # optional
manifestVersion: 1 # (1)
```

1. Manifest version. It's used to detect if the manifest file is compatible with the current version of Mineflake. Currently, only version 1 is supported.
