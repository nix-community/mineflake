{ lib, fetchurl, stdenv, ... }:

let
  mcVersion = "1.19.2";
  buildNum = "175";
  mojang_dep = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeicqy4t4hoguljxnvxy64nuwpek3pn2o5wub2xrcyc2pjw5qsvs5hu/mojang_1.19.2.jar";
    sha256 = "15jdxh5zvsgvvk9hnv47swgjfg8fr653g6nx99q1rxpmkq32frxj";
  };
in
stdenv.mkDerivation {
  pname = "paper";
  version = "${mcVersion}r${buildNum}";
  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeiac2fccdukavrpykqix4xgcwr6qqzm2wyxkkoov5ucxvzt3xznvxa/paper-${mcVersion}-${buildNum}.jar";
    sha256 = "0an6xbniqzw6v0zh5ygxmnq4fwaam07jbjn1razahml25ww1vy36";
  };

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    install -Dm444 $src $out/result
    install -Dm444 ${mojang_dep} $out/mojang.jar
  '';

  meta = with lib; {
    description = "High-performance Minecraft Server";
    homepage = "https://papermc.io/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    server = "spigot";
    type = "complex";
    struct = {
      "cache/mojang_1.19.2.jar" = "mojang.jar";
    };
    folders = [
      "cache"
      "plugins"
      "config"
    ];
    configs = {
      "bukkit.yml" = {
        type = "yaml";
        data = (importJSON ./bukkit.yml.json);
      };
      "spigot.yml" = {
        type = "yaml";
        data = (importJSON ./spigot.yml.json);
      };
      "config/paper-global.yml" = {
        type = "yaml";
        data = (importJSON ./paper-global.yml.json);
      };
      "config/paper-world-defaults.yml" = {
        type = "yaml";
        data = (importJSON ./paper-world-defaults.yml.json);
      };
    };
  };
}
