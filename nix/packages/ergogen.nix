{
  perSystem = { pkgs, ... }: {
    # Generates the output files from the source files.
    packages.ergogen = pkgs.buildNpmPackage {
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

      meta = with pkgs.lib; {
        description = "Ergonomic keyboard layout generator.";
        homepage = "https://ergogen.xyz";
        mainProgram = "ergogen";
        license = with licenses; [ mit ];
        maintainers = with maintainers; [
          Tygo-van-den-Hurk
        ];
      };
    };
  };
}
