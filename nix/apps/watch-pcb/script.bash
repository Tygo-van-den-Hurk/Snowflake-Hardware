#!/usr/bin/env bash
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
if [ -n "${__SCRIPT_SELF_INIT__:-}" ]; then
  nix --option warn-dirty false \
    --option abort-on-warn true \
    run "$root#update-pcb"
else
  export __SCRIPT_SELF_INIT__="1"
  nodemon \
    --exec "$0" \
    --watch "$root/src/**/*.*" \
    --ext "yaml,yml,js"
fi
