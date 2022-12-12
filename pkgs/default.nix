{ pkgs, ... }:

with pkgs; rec {
  buildMineflakeConfig =
    { type ? "spigot"
    , package
    , plugins ? [ ]
    , command ? ""
    , configs ? [ ]
    ,
    }: writeText "mineflake.json" (builtins.toJSON {
      type = type;
      package = mkMfPackage package;
      plugins = map (p: mkMfPackage p) plugins;
      command = command;
      configs = configs;
    });


  buildMineflakeBin = config: writeScriptBin "mineflake" ''
    #!${pkgs.runtimeShell}
    ${mineflake}/bin/mineflake apply -r -c "${buildMineflakeConfig config}"
  '';

  buildMineflakeContainer = config: pkgs.dockerTools.buildImage {
    name = "mineflake";
    tag = "latest";
    copyToRoot = (buildMineflakeBin config);
    config = {
      Cmd = [ "/bin/mineflake" ];
      WorkingDir = "/data";
    };
  };

  mkMfPackage = package: {
    type = "local";
    path = package;
  };

  mkMfConfig = type: path: content: {
    type = type;
    path = path;
    content = content;
  };

  paper = callPackage ./servers/paper_1.19.2 { };
  authme = callPackage ./plugins/authme { };

  ### TESTING AREA ###

  docker = buildMineflakeContainer {
    type = "spigot";
    command = "${jre}/bin/java -jar {}";
    package = paper;
    plugins = [
      authme
    ];
    configs = [
      (mkMfConfig "raw" "server.properties" "online-mode=false")
      (mkMfConfig "raw" "eula.txt" "eula=true")
    ];
  };

  ### TESTING AREA ###

  mineflake = callPackage ../cli { };

  # Alias to mineflake for `nix build .` command
  default = mineflake;
}
