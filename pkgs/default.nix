{ pkgs, ... }:

with pkgs; rec {
  buildMineflakeBin = config: writeScriptBin "mineflake" ''
    #!${pkgs.runtimeShell}
    ${mineflake}/bin/mineflake apply -r -c "${writeText "mineflake.json" (builtins.toJSON config)}"
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

  paper = callPackage ./servers/paper_1.19.2 { };
  authme = callPackage ./plugins/authme { };

  ### TESTING AREA ###

  docker = buildMineflakeContainer {
    type = "spigot";
    command = "echo {}";
    package = mkMfPackage paper;
    plugins = [
      (mkMfPackage authme)
    ];
  };

  ### TESTING AREA ###

  mineflake = callPackage ../cli { };

  # Alias to mineflake for `nix build .` command
  default = mineflake;
}
