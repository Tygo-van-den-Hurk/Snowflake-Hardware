{
  description = "The flake that is used add Node and a couple of other programs to the shell.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./.config/treefmt.nix;
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run (import ./.config/pre-commit.nix);
        inherit (pkgs) lib;

      in
      rec {
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Flake Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        checks = packages // {
          formatting = treefmtEval.config.build.check self;
          inherit pre-commit-check;
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Fmt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        formatter = treefmtEval.config.build.wrapper;

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Run ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        apps = {

          ergogen = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "ergogen" ''
                set -e

                root="$(git rev-parse --show-toplevel)/hardware"

                src="$root/src"
                [ -d $src ] && mkdir --parents $src

                out="$root/output"
                [ -d $out ] && mkdir --parents $out

                ${packages.ergogen}/bin/ergogen --debug --clean $src --output $out
              ''
            );
          };

          update-pcb = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "update-pcb" ''
                set -e
                nix run .#ergogen
                root="$(git rev-parse --show-toplevel)/hardware"
                cp $root/output/pcbs/* $root/kicad/
              ''
            );
          };

          watch-ergogen = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "watch-ergogen" ''
                set -e
                ${pkgs.nodemon}/bin/nodemon \
                  --exec "nix run .#ergogen" \
                  --watch "./src/**/*.*" \
                  --ext "yaml,yml,js"
              ''
            );
          };

          watch-pcb = {
            type = "app";
            program = builtins.toString (
              pkgs.writeShellScript "watch-ergogen" ''
                set -e
                ${pkgs.nodemon}/bin/nodemon \
                  --exec "nix run .#update-pcb" \
                  --watch "./src/**/*.*" \
                  --ext "yaml,yml,js"
              ''
            );
          };
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Develop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        devShells.default = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          nativeBuildInputs =
            pre-commit-check.enabledPackages # the packages for running/testing pre-commit hooks
            ++ (with packages; [
              ergogen # generate the files from the config
              openjscad # generate the STL files from JScad files.
              admesh # CLI and C library for processing triangulated solid meshes.
            ])
            ++ (with pkgs; [
              act # Run / check GitHub Actions locally.
              git # Pull, commit, and push changes.
              kicad # View and wire the PCBs.
              yq # parse and print YAML
              openscad # manipulate 3D objects using SCAD.
              yamllint # parse and lint YAML. Nice for when ergogen says the yaml is invalid, but not why.
            ]);
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        packages = rec {

          default = hardware;

          #| ---------------------------------------------- Hardware ----------------------------------------------- |#

          # all the hardware files, excluding post processing
          hardware-raw = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;

            buildPhase = ''
              runHook preBuild

              ${ergogen}/bin/ergogen --clean --output output --debug .

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share
              cp --recursive output/* $out/share

              runHook postInstall
            '';
          };

          # all the hardware files, including post processing
          hardware = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share/cases
              cp --recursive ${cases}/share/* $out/share/cases

              mkdir --parents $out/share/pcbs
              cp --recursive ${pcbs}/share/* $out/share/pcbs

              mkdir --parents $out/share/outlines
              cp --recursive ${outlines}/share/* $out/share/outlines

              mkdir --parents $out/share/points
              cp --recursive ${points}/share/* $out/share/points

              mkdir --parents $out/share/source
              cp --recursive ${hardware-raw}/share/source/* $out/share/source

              runHook postInstall
            '';
          };

          pcbs = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share
              cp --recursive ${hardware-raw}/share/pcbs/* $out/share

              runHook postInstall
            '';
          };

          outlines = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;

            buildPhase = ''
              runHook preBuild

              root="$(pwd)"
              mkdir --parents $root/outlines
              for outline in ${hardware-raw}/share/outlines/*; do
                if [ -f "$outline" ]; then
                  name=$(basename "$outline" | sed 's/\..*//')
                  if [[ "$name" == _* ]]; then
                    echo "$outline starts with '_', skipping..."
                    continue
                  fi
                  mkdir --parents $root/outlines/$name/
                  cp $outline $root/outlines/$name/
                else
                  echo "$outline is not a file, skipping..."
                fi
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share
              cp --recursive $root/outlines/* $out/share

              runHook postInstall
            '';
          };

          points = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share
              cp --recursive ${hardware-raw}/share/points/* $out/share

              runHook postInstall
            '';
          };

          cases = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./src;

            buildPhase = ''
              runHook preBuild

              echo "Creating the mirror scad script..."
              mirror_scad_script="$(pwd)/mirror.scad"
              echo "mirror([1,0,0]) import(input);" > $mirror_scad_script
              echo "" >> $mirror_scad_script
              cat $mirror_scad_script

              root="$(pwd)/cases"
              mkdir --parents $root
              for case in ${hardware-raw}/share/cases/*; do

                echo "making sure it is a file..."
                if [ ! -f "$case" ]; then
                  echo "$case is not a file, skipping..."
                fi

                name=$(basename "$case" | sed 's/\..*//')

                echo "making sure it is not a private file..."
                if [[ "$name" == _* ]]; then
                  echo "$case starts with '_', skipping..."
                  continue
                fi

                echo "Now processing '$name' case"
                mkdir --parents $root/$name/left
                mkdir --parents $root/$name/right

                echo "trying to convert: '$name' into an STL file..."
                ${openjscad}/bin/openjscad $case -o $root/$name/left/case.raw.stl

                echo "Checking $root/$name/left/case.raw.stl for mistakes and fixing them"
                ${admesh}/bin/admesh $root/$name/left/case.raw.stl \
                  --tolerance=1e-5 --iterations=3 --increment=5e-7 \
                  --fill-holes --remove-unconnected --nearby \
                  --normal-directions --exact --normal-values \
                  --write-binary-stl=$root/$name/left/case.binary.stl \
                  --write-ascii-stl=$root/$name/left/case.ascii.stl \
                  --write-dxf=$root/$name/left/case.dxf \
                  --write-off=$root/$name/left/case.off \
                  --write-vrml=$root/$name/left/case.vrml

                echo "trying to mirror: '$name' into a right version..."
                ${pkgs.openscad}/bin/openscad -o "$root/$name/right/case.raw.stl" \
                  -D "input=\"$root/$name/left/case.raw.stl\"" "$mirror_scad_script"

                echo ""
                echo "Checking $root/$name/right/case.raw.stl for mistakes and fixing them"
                ${admesh}/bin/admesh $root/$name/right/case.raw.stl \
                  --tolerance=1e-5 --iterations=3 --increment=5e-7 \
                  --fill-holes --remove-unconnected --nearby \
                  --normal-directions --exact --normal-values \
                  --write-binary-stl=$root/$name/right/case.binary.stl \
                  --write-ascii-stl=$root/$name/right/case.ascii.stl \
                  --write-dxf=$root/$name/right/case.dxf \
                  --write-off=$root/$name/right/case.off \
                  --write-vrml=$root/$name/right/case.vrml

                cp $case $root/$name/blueprint.jscad
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out/share
              cp --recursive $root/* $out/share

              runHook postInstall
            '';
          };

          #| --------------------------------------------- Dependencies -------------------------------------------- |#

          # for reading the config and generating the files.
          ergogen = pkgs.buildNpmPackage {
            pname = "ergogen";
            version = "4.0.2";

            forceGitDeps = true;

            src = pkgs.fetchFromGitHub {
              owner = "ergogen";
              repo = "ergogen";
              tag = "v4.0.2";
              hash = "sha256-RP+mDjL6M+gHFrQvFd7iZaL2aQXk+6gQEUf0tWaTp3g=";
            };

            npmDepsHash = "sha256-zsC8QcrEy9Ie7xaad/pk5D6wL8NgMdgfymAiGy8vnsY=";

            makeCacheWritable = true;
            dontNpmBuild = true;
            npmPackFlags = [ "--ignore-scripts" ];
            NODE_OPTIONS = "--openssl-legacy-provider";

            doInstallCheck = true;
            nativeInstallCheckInputs = [ pkgs.versionCheckHook ];

            passthru.updateScript = pkgs.nix-update-script { };

            meta = {
              description = "Ergonomic keyboard layout generator.";
              homepage = "https://ergogen.xyz";
              mainProgram = "ergogen";
              license = lib.licenses.mit;
            };
          };

          # for converting JS CAD files to STL
          openjscad = pkgs.stdenv.mkDerivation rec {
            pname = "openjscad";
            version = "1.6.1";

            src = pkgs.fetchFromGitHub {
              owner = "legacy-Tygo-van-den-Hurk/";
              repo = "openjscad-cli-v${version}";
              tag = "v${version}";
              hash = "sha256-UPdyA1Bm6CEoh1KxDkaMyyBbDuC/vrBGzp7rIpGZ7pA=";
            };

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -p $out/bin
              makeWrapper ${pkgs.nodejs}/bin/node $out/bin/openjscad \
                --add-flags "${src}/node_modules/.bin/openjscad"
            '';
          };

          # CLI and C library for processing triangulated solid meshes.
          admesh = pkgs.stdenv.mkDerivation rec {
            pname = "admesh";
            version = "0.98.5";

            src = pkgs.fetchFromGitHub {
              owner = "admesh";
              repo = "admesh";
              tag = "v${version}";
              hash = "sha256-zlv5fhpKdoN10qEIRYc80gJ+DHwH8tBsrWDe7Qs/ClM=";
            };

            nativeBuildInputs = with pkgs; [ autoreconfHook ];

            preBuild = ''
              # skip ChangeLog and AUTHORS generation
              sed -i '/^ChangeLog/d' Makefile
              sed -i '/^AUTHORS/d' Makefile
              touch ChangeLog AUTHORS
            '';

            meta = with pkgs.lib; {
              description = "CLI and C library for processing triangulated solid meshes.";
              homepage = "https://github.com/admesh/admesh";
              license = licenses.gpl2Plus;
              platforms = platforms.unix;
              maintainers = with maintainers; [
                Tygo-van-den-Hurk
              ];
            };
          };

        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
      }
    );
}
