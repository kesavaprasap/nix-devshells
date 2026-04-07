# Tool modules - Common development utilities and tools
{
  pkgs,
  lib,
  inputs,
  system,
}: {
  version-control = import ./version-control.nix {inherit pkgs lib;};
  nix-tools = import ./nix-tools.nix {inherit pkgs lib;};
  editors = import ./editors.nix {inherit pkgs lib inputs system;};
  utilities = import ./utilities.nix {inherit pkgs lib;};
  prompt = import ./prompt.nix {inherit pkgs lib;};
}
