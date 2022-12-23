{ fetchgit
, git
, lib
, maven
, mineflake
, stdenv
}:

let
  version = "510";
  pname = "Waterfall";

  src = fetchgit {
    url = "https://github.com/PaperMC/Waterfall.git";
    fetchSubmodules = true;
    leaveDotGit = true;
    rev = "079f3a31294551fcedc92bff2943ce749bdb99b5";
    sha256 = "sha256-I4Jkd2y2wZ5rKZB8pFtEI8w+kkcxx77uYeysEEX2IgE=";
  };

  patched-src = stdenv.mkDerivation {
    name = "${pname}-${version}-patched-source";
    inherit src;

    nativeBuildInputs = [ git ];

    patchPhase = ''
      patchShebangs scripts/applyPatches.sh
    '';

    buildPhase = ''
      export HOME=/build
      git config --global user.email "no-reply@nixos.org"
      git config --global user.name "Nix Build"
      ./scripts/applyPatches.sh
    '';

    installPhase = ''
      cp -R ./ $out/
    '';
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    src = patched-src;

    nativeBuildInputs = [ maven ];

    buildPhase = ''
      mvn package -Dmaven.test.skip=true -Dmaven.repo.local=$out/.m2 -Dmaven.wagon.rto=5000
    '';

    # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
    installPhase = ''
      find $out/.m2 -type f -regex '.+\(\.lastUpdated\|resolver-status\.properties\|_remote\.repositories\)' -delete
      find $out/.m2 -type f -iname '*.pom' -exec sed -i -e 's/\r\+$//' {} \;
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-zjyxo8+53CpDgCV+g+IskrD76jOrHi6gCQ9YsFj4jns=";

    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  inherit version pname;
  src = patched-src;

  nativeBuildInputs = [ maven ];

  buildPhase = ''
    mvn package --offline -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D Waterfall-Proxy/bootstrap/target/Waterfall.jar $out/package.jar
    install -D ${mineflake.buildMineflakeManifest pname version} $out/package.yml

    ${lib.concatMapStrings (name:
    ''
      install -D Waterfall-Proxy/module/cmd-${name}/target/cmd_${name}.jar $out/modules/cmd_${name}.jar
    '') ["alert" "find" "list" "send" "server"]}
    install -D Waterfall-Proxy/module/reconnect-yaml/target/reconnect_yaml.jar $out/modules/reconnect_yaml.jar

    install -D ${./config.yml} $out/config.yml
  '';
}
