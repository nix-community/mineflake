{ lib, python3Packages }:

with python3Packages;
buildPythonApplication {
  pname = "mineflake-utils";
  version = "1.0";

  propagatedBuildInputs = [ pyyaml toml ];

  src = ./src;
}
