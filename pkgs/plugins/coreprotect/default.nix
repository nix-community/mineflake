{ fetchFromGitHub
, maven
, mineflake
, stdenv
}:

let
  version = "21.3";
  pname = "CoreProtect";

  src = fetchFromGitHub {
    owner = "PlayPro";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1Q89OT9+hcFUtb3jc0qXQGXyV767E5zsDAfWxdXqwXI=";
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
    outputHash = "sha256-3oC/xOSDFot+Mffnfy0rMQGsUJq/Z+JGrpfqvEFzdkk=";

    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  inherit version pname src;

  buildInputs = [
    maven
  ];

  buildPhase = ''
    mvn package --offline -Dproject.branch=master -Dmaven.test.skip=true -Dmaven.repo.local=$(cp -dpR ${deps}/.m2 ./ && chmod +w -R .m2 && pwd)/.m2
  '';

  installPhase = ''
    install -D target/${pname}-${version}.jar $out/package.jar
    install -D ${mineflake.buildMineflakeManifest pname version} $out/package.yml
    install -D ${./config.yml} $out/plugins/CoreProtect/config.yml
    install -D lang/en.yml $out/plugins/CoreProtect/language.yml
  '';
}
