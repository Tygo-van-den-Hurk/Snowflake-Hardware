{
  writeShellApplication,
  ergogen,
  git,
  nix,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "generate";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [
    ergogen
    git
    nix
  ];
}
