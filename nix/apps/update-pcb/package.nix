{
  writeShellApplication,
  git,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "update-pcb";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [ git ];
}
