{
  perSystem = { pkgs, ... }: {
    # CLI and C library for processing triangulated solid meshes.
    packages.admesh = pkgs.stdenv.mkDerivation rec {
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
}
