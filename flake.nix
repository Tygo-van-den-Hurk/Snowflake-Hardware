{
  description = "The flake that is used add Node and a couple of other programs to the shell.";

  # A collection of packages for the Nix package manager
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # Flake basics described using the module system
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # Seamless integration of https://pre-commit.com git hooks with Nix.
  inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.flake-compat.follows = "flake-compat";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Allow flakes to be used with Nix < 2.4
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  # treefmt nix configuration modules
  inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # The outputs are defined in ./nix
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [ ./nix ];
    };
}

#   outputs1 =
#     inputs@{
#       self,
#       nixpkgs,
#       flake-utils,
#       treefmt-nix,
#       ...
#     }:
#     flake-utils.lib.eachDefaultSystem (
#       system:
#       let

#         pkgs = import nixpkgs { inherit system; };
#         treefmtEval = treefmt-nix.lib.evalModule pkgs ./.config/treefmt.nix;
#         pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run (import ./.config/pre-commit.nix);
#         inherit (pkgs) lib;

#       in
#       rec {
#         # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

#         packages = rec {

#           default = pkgs.stdenv.mkDerivation rec {
#             name = "pcb";
#             src = ./.;
#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive ${hardware} $out/hardware
#               cp --recursive ${software} $out/software

#               runHook postInstall
#             '';
#           };

#           #| ---------------------------------------------- Hardware ----------------------------------------------- |#

#           # all the hardware files, excluding post processing
#           hardware-raw = pkgs.stdenv.mkDerivation rec {
#             name = "hardware-raw";
#             src = ./hardware/src;

#             buildPhase = ''
#               runHook preBuild

#               ${ergogen}/bin/ergogen --clean --output output --debug .

#               runHook postBuild
#             '';

#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive output/* $out

#               runHook postInstall
#             '';
#           };

#           # all the hardware files, including post processing
#           hardware = pkgs.stdenv.mkDerivation rec {
#             name = "hardware";
#             src = ./hardware/src;
#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out/cases
#               cp --recursive ${cases}/* $out/cases

#               mkdir --parents $out/pcbs
#               cp --recursive ${pcbs}/* $out/pcbs

#               mkdir --parents $out/outlines
#               cp --recursive ${outlines}/* $out/outlines

#               mkdir --parents $out/points
#               cp --recursive ${points}/* $out/points

#               mkdir --parents $out/source
#               cp --recursive ${hardware-raw}/source/* $out/source

#               runHook postInstall
#             '';
#           };

#           pcbs = pkgs.stdenv.mkDerivation rec {
#             name = "pcb";
#             src = ./hardware/src;
#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive ${hardware-raw}/pcbs/* $out

#               runHook postInstall
#             '';
#           };

#           outlines = pkgs.stdenv.mkDerivation rec {
#             name = "outlines";
#             src = ./hardware/src;

#             buildPhase = ''
#               runHook preBuild

#               root="$(pwd)"
#               mkdir --parents $root/outlines
#               for outline in ${hardware-raw}/outlines/*; do
#                 if [ -f "$outline" ]; then
#                   name=$(basename "$outline" | sed 's/\..*//')
#                   if [[ "$name" == _* ]]; then
#                     echo "$outline starts with '_', skipping..."
#                     continue
#                   fi
#                   mkdir --parents $root/outlines/$name/
#                   cp $outline $root/outlines/$name/
#                 else
#                   echo "$outline is not a file, skipping..."
#                 fi
#               done

#               runHook postBuild
#             '';

#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive $root/outlines/* $out

#               runHook postInstall
#             '';
#           };

#           points = pkgs.stdenv.mkDerivation rec {
#             name = "points";
#             src = ./hardware/src;
#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive ${hardware-raw}/points/* $out

#               runHook postInstall
#             '';
#           };

#           cases = pkgs.stdenv.mkDerivation rec {
#             name = "cases";
#             src = ./hardware/src;

#             buildPhase = ''
#               runHook preBuild

#               echo "Creating the mirror scad script..."
#               mirror_scad_script="$(pwd)/mirror.scad"
#               echo "mirror([1,0,0]) import(input);" > $mirror_scad_script
#               echo "" >> $mirror_scad_script
#               cat $mirror_scad_script

#               root="$(pwd)/cases"
#               mkdir --parents $root
#               for case in ${hardware-raw}/cases/*; do

#                 echo "making sure it is a file..."
#                 if [ ! -f "$case" ]; then
#                   echo "$case is not a file, skipping..."
#                 fi

#                 name=$(basename "$case" | sed 's/\..*//')

#                 echo "making sure it is not a private file..."
#                 if [[ "$name" == _* ]]; then
#                   echo "$case starts with '_', skipping..."
#                   continue
#                 fi

#                 echo "Now processing '$name' case"
#                 mkdir --parents $root/$name/left
#                 mkdir --parents $root/$name/right

#                 echo "trying to convert: '$name' into an STL file..."
#                 ${openjscad}/bin/openjscad $case -o $root/$name/left/case.raw.stl

#                 echo "Checking $root/$name/left/case.raw.stl for mistakes and fixing them"
#                 ${admesh}/bin/admesh $root/$name/left/case.raw.stl \
#                   --tolerance=1e-5 --iterations=3 --increment=5e-7 \
#                   --fill-holes --remove-unconnected --nearby \
#                   --normal-directions --exact --normal-values \
#                   --write-binary-stl=$root/$name/left/case.binary.stl \
#                   --write-ascii-stl=$root/$name/left/case.ascii.stl \
#                   --write-dxf=$root/$name/left/case.dxf \
#                   --write-off=$root/$name/left/case.off \
#                   --write-vrml=$root/$name/left/case.vrml

#                 echo "trying to mirror: '$name' into a right version..."
#                 ${pkgs.openscad}/bin/openscad -o "$root/$name/right/case.raw.stl" \
#                   -D "input=\"$root/$name/left/case.raw.stl\"" "$mirror_scad_script"

#                 echo ""
#                 echo "Checking $root/$name/right/case.raw.stl for mistakes and fixing them"
#                 ${admesh}/bin/admesh $root/$name/right/case.raw.stl \
#                   --tolerance=1e-5 --iterations=3 --increment=5e-7 \
#                   --fill-holes --remove-unconnected --nearby \
#                   --normal-directions --exact --normal-values \
#                   --write-binary-stl=$root/$name/right/case.binary.stl \
#                   --write-ascii-stl=$root/$name/right/case.ascii.stl \
#                   --write-dxf=$root/$name/right/case.dxf \
#                   --write-off=$root/$name/right/case.off \
#                   --write-vrml=$root/$name/right/case.vrml

#                 cp $case $root/$name/blueprint.jscad
#               done

#               runHook postBuild
#             '';

#             installPhase = ''
#               runHook preInstall

#               mkdir --parents $out
#               cp --recursive $root/* $out

#               runHook postInstall
#             '';
#           };

#         };
#       }
#     );
# }
