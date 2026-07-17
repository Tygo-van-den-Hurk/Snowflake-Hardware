{
  perSystem = { pkgs, ... }: {
    # for converting JS CAD files to STL
    packages.openjscad = pkgs.stdenv.mkDerivation rec {
      pname = "openjscad";
      version = "1.6.1";

      src = pkgs.fetchFromGitHub {
        owner = "legacy-Tygo-van-den-Hurk";
        repo = "openjscad-cli-v${version}";
        tag = "v${version}";
        hash = "sha256-UPdyA1Bm6CEoh1KxDkaMyyBbDuC/vrBGzp7rIpGZ7pA=";
      };

      nativeBuildInputs = with pkgs; [
        makeWrapper
        nodejs
      ];

      buildPhase = /* SHELL */ ''
        runHook preBuild

        export nodejs="$(command -v node)"
        if [ -z "$nodejs" ]; then
          echo 'no node js in PATH?'
          exit 1
        fi

        makeWrapper "$nodejs" "$PWD/openjscad" \
          --add-flags "$src/node_modules/.bin/openjscad"

        runHook postBuild
      '';

      installPhase = /* SHELL */ ''
        runHook preInstall

        mkdir --parents "$out/bin"
        cp "$PWD/openjscad" "$out/bin/openjscad"

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "For creating parametric 2D and 3D designs with JavaScript code.";
        homepage = "https://openjscad.xyz/";
        mainProgram = "openjscad";
        license = with licenses; [ mit ];
        maintainers = with maintainers; [
          Tygo-van-den-Hurk
        ];
      };
    };
  };
}
