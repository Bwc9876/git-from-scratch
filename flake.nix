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
        env = pkgs: {TYPST_PLUGINS = "${pkgs.plugins}";};
        shellHook = ''
          export XDG_DATA_HOME=$(mktemp -d)
          ln -s $TYPST_PLUGINS/typst $XDG_DATA_HOME/typst
        '';
        packages = pkgs: with pkgs; [typstyle tinymist alejandra];
      };
    };
}
