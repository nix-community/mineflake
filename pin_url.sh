#!/usr/bin/env bash

wget -O /tmp/file $1
ipfs-cluster-ctl --host /dns4/rat.frsqr.xyz/tcp/9094 --basic-auth default:$CLUSTER_SECRET add /tmp/file -Q --name mineflake > /tmp/cid
URL="https://static.ipfsqr.ru/ipfs/$(cat /tmp/cid)"
nix-prefetch-url $URL
echo $URL
