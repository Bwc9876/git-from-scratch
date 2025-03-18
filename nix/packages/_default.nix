{pkgs}:
pkgs.runCommand "git-from-scratch.pdf" {
  XDG_DATA_HOME = "${pkgs.plugins}";
  nativeBuildInputs = [pkgs.typst];
} ''
  typst compile ${../../index.typ} $out
''
