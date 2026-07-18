{
  writeShellApplication,
  coreutils,
  git,
  nix,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "update-pcb";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [
    coreutils
    git
    nix
  ];
}
