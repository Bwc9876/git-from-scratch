{pkgs}: let
  typst-packages = pkgs.fetchgit {
    url = "https://github.com/typst/packages.git";
    rev = "34318a0f1877b9244f5ce12917e628b52975db1f";
    sparseCheckout = map (p: "packages/preview/${p}") [
      "fletcher/0.5.7"
      "cetz/0.3.3"
      "touying/0.6.1"
      "tidy/0.4.1"
      "valkyrie/0.2.2"
    ];
    hash = "sha256-8mW3Z2ozmH+G5ABhpcf5TCgPPTCA1xSdueukpo6xx8c=";
  };
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "typst";
    rev = "7e5cfc07d6833cef888f251235265c08ce480fcc";
    hash = "sha256-Zb+H5aHDXBcWOYV5le2OcQCVz341qd69+MHlQqYw3eg=";
  };
in
  pkgs.runCommand "plugins-dir" {} ''
    mkdir -p $out/typst/packages
    mkdir -p $out/typst/packages/local/catppuccin
    ln -s ${catppuccin} $out/typst/packages/local/catppuccin/1.0.0
    ln -s ${typst-packages}/packages/preview $out/typst/packages/preview
  ''
