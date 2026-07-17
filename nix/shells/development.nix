{
  perSystem =
    {
      config,
      pkgs,
      self',
      ...
    }:
    let
      packages-from-nix = with pkgs; [
        kicad # View and wire the PCBs.
        yq # parse and print YAML
        openscad # manipulate 3D objects using SCAD.
        yamllint # parse and lint YAML. Nice for when ergogen says the yaml is invalid, but not why.
      ];

      packages-from-self = with self'.packages; [
        ergogen # generate the files from the config
        openjscad # generate the STL files from JScad files.
        admesh # CLI and C library for processing triangulated solid meshes.
      ];

      formatters = builtins.attrValues config.treefmt.build.programs;
      hooks = config.pre-commit.settings.enabledPackages;
      packages = packages-from-nix ++ packages-from-self;
      buildInputs = packages ++ formatters ++ hooks;

      shellHook = ''
        ${config.pre-commit.shellHook}
        if [ -f .env ]; then
          source .env
        fi
      '';
    in
    {
      devShells."development" = pkgs.mkShell {
        inherit buildInputs;
        inherit shellHook;
      };
    };
}
