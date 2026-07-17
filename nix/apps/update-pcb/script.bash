set -e
root="$(git rev-parse --show-toplevel)"
nix --option warn-dirty false --option abort-on-warn true run "$root#generate"
cp "$root/output/pcbs"/* "$root/kicad/"
