{
  writeShellApplication,
  ergogen,
  git,
  ...
}:

writeShellApplication {
  inheritPath = false;
  name = "generate";
  text = builtins.readFile ./script.bash;
  runtimeInputs = [
    git
    ergogen
  ];
}
