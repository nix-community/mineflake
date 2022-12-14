{ pkgs, ... }:

with pkgs; mineflake.buildMineflakeContainer {
  package = mineflake.paper;
  command = "${jdk}/bin/java -Xms1G -Xmx1G -jar {} nogui";
  plugins = with mineflake; [ luckperms ];
  configs = [
    (mineflake.mkMfConfig "mergeyaml" "plugins/LuckPerms/config.yml" {
      server = "vanilla_1";
    })
  ];
}
