{ lib, fetchurl, stdenv, ... }:

let
  mcVersion = "1.18.2";
  buildNum = "387";
  hash = "sha256-XB1NpToEW/0LO080Y+sDH+i+NBGuQh1ZsQpaHH+gne0=";
  mojang_dep = fetchurl {
    url = "https://ipfs.io/ipfs/bafybeidd64amhqeqkrtm6udjyhlu7lero7fakzeunqha7oywwibeogluqq/mojang_1.18.2.jar";
    hash = "sha256-V76dHjWqkc/fokattjoOoRqUYIHgRk0IvD02ZRcYo0M=";
  };
in
stdenv.mkDerivation {
  inherit hash;

  pname = "paper";
  version = "${mcVersion}r${buildNum}";
  src = fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
    hash = hash;
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
      "cache/mojang_1.18.2.jar" = "mojang.jar";
    };
    folders = [
      "cache"
      "plugins"
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
      "paper.yml" = {
        type = "yaml";
        data = (importJSON ./paper.yml.json);
      };
    };
  };
}
