{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.6.7";
in
stdenv.mkDerivation {
  inherit version;

  pname = "InventoryRollbackPlus";

  src = fetchurl {
    url = "https://github.com/TechnicallyCoded/Inventory-Rollback-Plus/releases/download/v${version}/InventoryRollbackPlus-${version}.jar";
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
