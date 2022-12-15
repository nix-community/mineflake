{ mineflake, ... }:

rec {
  luckperms = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeidnakt6kkphubpi6aye5jet6ftkpt44pstbgtae4a24mojlos7o5i/package.zip";
    sha256 = "0sxy5q5m4xpv38yk4vmasa5gcq7anv4m1582927s3ym0q1cbqcvv";
  };

  authme = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeifox6mekis77muueh4nzdjbf3kjvxdp7vztu4hr47lqnui5p3sr6i/authme.zip";
    sha256 = "1l0ax3v4mk41g2zw9p17mff5lawbhr76nak2lgmw2c4qc16iisgl";
  };

  coreprotect = mineflake.buildZipMfPackage {
    url = mineflake.ipfsUrl "bafybeifpo743ap7pltrs3skl6lt7q7j4s4pwzb3yzkvyzyzmuafnofrsdq/coreprotect.zip";
    sha256 = "0nxndav03304xsaryk89krqxpsmp21xbpdvrl2myvqbpq22h0g6w";
  };
}
