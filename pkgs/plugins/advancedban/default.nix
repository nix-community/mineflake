{ fetchFromGitHub
, maven
, mineflake
, stdenv
}:

let
  version = "2.3.0";
  pname = "AdvancedBan";

  src = fetchFromGitHub {
    owner = "DevLeoko";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4kRlQRUiCZHHl7MSLp/xsBSSzvUUDLhtU61cwsjv7ck=";
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;

    nativeBuildInputs = [ maven ];

    patchPhase = ''
      sed -i 's=http://repo.md-5.net=https://repo.md-5.net=' bungee/pom.xml
    '';

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
    outputHash = "sha256-8FvSeQC++m7CO7csmgLsT1neYdad6HMVmFaOqbLK04k=";

    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  inherit version pname src;

  nativeBuildInputs = [ maven ];

  buildPhase = ''
    mvn package --offline -Dproject.branch=master -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D bundle/target/${pname}-Bundle-${version}-RELEASE.jar $out/package.jar
    install -D ${mineflake.buildMineflakeManifest pname version} $out/package.yml
    install -D core/src/main/resources/config.yml $out/plugins/AdvancedBan/config.yml
    install -D core/src/main/resources/Layouts.yml $out/plugins/AdvancedBan/Layouts.yml
    install -D core/src/main/resources/Messages.yml $out/plugins/AdvancedBan/Messages.yml
  '';
}
