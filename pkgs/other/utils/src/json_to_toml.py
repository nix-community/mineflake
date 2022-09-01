#!/usr/bin/env python

from sys import argv
import toml
import json

with open(argv[1], 'r') as f:
    inp = json.load(f)

with open(argv[2], 'w') as f:
    toml.dump(inp, f)
