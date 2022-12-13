// require modules
import { Web3Storage } from "web3.storage";
import fs from "fs";
import crypto from "crypto";
import archiver from "archiver";

let uploaded = {};

async function main() {
  // load json file located at first CLI argument
  let config = JSON.parse(fs.readFileSync(process.argv[2]));

  // create a client
  const client = new Web3Storage({ token: process.env.WEB3STORAGE_TOKEN });

  // get all pinned files
  console.log("Getting all pinned files...");
  let files = await client.list();
  for await (let file of files) {
    uploaded[file.name] = file.cid;
  }
  console.log(`Found ${uploaded.length} files!`);

  // initialize repo
  let repo = {};

  // iterate over config
  for (let name in config) {
    console.log(`Processing ${name}...`);

    // create a zip file
    console.log(`Creating zip file...`);
    const output = fs.createWriteStream(`${name}.zip`);
    const archive = archiver("zip");

    // zip config[name] folder
    archive.directory(config[name], false);

    // save zip file
    archive.pipe(output);
    await archive.finalize();
    output.close();

    // get zip file sha256 hash
    const _hash = crypto
      .createHash("sha256")
      .update(fs.readFileSync(`${name}.zip`))
      .digest("hex");
    const full = `${name}-${_hash}.zip`;

    // check if zip file already exists
    if (uploaded[full]) {
      console.log(`Zip file already exists! Skipping...`);
    } else {
      // upload zip file to web3.storage
      console.log(`Uploading zip file...`);
      const cid = await client.put(
        [
          {
            name: "archive.zip",
            stream: () => fs.createReadStream(`${name}.zip`),
          },
        ],
        { type: "application/zip", name: full }
      );
      uploaded[full] = cid;
    }

    // add cid to repo
    repo[name] = `https://w3s.link/ipfs/${uploaded[full]}/archive.zip`;

    // delete zip file
    fs.unlinkSync(`${name}.zip`);

    console.log(`Done processing ${name}! CID: ${uploaded[full]}`);
  }

  // save repo to repo.json
  fs.writeFileSync("repo.json", JSON.stringify(repo));

  // upload repo.json to web3.storage
  console.log("Uploading repo.json...");
  const cid = await client.put(
    [
      {
        name: "repo.json",
        stream: () => fs.createReadStream("repo.json"),
      },
    ],
    { type: "application/json", name: "repo.json" }
  );
  console.log(`repo.json uploaded! CID: ${cid}`);

  // save repo.json cid to repo.json
  repo["cid"] = cid;
  fs.writeFileSync("repo.json", JSON.stringify(repo));

  // exit
  console.log("Done!");
}

main();
