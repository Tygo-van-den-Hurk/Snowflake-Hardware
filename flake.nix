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
                  --watch "./hardware/src/**/*.*" \
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
                  --watch "./hardware/src/**/*.*" \
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
            ])
            ++ (with pkgs; [
              act # Run / check GitHub Actions locally.
              git # Pull, commit, and push changes.
              kicad # View and wire the PCBs.
              yq # parse and print YAML
              yamllint # parse and lint YAML. Nice for when ergogen says the yaml is invalid, but not why.
            ]);
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Nix Build ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

        packages = rec {

          default = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./.;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${hardware} $out/hardware
              cp --recursive ${software} $out/software

              runHook postInstall
            '';
          };

          #| ---------------------------------------------- Software ----------------------------------------------- |#

          software = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./software;

            buildPhase = ''
              runHook preBuild

              # ...

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out

              runHook postInstall
            '';
          };

          #| ---------------------------------------------- Hardware ----------------------------------------------- |#

          # all the hardware files, excluding post processing
          hardware-raw = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;

            buildPhase = ''
              runHook preBuild

              ${ergogen}/bin/ergogen --clean --output output --debug .

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive output/* $out

              runHook postInstall
            '';
          };

          # all the hardware files, including post processing
          hardware = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out/cases
              cp --recursive ${cases}/* $out/cases

              mkdir --parents $out/pcbs
              cp --recursive ${pcbs}/* $out/pcbs

              mkdir --parents $out/outlines
              cp --recursive ${outlines}/* $out/outlines

              mkdir --parents $out/points
              cp --recursive ${points}/* $out/points

              mkdir --parents $out/source
              cp --recursive ${hardware-raw}/source/* $out/source

              runHook postInstall
            '';
          };

          pcbs = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${hardware-raw}/pcbs/* $out

              runHook postInstall
            '';
          };

          outlines = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;

            buildPhase = ''
              runHook preBuild

              root="$(pwd)"
              mkdir --parents $root/outlines
              for outline in ${hardware-raw}/outlines/*; do
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

              mkdir --parents $out
              cp --recursive $root/outlines/* $out

              runHook postInstall
            '';
          };

          points = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;
            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive ${hardware-raw}/points/* $out

              runHook postInstall
            '';
          };

          cases = pkgs.stdenv.mkDerivation rec {
            name = "pcb";
            src = ./hardware/src;

            buildPhase = ''
              runHook preBuild

              root="$(pwd)/cases"
              mkdir --parents $root
              for case in ${hardware-raw}/cases/*; do
                if [ -f "$case" ]; then
                  name=$(basename "$case" | sed 's/\..*//')
                  # if [[ "$name" == _* ]]; then
                  #   echo "$case starts with '_', skipping..."
                  #   continue
                  # fi
                  mkdir --parents $root/$name/
                  echo "trying to convert: $case into an STL file..."
                  ${openjscad}/bin/openjscad $case -o $root/$name/$name.stl
                  cp ${hardware-raw}/cases/$name* $root/$name/
                else
                  echo "$case is not a file, skipping..."
                fi
              done

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir --parents $out
              cp --recursive $root/* $out

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
        };

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
      }
    );
}
