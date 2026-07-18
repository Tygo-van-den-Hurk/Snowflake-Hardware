{
  writeShellApplication,
  nodemon,
  bash,
  git,
  nix,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "watch-pcb";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [
    nodemon
    bash
    git
    nix
  ];
}
