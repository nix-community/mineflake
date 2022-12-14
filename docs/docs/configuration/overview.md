# Configuration overview

In previous page we created a simple paper server with LuckPerms plugin. Let's break down this example and see how it works.

## Yaml anchors

Yaml anchors are used to avoid repeating the same value multiple times. In this example we use it to avoid repeating the repo url.

You can create an anchor by writing `&anchorname`:

``` yaml linenums="1" hl_lines="2" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

We write here `defaults` only for readability. It's not required.

Then you can use it by writing `*anchorname`:

``` yaml linenums="1" hl_lines="14" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

## Type

``` yaml linenums="1" hl_lines="4" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

...
```

Type of server to create. Different types have different options, but they all have shared options (package, plugins, configs).
For example, `spigot` type has `permissions` config option, but others doesn't.

Different types require different packages (e.g. `spigot` requires `package.jar` in the package).

## Command

``` yaml linenums="1" hl_lines="6" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper
```

Command to run the server. `{}` will be replaced with the path to the package.

Used by `mineflake run` command.

## Package

``` yaml linenums="1" hl_lines="8-10" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

Package is a server jar file. It can be downloaded from a repository or from a local path.

Package type can be `local`, `remote` or `repository`.

### Local

``` yaml linenums="1"
package:
  type: local
  path: /path/to/paper
```

Package is located in a local directory path.

### Remote

``` yaml linenums="1"
package:
  type: remote
  url: https://w3s.link/ipfs/bafybeidcg37nfcqgxgyrpq2z4h2ng7vabbmzyp7xtfzwuew46kzujn6hwu/archive.zip
```

Package zip is downloaded from a remote url and extracted.

All remote packages are cached for better performance.

### Repository

``` yaml linenums="1"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

package:
  type: repository
  repo: *repo
  name: paper
```

Repository is a json file with a list of packages. Package zip url is downloaded from a repository and extracted.

Repository and it's packages are cached for better performance.

## Plugins

``` yaml linenums="1" hl_lines="12-15" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

Plugins is a list of plugins to install. Each plugin is a package and have the same options as above.

## Configs

``` yaml linenums="1" hl_lines="17-24" title="mineflake.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

Configs is a list of server configs to create. Configs can be `raw`, `yaml`, `json`, `mergeyaml` or `mergejson`.

### Raw

``` yaml linenums="1"
configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

Raw config is a file with a content.

### YAML

``` yaml linenums="1"
configs:
  - type: yaml
    path: some/config.yml
    content:
      key: "value"
      list:
        - "item1"
        - "item2"
```

YAML config is a file with a YAML content.

### JSON

``` yaml linenums="1"
configs:
  - type: json
    path: ops.json
    content:
      - "someplayer"
      - "anotherplayer"
```

JSON config is a file with a JSON content.

### MergeYAML

``` yaml linenums="1"
configs:
  - type: yaml
    path: some/config.yml
    content:
      key: "value"
      list:
        - "item1"
        - "item2"
  - type: mergeyaml
    path: some/config.yml
    content:
      bar: "baz"
      list:
        - "foo"
        - "bar"
```

MergeYAML config updates previous YAML config with a new content.

In this example, `some/config.yml` will have the following content:

``` yaml
key: "value"
bar: "baz"
list:
  - "foo"
  - "bar"
```

### MergeJSON

``` yaml linenums="1"
configs:
  - type: json
    path: ops.json
    content:
      - "someplayer"
      - "anotherplayer"
  - type: mergejson
    path: ops.json
    content:
      - "someplayer"
      - "anotherplayer"
      - "yetanotherplayer"
```

MergeJSON config updates previous JSON config with a new content, like MergeYAML.

??? warning "MergeYAML and MergeJSON must be pure"

    MergeYAML and MergeJSON configs require path to exist in configs list or in packages.

    For example, this config will fail:

    ``` yaml linenums="1"
    configs:
      - type: mergeyaml
        path: some/config.yml
        content:
          bar: "baz"
          list:
            - "foo"
            - "bar"
    ```

    Because `some/config.yml` doesn't exist in configs list.

    But this config will work:

    ``` yaml linenums="1"
    configs:
      - type: yaml
        path: some/config.yml
        content:
          key: "value"
          list:
            - "item1"
            - "item2"
      - type: mergeyaml
        path: some/config.yml
        content:
          bar: "baz"
          list:
            - "foo"
            - "bar"
    ```

    And this config will work too:

    ``` yaml linenums="1"
    package:
      type: local
      path: /path/to/paper

    configs:
      - type: mergeyaml
        path: spigot.yml
        content:
          bar: "baz"
          list:
            - "foo"
            - "bar"
    ```

    Because `spigot.yml` exists in server package.
