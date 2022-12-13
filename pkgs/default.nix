{ pkgs, ... }:

with pkgs; rec {
  # CLI
  mineflake = (callPackage ../cli { }).offline;
  mineflake-online = (callPackage ../cli { }).default;

  # Build utils
  buildMineflakeConfig =
    { type ? "spigot"
    , package
    , plugins ? [ ]
    , command ? ""
    , configs ? [ ]
    , ...
    }@attrs: writeText "mineflake.json" (builtins.toJSON (attrs // {
      type = type;
      package = mkMfPackage package;
      plugins = map (p: mkMfPackage p) plugins;
      command = command;
      configs = configs;
    }));


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

  buildMineflakeLayeredContainer = config: pkgs.dockerTools.buildLayeredImage {
    name = "mineflake";
    tag = "latest";
    contents = [ (buildMineflakeBin config) ];
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

  # Generates manifest.yml for a package
  buildMineflakeManifest = name: version: writeText "mineflake-manifest.yml" (builtins.toJSON { inherit name version; });

  buildMineflakePackage = { pname, version, ... }@attrs: stdenv.mkDerivation ({
    phases = [ "buildPhase" "installPhase" "manifestPhase" ];
    manifestPhase = ''
      cp ${buildMineflakeManifest pname version} $out/package.yml
    '';
  } // attrs);



  # Servers
  paper = paper_1-19-2;
  paper_1-19-2 = callPackage ./servers/paper_1.19.2 { };


  # Plugins
  authme = callPackage ./plugins/authme { };
  luckperms = callPackage ./plugins/luckperms { };
}
