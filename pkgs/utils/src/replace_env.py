#!/usr/bin/env python

from sys import argv
from os import environ
import re

with open(argv[1], 'r') as f:
    inp = f.read()

default_envs = ['SHELL', '__ETC_PROFILE_DONE', 'XDG_CONFIG_DIRS', 'XCURSOR_PATH', 'NO_AT_BRIDGE', 'EDITOR', 'PWD', 'NIX_PROFILES', 'LOGNAME', 'XDG_SESSION_TYPE', 'NIX_PATH', 'SYSTEMD_EXEC_PID', 'NIXPKGS_CONFIG', 'HOME', 'SSH_ASKPASS', 'LANG', 'LS_COLORS', 'INVOCATION_ID', 'NIX_USER_PROFILE_DIR', 'INFOPATH', 'XDG_SESSION_CLASS', 'TERM', 'GTK_PATH', 'LESSOPEN', 'USER', 'TZDIR', 'SHLVL', 'PAGER', 'QTWEBKIT_PLUGIN_PATH', '__NIXOS_SET_ENVIRONMENT_DONE', 'XDG_SESSION_ID', 'LOCALE_ARCHIVE', 'LESSKEYIN_SYSTEM', 'TERMINFO_DIRS', 'MOZ_PLUGIN_PATH', 'NIX_REMOTE', 'XDG_RUNTIME_DIR', 'KDEDIRS', 'XDG_DATA_DIRS', 'LIBEXEC_PATH', 'PATH', 'DBUS_SESSION_BUS_ADDRESS', 'QT_PLUGIN_PATH', '_']

for env_name in environ:
    if env_name in default_envs:
        continue
    inp = inp.replace(f"#{env_name}#", environ[env_name])

with open(argv[2], 'w') as f:
    f.write(inp)
