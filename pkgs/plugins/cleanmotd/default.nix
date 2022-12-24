{ fetchFromGitHub
, maven
, mineflake
, stdenv
}:

let
  version = "0.2.8";
  pname = "CleanMOTD";

  src = fetchFromGitHub {
    owner = "2lstudios-mc";
    repo = pname;
    rev = "f694a5c64f133d640a8a421d11a64895c17b4bb9";
    sha256 = "sha256-QizQlDdJGxIGA9m18vSCZvv5JJ3iBwKP2YmAs1vGy04=";
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
    outputHash = "sha256-f8MOFzJ7glpLJ+Zm9BDxjb/88R6eE100CLnCXp25TRU=";

    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  inherit version pname src;

  nativeBuildInputs = [
    maven
  ];

  buildPhase = ''
    mvn package --offline -Dproject.branch=master -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D target/${pname}.jar $out/package.jar
    install -D ${mineflake.buildMineflakeManifest pname version} $out/package.yml
    install -D src/main/resources/config.yml $out/plugins/CleanMOTD/config.yml
    install -D src/main/resources/messages.yml $out/plugins/CleanMOTD/messages.yml
  '';
}
