{
  perSystem = { pkgs, self', ... }: {
    apps."generate" = {
      type = "app";
      program = pkgs.callPackage ./package.nix {
        inherit (self'.packages) ergogen;
      };
    };
  };
}
