{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.19.12";
in
stdenv.mkDerivation {
  inherit version;

  pname = "Chatty";

  src = fetchurl {
    url = "https://github.com/Brikster/Chatty/releases/download/v${version}/Chatty.jar";
    hash = "sha256-28bpZNb88IPsUmDiXJzByaadXd41yEh0e6Lg/2p73HE=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Bukkit-compatible chat plugin with multiple chat-modes";
    homepage = "https://github.com/Brikster/Chatty";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/Chatty/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/Chatty/locale/en.yml" = {
        type = "yaml";
        data = importJSON ./en.yml.json;
      };
    };
    server = ["spigot"];
    type = "result";
    folders = [ "plugins/Chatty" "plugins/Chatty/locale" ];
  };
}
