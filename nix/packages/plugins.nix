{pkgs}: let
  typst-packages = pkgs.fetchgit {
    url = "https://github.com/typst/packages.git";
    rev = "34318a0f1877b9244f5ce12917e628b52975db1f";
    sparseCheckout = map (p: "packages/preview/${p}") [
      "fletcher/0.5.7"
      "cetz/0.3.4"
      "touying/0.6.1"
      "tidy/0.4.1"
      "valkyrie/0.2.2"
      "oxifmt/0.2.1"
    ];
    hash = "sha256-VPs+0pODV4wbrD++rP6QUVTbB2L7Ro6mL+DfA8h5bMA=";
  };
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "typst";
    rev = "7e5cfc07d6833cef888f251235265c08ce480fcc";
    hash = "sha256-Zb+H5aHDXBcWOYV5le2OcQCVz341qd69+MHlQqYw3eg=";
  };
in
  pkgs.runCommand "plugins-dir" {} ''
    mkdir -p $out
    mkdir -p $out/local/catppuccin
    ln -s ${catppuccin} $out/local/catppuccin/1.0.0
    ln -s ${typst-packages}/packages/preview $out/preview
  ''
