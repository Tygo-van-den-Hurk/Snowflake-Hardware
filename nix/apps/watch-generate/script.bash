#!/usr/bin/env bash
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
nodemon \
  --exec "nix --option warn-dirty false --option abort-on-warn true run .#generate" \
  --watch "$root/src/**/*.*" \
  --ext "yaml,yml,js"
