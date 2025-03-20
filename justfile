watch:
  nix develop -c typst watch index.typ

shell:
  nix develop

update:
  nix flake update

edit:
  nix develop -c nvim index.typ

build:
  nix build .#

