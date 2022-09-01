{ lib, spigot, ... }:

with lib; let
  mkConfigFile = option: (
    # yaml compatible with json format
    if option.type == "yaml" || option.type == "json" || option.type == "toml" then
      (builtins.toFile "config.${option.type}" (builtins.toJSON option.data))
    else if option.type == "raw" then
      (builtins.toFile "config.${option.type}" option.data.raw)
    else
      (builtins.toFile "none.txt" "Unexpected config format type!")
  );
  mkConfig = type: data: { inherit type data; };

  getName = package: "${package.pname}-${package.version}";
in
{
  inherit mkConfigFile mkConfig attrValsToList getName;

  mkConfigs = server: configs:
    concatStringsSep "\n" (map
      # TODO: replace env variables in config
      # substitute ${server.envfile} ${server.datadir}/${key}
      (key: ''
        echo 'Create "${key}" config file'
        rm -f "${server.datadir}/${key}"
        ${if (getAttr key configs).type == "yaml" then
          ''${spigot.utils}/bin/json_to_yaml.py "${mkConfigFile (getAttr key configs)}" "${server.datadir}/${key}"'' else
        if (getAttr key configs).type == "toml" then
          ''${spigot.utils}/bin/json_to_toml.py "${mkConfigFile (getAttr key configs)}" "${server.datadir}/${key}"'' else
        if (getAttr key configs).type == "json" then
          ''${spigot.utils}/bin/format_json.py "${mkConfigFile (getAttr key configs)}" "${server.datadir}/${key}"'' else
          ''cp "${mkConfigFile (getAttr key configs)}" "${server.datadir}/${key}"''}
        chmod 640 "${server.datadir}/${key}"
        ${spigot.utils}/bin/replace_env.py "${server.datadir}/${key}" "${server.datadir}/${key}"
      '')
      (attrNames configs));

  mkRawConfig = text: mkConfig "raw" { raw = text; };

  linkComplex = package: base:
    concatStringsSep "\n" (
      map
        (key: ''
          echo 'Link "${key}" for ${getName package}'
          rm -f "${base}/${key}"
          ln -sf "${package}/${getAttr key package.meta.struct}" "${base}/${key}"'')
        (attrNames package.meta.struct));

  linkResult = package: base: ext:
    ''
      echo "Link ${getName package} result"
      ln -sf "${package}" "${base}/${getName package}${ext}"
    '';

  boolToString = val: if val then "true" else "false";

  recursiveMerge = attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == [ ]
        then head values
        else if all isList values
        then unique (concatLists values)
        else if all isAttrs values
        then f (attrPath ++ [ n ]) values
        else last values
      );
    in f [ ] attrList;

  attrsToList = attrs: map (key: getAttr key attrs) (attrNames attrs);
}
