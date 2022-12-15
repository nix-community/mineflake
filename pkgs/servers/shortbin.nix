{ mineflake, ... }:

rec {
  paper_1-19-3 = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeibpcdwogzv5pub2h7tmfjam63wo3fhbkypl6bjtm36jtsbbuvn3ja/server.zip";
    sha256 = "sha256-Gy426x5uhyhIj1tB5mjMyfgPJMJqIUIR4R5Iu/ZsH9c=";
  };
  paper = paper_1-19-3;

  waterfall_1-19 = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeidfd3ysbnh566fu6qduvahikh6br3aypuyivzslgjat7r37z2xtom/server.zip";
    sha256 = "0kzfkwf1ch25j1jsm6y8qlj8124007v22idxgndc8yd0rngk7njc";
  };
  waterfall = waterfall_1-19;
}
