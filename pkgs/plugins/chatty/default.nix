{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "Chatty";
  version = "2.19.12";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmZcQZ8SeJuhBWQqP6iV4tWMT7MjX4qiBosXiQmUKZXNTL";
    sha256 = "0wfwgdmgzq52gds4ij1mvrfrv9n9q6f5rqk0abn87w7wsrjfkinv";
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
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/Chatty" "plugins/Chatty/locale" ];
  };
}
