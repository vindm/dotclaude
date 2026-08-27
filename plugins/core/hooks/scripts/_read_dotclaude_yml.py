#!/usr/bin/env python3
"""Read one key from a project's dotclaude.yml for the consumed hooks.

Usage: _read_dotclaude_yml.py <yml_path> <dotted.key> [default]
  - a scalar prints on one line
  - a list prints one item per line
  - a missing key prints the default (nothing if no default given)

Zero hard dependency: uses PyYAML when importable, otherwise a minimal parser
for dotclaude.yml's simple two-level shape (top-level key -> scalar, or a block
of nested scalars and simple `- item` lists). If neither works, the caller's
default stands, so a hook degrades to its built-in behaviour rather than break.
"""
import os
import sys


def _scalar(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ("'", '"'):
        return s[1:-1]
    return s


def _minimal_parse(text):
    """Handle exactly dotclaude.yml's controlled structure — no full YAML."""
    data = {}
    top = None
    last_list_key = None
    for raw in text.splitlines():
        line = raw.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        if indent == 0:
            key, sep, val = stripped.partition(":")
            key, val = key.strip(), val.strip()
            if val:
                data[key] = _scalar(val)
                top = None
            else:
                data[key] = {}
                top = key
            last_list_key = None
        elif top is not None:
            if stripped.startswith("- "):
                if last_list_key is not None:
                    data[top][last_list_key].append(_scalar(stripped[2:]))
            else:
                key, sep, val = stripped.partition(":")
                key, val = key.strip(), val.strip()
                if val:
                    data[top][key] = _scalar(val)
                    last_list_key = None
                else:
                    data[top][key] = []
                    last_list_key = key
    return data


def load(path):
    """Parse a dotclaude.yml into a dict. Never raises — an unreadable or
    unparseable file yields {} so every caller degrades to its own default."""
    if not os.path.isfile(path):
        return {}
    try:
        text = open(path, encoding="utf-8").read()
    except Exception:
        return {}
    try:
        import yaml  # optional; not a required dependency
        return yaml.safe_load(text) or {}
    except Exception:
        pass
    try:
        return _minimal_parse(text)
    except Exception:
        return {}


def lookup(data, key):
    """Walk a dotted key. Returns None when any segment is missing."""
    node = data
    for part in key.split("."):
        if isinstance(node, dict) and part in node:
            node = node[part]
        else:
            return None
    return node


def main():
    if len(sys.argv) < 3:
        return 1
    path, key = sys.argv[1], sys.argv[2]
    default = sys.argv[3] if len(sys.argv) > 3 else ""
    node = lookup(load(path), key)
    if node is None:
        if default:
            print(default)
        return 0
    if isinstance(node, list):
        for item in node:
            print(item)
    elif isinstance(node, dict):
        pass
    else:
        print(node)
    return 0


if __name__ == "__main__":
    sys.exit(main())
