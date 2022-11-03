{ rustPlatform, lib, ... }:

rustPlatform.buildRustPackage rec {
  pname = "mineflake";
  version = "0.1.0";

  src = ./.;

  cargoSha256 = "sha256-wQvUINSxh220xWKzZaSoYeHSS2FhwjZjYIBlO9OoONg=";

  meta = with lib; {
    description = "CLI that powers Mineflake";
    license = licenses.mit;
  };
}
