{
  perSystem = { pkgs, ... }: {
    apps."watch-generate" = {
      program = pkgs.callPackage ./package.nix { };
      type = "app";
    };
  };
}
