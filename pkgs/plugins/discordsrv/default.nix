{ fetchFromGitHub
, lib
, maven
, mineflake
, stdenv
}:
let
  version = "1.26.0";
  pname = "DiscordSRV";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IQc2XFyCBIewBihKwSVc7FobiJ3b7FlL0Rv8yfeD0D8=";
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;

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
    outputHash = "sha256-bFuafFpQARUgFEFx/cxfkvsfHNGMC3oXGvVE1QWylBI=";
  };
in
stdenv.mkDerivation rec {
  inherit version pname src;

  nativeBuildInputs = [
    maven
  ];

  buildPhase = ''
    mvn package --offline -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D target/${pname}-Build-${version}-null.jar $out/package.jar
    install -D ${mineflake.buildMineflakeManifest pname version} $out/package.yml

    ${lib.concatMapStrings (name:
    ''
      install -D src/main/resources/${name}/en.yml $out/plugins/${pname}/${name}.yml
    '') ["alerts" "config" "linking" "messages" "synchronization" "voice"]}
  '';
}
