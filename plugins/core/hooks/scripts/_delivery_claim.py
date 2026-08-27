#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Parsing half of check-delivery-claim.sh — everything that is not a git call.

Two mistake classes this prevents, both of which a pure-bash hook would walk into:

1. **Unicode claim matching.** macOS ships bash 3.2, which has no `${var,,}` and
   whose `tr`/`grep -i` fold bytes, not codepoints — a Cyrillic (or any non-ASCII)
   claim phrase would silently never match, and a guard that silently never fires
   is worse than no guard. Python lowercases properly.
2. **Receipt reading without a second JSON parser.** The receipt is JSON; bash
   would need jq and a hand-rolled staleness comparison.

Subcommands
-----------
claims <yml_path>
    Reads the hook payload JSON on stdin, reads the phrase lists out of the
    project's dotclaude.yml, prints one `<rung>\\t<matched phrase>` line per rung
    the message claims. No claim -> no output.

receipt <receipt_path> <head> <dirty_hash>
    Prints ONE verdict token plus optional detail, tab-separated:
      OK | MISSING | UNREADABLE | RED\\t<n> | SKIPPED\\t<n> | STALE\\t<what>

Exit status is 0 for a normal answer and 3 when the caller passed nonsense —
never a nonzero the caller could mistake for a verdict.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _read_dotclaude_yml as ydr  # noqa: E402  (same dir; one YAML parser, not two)

# The rungs, weakest first. Each names a claim class and the evidence that settles
# it; the evidence itself is gathered by the shell half, which owns the git calls.
RUNGS = ("committed", "merged", "pushed", "verified")

# Shipped English defaults. The plugin must stay project-agnostic (CONTRIBUTING),
# so a project's own vocabulary — its language, its domain words — is added via
# dotclaude.yml rather than hardcoded here.
#
# These lists are deliberately SENSITIVE rather than precise. A false phrase match
# costs nothing: the shell half blocks only when the state actually contradicts the
# claim, so a stray "pushed" in prose over an already-pushed repo is silent.
DEFAULT_PHRASES = {
    "committed": ["committed", "commit landed", "commit is in"],
    "merged": ["merged into main", "merged to main", "merged into master",
               "merged to master", "merge landed"],
    "pushed": ["pushed", "push landed", "pushed to origin"],
    "verified": ["all gates green", "gates are green", "gates green",
                 "all green", "all checks pass", "all tests pass",
                 "every gate passed"],
}

# Not a rung — a NARROWING of the "verified" claim. When the message itself says
# some gates were skipped, "green" has stopped asserting "everything passed", which
# is the legitimate "correct the wording" way past the gate. Without this the rung is
# unsatisfiable wherever a gate is legitimately unavailable (no node toolchain, no
# docker), and an unsatisfiable gate gets switched off.
DEFAULT_SKIP_ACK = ["skipped", "skipping", "except", "apart from", "other than"]

CONFIG_KEY = {
    # Flat keys on purpose — see the note in check-delivery-claim.sh. The bundled
    # minimal YAML parser (used when PyYAML is absent) reads exactly two levels.
    "committed": "delivery.claimsCommitted",
    "merged": "delivery.claimsMerged",
    "pushed": "delivery.claimsPushed",
    "verified": "delivery.claimsVerified",
}


def _fold(s):
    """Lowercase for comparison, and treat Russian yo as ye — both spellings of a
    word like zelyonye/zelenye are the same claim, and requiring the author to
    list both is a trap that fails open."""
    return s.lower().replace("ё", "е").replace("Ё", "Е")


def _as_list(node):
    if node is None:
        return []
    if isinstance(node, str):
        return [node]
    if isinstance(node, list):
        return [str(x) for x in node if str(x).strip()]
    return []


def cmd_claims(yml_path):
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # unparseable payload -> no claim detected -> hook stays silent
    msg = payload.get("last_assistant_message") or ""
    if not msg.strip():
        return 0

    cfg = ydr.load(yml_path)
    hay = _fold(msg)
    found_any_phrase = False

    for rung in RUNGS:
        phrases = list(DEFAULT_PHRASES[rung])
        phrases += _as_list(ydr.lookup(cfg, CONFIG_KEY[rung]))
        if phrases:
            found_any_phrase = True
        # Longest first, so the report names the most specific phrase that matched
        # ("merged into main" rather than the "merged" inside it).
        for p in sorted(set(phrases), key=len, reverse=True):
            if _fold(p) in hay:
                sys.stdout.write("%s\t%s\n" % (rung, p))
                break

    ack = list(DEFAULT_SKIP_ACK) + _as_list(ydr.lookup(cfg, "delivery.claimsSkipAck"))
    for p in sorted(set(ack), key=len, reverse=True):
        if _fold(p) in hay:
            sys.stdout.write("_skipack\t%s\n" % p)
            break

    if not found_any_phrase:
        # A delivery: block exists (the shell half checked) but not one phrase
        # resolved — almost certainly a config that did not parse. Say so; a guard
        # that goes quiet because its own configuration failed is the exact failure
        # this file's docstring opens with.
        sys.stderr.write("delivery: no claim phrases resolved from %s\n" % yml_path)
    return 0


def cmd_receipt(path, tree):
    if not os.path.isfile(path):
        sys.stdout.write("MISSING\n")
        return 0
    try:
        r = json.load(open(path, encoding="utf-8"))
    except Exception:
        sys.stdout.write("UNREADABLE\n")
        return 0

    # Staleness first: a receipt for a different tree says nothing about this one,
    # however green it was. The fingerprint is the tree AS IT WOULD BE COMMITTED,
    # so it survives `git add` and `git commit` and moves only on a real edit.
    recorded = str(r.get("tree", ""))
    if not recorded:
        sys.stdout.write("STALE\tthe receipt records no tree fingerprint\n")
        return 0
    if not tree:
        sys.stdout.write("STALE\tthis tree's fingerprint could not be computed\n")
        return 0
    if recorded != tree:
        sys.stdout.write("STALE\tthe tree changed since the run (%s -> %s)\n"
                         % (recorded[:12], tree[:12]))
        return 0

    failed = int(r.get("failed") or 0)
    if failed:
        sys.stdout.write("RED\t%d\n" % failed)
        return 0
    skipped = int(r.get("skipped") or 0)
    if skipped:
        sys.stdout.write("SKIPPED\t%d\n" % skipped)
        return 0
    sys.stdout.write("OK\n")
    return 0


def main():
    if len(sys.argv) < 2:
        return 3
    what = sys.argv[1]
    if what == "claims" and len(sys.argv) == 3:
        return cmd_claims(sys.argv[2])
    if what == "receipt" and len(sys.argv) == 4:
        return cmd_receipt(sys.argv[2], sys.argv[3])
    return 3


if __name__ == "__main__":
    sys.exit(main())
