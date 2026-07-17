{
  imports = [
    ./generate
    ./update-pcb
    ./watch-generate
    ./watch-pcb
  ];

  perSystem = { self', ... }: {
    apps.default = self'.apps.generate;
  };
}
