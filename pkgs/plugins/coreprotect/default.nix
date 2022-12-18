{ stdenv, jdk17_headless, maven, makeWrapper, fetchFromGitHub, mineflake, ... }:

let
  repo-src = fetchFromGitHub {
    owner = "PlayPro";
    repo = "CoreProtect";
    rev = "61847f2f8d95e0ce6bb0f586f2e95a529f07b1a1";
    hash = "sha256-FwB5ZTf/2hFmsN0QT0+V5xDIjwt4gs/zVXceCeZn6+8=";
  };

  dependencies = stdenv.mkDerivation {
    name = "CoreProtect-maven-dependencies";
    nativeBuildInputs = [ maven jdk17_headless ];
    src = repo-src;
    buildPhase = ''
      while mvn package -Dmaven.repo.local=$out/.m2 -Dmaven.wagon.rto=5000; [ $? = 1 ]; do
        echo "timeout, restart maven to continue downloading"
      done
    '';
    installPhase = ''
      find $out/.m2 -type f -regex '.+\\(\\.lastUpdated\\|resolver-status\\.properties\\|_remote\\.repositories\\)' -delete
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-beLWt6Ql0hDWzIZgLPR+cXGkJOZr/tdp3mhQ12Q99mU=";
  };
in
mineflake.buildMineflakePackage rec {
  pname = "CoreProtect";
  version = "21.3";

  src = repo-src;

  nativeBuildInputs = [ maven jdk17_headless ];

  buildPhase = ''
    # 'maven.repo.local' must be writable so copy it out of nix store
    cp -r $src/* .
    cp -r ${dependencies}/.m2 maven-repo
    chmod -R u+w .
    mvn package --offline -Dmaven.repo.local=maven-repo
  '';

  installPhase = ''
    mkdir -p $out
    cp target/${pname}-${version}.jar $out/package.jar
    cp -r ${./plugins} $out/plugins
  '';
}
