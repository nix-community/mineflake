// require modules
import { Web3Storage } from "web3.storage";
import fs from "fs";
import crypto from "crypto";
import child_process from "child_process";

let uploaded = {};

async function exec_command(command) {
  return new Promise((resolve, reject) => {
    const child = child_process.exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      } else {
        resolve(stdout);
      }
    });
    child.stdout.pipe(process.stdout);
    child.stderr.pipe(process.stderr);
  });
}

async function main() {
  // load json file located at first CLI argument
  let config = JSON.parse(fs.readFileSync(process.argv[2]));

  // create a client
  const client = new Web3Storage({ token: process.env.WEB3STORAGE_TOKEN });

  // get all pinned files
  console.log("Getting all pinned files...");
  let files = client.list();
  for await (let file of files) {
    uploaded[file.name] = file.cid;
  }

  // initialize repo
  let repo = {};

  // iterate over config
  for (let name in config) {
    console.log(`Processing ${name}...`);

    // check if package.yml exists
    if (!fs.existsSync(`${config[name]}/package.yml`)) {
      console.log(`package.yml does not exist! Skipping...`);
      await exec_command(`rm -rf ${name}`);
      continue;
    }

    // create a zip file
    console.log(`Creating zip file...`);
    await exec_command(`rm -f ${name}.zip`);
    await exec_command(`rm -rf ${name}`);
    await exec_command(`cp -r ${config[name]} ${name}`);
    await exec_command(`chmod -R +w ${name}`);

    const _hash = crypto
      .createHash("sha256")
      .update(fs.readFileSync(`${name}/package.yml`))
      .digest("hex");
    const full = `${_hash}.zip`;

    // check if zip file already exists
    if (uploaded[full]) {
      console.log(`Zip file already exists! Skipping...`);
      await exec_command(`rm -rf ${name}`);
    } else {
      // set all timestamps to 2000-01-01 00:00:00
      await exec_command(
        `
      find ${name} -print | while read filename; do
        touch -a -m -t 200001010000.00 "$filename"
      done
    `
      );
      await exec_command(`zip -9 -r ${name}.zip ${name}`);
      await exec_command(`rm -rf ${name}`);

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

      // delete zip file
      fs.unlinkSync(`${name}.zip`);
    }

    // add cid to repo
    repo[name] = `https://w3s.link/ipfs/${uploaded[full]}/archive.zip`;

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
