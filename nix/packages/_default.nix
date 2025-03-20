{pkgs}:
pkgs.runCommand "git-from-scratch.pdf" {
  nativeBuildInputs = [pkgs.typst];
} ''
  cd ${../..}
  typst compile --package-path=${pkgs.plugins} ./index.typ $out
''
