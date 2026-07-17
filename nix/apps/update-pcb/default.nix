{
  perSystem = { pkgs, ... }: {
    apps."update-pcb" = {
      program = pkgs.callPackage ./package.nix { };
      type = "app";
    };
  };
}
