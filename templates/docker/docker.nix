{ pkgs, ... }:

with pkgs; mineflake.buildMineflakeContainer {
  package = mineflake.paper;
  command = "${jre_headless}/bin/java -Xms1G -Xmx1G -jar {} nogui";
  plugins = with mineflake; [ luckperms ];
  configs = [
    (mineflake.mkMfConfig "mergeyaml" "plugins/LuckPerms/config.yml" {
      server = "vanilla_1";
    })
  ];
}
