{ callPackage, fetchFromGitHub, rustPlatform, lib, openssl, pkg-config, ... }:

let
  naersk = callPackage
    (fetchFromGitHub {
      owner = "nix-community";
      repo = "naersk";
      rev = "6944160c19cb591eb85bbf9b2f2768a935623ed3";
      sha256 = "sha256-9o2OGQqu4xyLZP9K6kNe1pTHnyPz0Wr3raGYnr9AIgY=";
    })
    { };
in
naersk.buildPackage rec {
  src = ./.;
  buildInputs = [ pkg-config ];
  nativeBuildInputs = [ openssl.dev ];
}
