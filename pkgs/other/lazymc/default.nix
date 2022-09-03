{ lib, fetchFromGitHub, rustPlatform, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "lazymc";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "timvisee";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-JuKCZxyh55L6jzoUwpAv7Mpo0HX3rrSRtHgsrZoTV+8=";
  };

  doCheck = false;

  cargoSha256 = "sha256-l4qd5WB6awraxpqI9V3zxzRohzmcA161+CDa9E8MKsE=";

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Put your Minecraft server to rest when idle";
    homepage = "https://github.com/timvisee/lazymc";
    license = licenses.gpl3;
  };
}
