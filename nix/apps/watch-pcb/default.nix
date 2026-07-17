{
  perSystem = { pkgs, ... }: {
    apps."watch-pcb" = {
      program = pkgs.callPackage ./package.nix { };
      type = "app";
    };
  };
}
