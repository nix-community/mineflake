{ pkgs, lib ? pkgs.lib }:

let

  nmdSrc = fetchTarball {
    url =
      "https://gitlab.com/api/v4/projects/rycee%2Fnmd/repository/archive.tar.gz?sha=91dee681dd1c478d6040a00835d73c0f4a4c5c29";
    sha256 = "07szg39wmna287hv5w9hl45wvm04zbh0k54br59nv3yzvg9ymlj4";
  };

  nmd = import nmdSrc { inherit lib pkgs; };

  # Make sure the used package is scrubbed to avoid actually
  # instantiating derivations.
  scrubbedPkgsModule = {
    imports = [{
      _module.args = {
        pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        pkgs_i686 = lib.mkForce { };
      };
    }];
  };

  dontCheckDefinitions = { _module.check = false; };

  buildModulesDocs = args:
    nmd.buildModulesDocs ({
      moduleRootPaths = [ ./.. ];
      mkModuleUrl = path:
        "https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/${path}";
      channelName = "mineflake";
    } // args);

  hmModulesDocs = buildModulesDocs {
    modules = [ ../modules/mineflake.nix scrubbedPkgsModule dontCheckDefinitions ];
    docBook.id = "mineflake-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "mineflake";
    projectName = "Mineflake";
    modulesDocs = [ hmModulesDocs ];
    documentsDirectory = ./.;
    documentType = "article";
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-mineflake-manual"><?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-options"><?dbhtml filename="options.html"?></d:tocentry>
        </d:tocentry>
      </toc>
    '';
  };

in {
  inherit nmdSrc;
  manual = { inherit (docs) html htmlOpenTool; };
}
