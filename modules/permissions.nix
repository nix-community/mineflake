{ lib, spigot, utils, ... }:

with lib; with utils; {
  submodule = types.submodule ({ ... }: {
    options = {
      enable = mkEnableOption "Enables declarative generation of LuckPerms settings";

      name = mkOption {
        type = types.str;
        default = "global";
      };

      groups = mkOption {
        type = types.attrsOf (types.submodule ({ ... }: {
          options = {
            permissions = mkOption {
              type = types.nullOr (types.listOf (types.submodule ({ ... }: {
                options = {
                  permission = mkOption {
                    type = types.str;
                  };

                  value = mkOption {
                    type = types.bool;
                    default = true;
                  };

                  expiry = mkOption {
                    type = types.nullOr types.int;
                    default = null;
                  };

                  context = mkOption {
                    type = types.nullOr types.attrs;
                    default = null;
                  };
                };
              })));
              default = null;
            };

            prefixes = mkOption {
              type = types.nullOr (types.listOf (types.submodule ({ ... }: {
                options = {
                  prefix = mkOption {
                    type = types.str;
                  };

                  priority = mkOption {
                    type = types.int;
                  };
                };
              })));
              default = null;
            };

            suffixes = mkOption {
              type = types.nullOr (types.listOf (types.submodule ({ ... }: {
                options = {
                  seffix = mkOption {
                    type = types.str;
                  };

                  priority = mkOption {
                    type = types.int;
                  };
                };
              })));
              default = null;
            };
          };
        }));
        default = [{ name = "default"; }];
      };

      package = mkOption {
        type = types.package;
        default = spigot.luckperms;
        example = "pkgs.spigot.luckperms";
        description = "Plugin package";
      };
    };
  });

  generator = permissions: with permissions;
    optionalAttrs enable
      (
        let obj = builtins.mapAttrs (name: group: { name = "plugins/LuckPerms/json-storage/groups/${name}.json"; value = (mkConfig "json" group // { inherit name; }); }) groups;
        in
        builtins.listToAttrs (map (key: getAttr key obj) (attrNames obj)) //
        {
          "plugins/LuckPerms/config.yml" = mkConfig "yaml" {
            "server" = name;
            "storage-method" = "h2";
            "split-storage" = {
              "enabled" = true;
              "methods" = {
                "group" = "json";
              };
            };
          };
        }
      );
}
