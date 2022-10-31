# Creating plugin

[<- Back](./README.md)

## How plugins work

Basically, plugins are simple, so we recommend you to read the [Nix Pills](https://nixos.org/guides/nix-pills/) series of articles and
documentation about them.

The only difference between plugins and regular packages is their meta information - the information by which mineflake knows what it is,
how to install it, what configurations it has. Plugins do not have a description of options or any other business logic inside them.

### What parameters can plugins contain?

- `configs` - attrs of the configs. (Folders for them should already exist). Example:

 ```nix
configs = {
  "plugins/AuthMe/config.yml" = {
    type = "yaml"; # can be yaml, json, toml or raw
    data = {
      some.option = true;
    };
  };
  "plugins/AuthMe/custom.type" = {
    type = "raw";
    data.raw = "some value";
  };
};
 ```

- `server` - list of server types for which this plugin is suitable. This field is needed for build-time checks for config correctness. It can be `bungee`, for bungeecord-based, `spigot`, for spigot-based or `forge`, for forge mods (there is no support for forge at this time). Example: `[ "bungee" "spigot" ]`
- `type` - plugin type. It can be either `complex`, for complex packages with complex dependency relationships, or `result`, for simple plugins with no additional dependencies for themselves. Complex plugins must contain the result file in the `$out` folder, with the main jar file. result plugins must contain the jar file in the `$out` path, with no additional directory. Example: `"result"`
- `struct` - field only for complex type of plugins. Contains attrs map (path in server folder)=(path in out folder). Example:

 ```nix
{
  "cache/mojang_1.18.2.jar" = "mojang.jar";
};
 ```

- `deps` - list with other plugins that will be installed along with this plugin. (**Important** - plugin dependencies cannot have other dependencies.) Example: `[ (callPackage ../redlib { }) ]`
- `folders` - list of folders that will be created in the server folder. Example: `[ "plugins/AuthMe" ]`

## Practice

You can look at [ready-made plugins](https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/pkgs/spigot/plugins) as a reference.

### Simple plugin

```nix
{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.0";
in
stdenv.mkDerivation {
  inherit version;

  pname = "PluginName";

  src = fetchurl {
    url = "https://github.com/author/${pname}/releases/download/${version}/${pname}-${version}.jar";
    sha256 = "1f9w6rdmma009x8k3l4k2h006swkascd8mk2mqi5bm3vj95515q8"; # You can get this hash via the command "nix-prefetch-url <file link>"
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Short plugin description";
    homepage = "https://github.com/author/${pname}";
    license = licenses.mit; # See LICENSE file in plugin repo
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/${pname}/config.yml" = {
        type = "yaml";
        data = {
            example-value = true;
        };
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/${pname}" ];
  };
}
```

### Complex plugin

```nix
{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.0";
  pname = "PluginName";
  additional_dep = fetchurl {
    url = "https://github.com/author/${pname}/releases/download/${version}/${pname}-${version}-lib.jar";
    sha256 = "053kv00g07pp083f18safwllgq9a41r69z2k806860r02p89mj1d";
  };
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://github.com/author/${pname}/releases/download/${version}/${pname}-${version}.jar";
    sha256 = "1f9w6rdmma009x8k3l4k2h006swkascd8mk2mqi5bm3vj95515q8";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    install -Dm444 $src $out/result
    install -Dm444 ${additional_dep} $out/lib.jar
  '';

  meta = with lib; {
    description = "Short plugin description";
    homepage = "https://github.com/author/${pname}";
    license = licenses.mit; # See LICENSE file in plugin repo
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/${pname}/config.yml" = {
        type = "yaml";
        data = {
            example-value = true;
        };
      };
    };
    server = [ "spigot" ];
    type = "complex";
    struct = {
        "plugins/${pname}/libs/library.jar" = "lib.jar";
    };
    folders = [ "plugins/${pname}" "plugins/${pname}/libs" ];
  };
}
```
