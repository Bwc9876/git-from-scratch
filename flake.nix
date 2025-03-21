{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };
  outputs = {flakelight, ...} @ inputs:
    flakelight ./. ({lib, ...}: {
      inherit inputs;
      systems = lib.systems.flakeExposed;
      formatters = {
        "*.nix" = "alejandra .";
        "*.typ" = "typstyle -i index.typ";
      };
      devShell = {
        env = pkgs: {TYPST_PACKAGE_PATH = "${pkgs.plugins}";};
        packages = pkgs: with pkgs; [typst typstyle tinymist alejandra];
      };
    });
}
