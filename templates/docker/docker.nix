{ pkgs, ... }:

with pkgs; mineflake.buildMineflakeContainer {
  package = mineflake.paper;
  command = "${jdk}/bin/java -Xms1G -Xmx1G -jar {} nogui";
  plugins = with mineflake; [ authme ];
  configs = [
    (mineflake.mkMfConfig "raw" "eula.txt" "eula=true")
  ];
}
