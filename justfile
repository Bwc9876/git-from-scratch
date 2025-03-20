
# Preview server
watch:
  nix develop -c typst watch index.typ

shell:
  nix develop

build:
  nix build .#

