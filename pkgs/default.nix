{ pkgs, ... }:

with pkgs; rec {
  buildMineflakeBin = config: writeScriptBin "mineflake" ''
    #!${pkgs.runtimeShell}
    ${mineflake}/bin/mineflake apply -c "${writeText "mineflake.json" (builtins.toJSON config)}"
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

  ### TESTING AREA ###

  docker = buildMineflakeContainer {
    type = "spigot";
    command = "echo {}";
    package = {
      type = "local";
      path = fetchzip {
        url = "https://bafybeibdyu6zey5k2rihdeapzeh3r2zr5mjgh3tcaqu27wiad6pxd3tjhi.ipfs.w3s.link/ipfs/bafybeibdyu6zey5k2rihdeapzeh3r2zr5mjgh3tcaqu27wiad6pxd3tjhi/essentialsx.zip";
        sha256 = "0fqjfsicm9gaga7b7f1n60z296dkqwgmy11s2pghq2ygi08jrkk4";
      };
    };
    plugins = [

    ];
  };

  ### TESTING AREA ###

  mineflake = callPackage ../cli { };

  # Alias to mineflake for `nix build .` command
  default = mineflake;
}
