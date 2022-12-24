# TODO: pin deduplication

import requests
import re
import os


AUTH = os.environ["CLUSTER_TOKEN"]
ENDPOINT = os.environ["CLUSTER_ADDRESS"]


regex = re.compile(r"(Qm[a-zA-Z0-9]{44}|bafy[a-zA-Z0-9]{55})", flags=re.IGNORECASE)
local_cids = []

def find(path):
  with open(path, 'r') as file:
    content = file.read()
  for match in regex.findall(content):
    local_cids.append(match)


def pin_cid(cid):
  r = requests.post(ENDPOINT + f"/pins", json={
    "cid": cid,
    "name": "mineflake auto pin"
  }, headers={
    "Authorization": "Bearer " + AUTH,
  })
  r.raise_for_status()
  print(f"pinned cid: {cid}")


os.system("git diff --name-only HEAD HEAD~1 > changed_files.txt")
with open("changed_files.txt", 'r') as file:
  for line in file:
    print(f"checking file: {line.strip()}")
    find(line.strip())
os.remove("changed_files.txt")

local_cids = list(set(local_cids))
print(f"found {len(local_cids)} cids")


for cid in local_cids:
  pin_cid(cid)
