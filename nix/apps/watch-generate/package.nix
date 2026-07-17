{
  writeShellApplication,
  nodemon,
  git,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "watch-pcb";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [
    git
    nodemon
  ];
}
