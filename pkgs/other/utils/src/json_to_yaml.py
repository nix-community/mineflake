#!/usr/bin/env python

from sys import argv
import yaml
import json

with open(argv[1], 'r') as f:
    inp = json.load(f)

with open(argv[2], 'w') as f:
    yaml.dump(inp, f)
