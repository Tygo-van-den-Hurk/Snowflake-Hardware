{
  imports = [
    ./admesh.nix
    ./ergogen.nix
    ./openjscad.nix
    ./snowflake-hardware.nix
  ];

  perSystem = { self', ... }: {
    packages = with self'; {
      default = packages."snowflake-hardware";
    };
  };
}
