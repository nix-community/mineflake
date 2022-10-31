# Создание плагина

[<- Назад](./README.md)

## Как работают плагины

Плагины это простые Nix, поэтому мы рекомендуем вам прочитать серию статей и документацию о них в
[Nix Pills](https://nixos.org/guides/nix-pills/).

Единственным отличием плагинов от обычных пакетов является их метаинформация - информация, по которой mineflake знает, что
это такое, как его установить, какие у него конфигурации. Плагины не имеют внутри себя описания параметров или какой-либо
другой логики.

### Какие параметры могут содержать плагины?

- `configs` - атрибуты конфигураций. (Папки для них уже должны существовать). Пример:

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

- `server` - список типов серверов, для которых подходит данный плагин. Это поле необходимо для проверки корректности конфигурации во время сборки. Оно может быть `bungee`, для серверов на основе bungeecord, `spigot`, для серверов на основе spigot или `forge`, для модов forge (в настоящее время поддержка forge отсутствует). Пример: `[ "bungee" "spigot" ]`.
- `type` - тип плагина. Он может быть либо `complex`, для сложных пакетов со сложными зависимостями, либо `result`, для простых плагинов без дополнительных зависимостей для себя. Сложные плагины должны содержать файл `result` в папке `$out`, с основным jar-файлом. Плагины типа `result` должны содержать jar-файл по пути `$out`, без дополнительной директории. Пример: `"result"`.
- `struct` - поле только для плагинов сложного типа. Содержит карту attrs (путь в папке сервера)=(путь в папке `$out`). Пример:

 ```nix
{
  "cache/mojang_1.18.2.jar" = "mojang.jar";
};
 ```

- `deps` - список с другими плагинами, которые будут установлены вместе с этим плагином. (**Важно** - зависимости плагина не могут иметь другие зависимости.) Пример: `[ (callPackage ../redlib { }) ]`.
- `folders` - список папок, которые будут созданы в папке сервера до создания плагинов. Пример: `[ "plugins/AuthMe" ]`.

## Практика

В качестве образца можно посмотреть на [готовые плагины](https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/pkgs/spigot/plugins).

### Простой плагин

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

### Сложный плагин

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
