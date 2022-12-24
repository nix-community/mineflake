{ mineflake, ... }:

rec {
  paper_1-19-3 = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeibpcdwogzv5pub2h7tmfjam63wo3fhbkypl6bjtm36jtsbbuvn3ja/server.zip";
    sha256 = "sha256-Gy426x5uhyhIj1tB5mjMyfgPJMJqIUIR4R5Iu/ZsH9c=";
  };
  paper = paper_1-19-3;
}
