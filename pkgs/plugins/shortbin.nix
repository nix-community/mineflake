{ mineflake, ... }:

rec {
  luckperms = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeidnakt6kkphubpi6aye5jet6ftkpt44pstbgtae4a24mojlos7o5i/package.zip";
    sha256 = "0sxy5q5m4xpv38yk4vmasa5gcq7anv4m1582927s3ym0q1cbqcvv";
  };
}
