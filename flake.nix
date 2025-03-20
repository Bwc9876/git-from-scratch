{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };
  outputs = {flakelight, ...} @ inputs:
    flakelight ./. {
      inherit inputs;
      formatters = {
        "*.nix" = "alejandra .";
        "*.typ" = "typstyle format-all .";
      };
      devShell = {
        env = pkgs: {TYPST_PACKAGE_PATH = "${pkgs.plugins}";};
        packages = pkgs: with pkgs; [typst typstyle tinymist alejandra];
      };
    };
}
