{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "InventoryRollbackPlus";
  version = "1.6.7";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmUha5jtsWmEvXnhXUWideCBTYEuvYU5REbAg4E6YuHYVM";
    sha256 = "0cxp1arxx6j1vkqjs17pqpfbwq14k9azrqyfyf9nw6k9wr6jxxb0";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Plugin that allows server moderators to restore player items and data from backups";
    homepage = "https://github.com/TechnicallyCoded/Inventory-Rollback-Plus";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/InventoryRollbackPlus/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/InventoryRollbackPlus/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/InventoryRollbackPlus" "plugins/InventoryRollbackPlus/backups" ];
  };
}
