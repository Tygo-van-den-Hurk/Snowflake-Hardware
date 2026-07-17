set -e
root="$(git rev-parse --show-toplevel)"
nodemon \
  --exec "nix --option warn-dirty false --option abort-on-warn true run '$root#update-pcb'" \
  --watch "$root/src/**/*.*" \
  --ext "yaml,yml,js"
