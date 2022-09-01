#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name='mineflake-utils',
      version='1.0',
      packages=find_packages(),
      scripts=["json_to_yaml.py", "json_to_toml.py", "format_json.py", "replace_env.py"],
     )