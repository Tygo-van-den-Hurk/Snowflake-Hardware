set -e

root="$(git rev-parse --show-toplevel)"

source="$root/src"
[ ! -d "$source" ] && {
  echo creating source directory: "$source"
  rm -rf "$source"
  mkdir --parents "$source"
}

output="$root/output"
[ ! -d "$output" ] && {
  echo creating output directory: "$output"
  rm -rf "$output"
  mkdir --parents "$output"
}

ergogen "$source" --debug --clean --output "$output"
