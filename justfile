# Day-2 operations for this NixOS desktop template.
# Run `just` (or `just default`) to see this list.

default:
    @just --list

# Rebuild and activate the system for the current host.
switch:
    sudo nixos-rebuild switch --flake .#$(hostname)

# Evaluate the flake without building derivations (same check CI runs).
check:
    nix flake check --no-build

# Apply nixfmt formatting to all Nix files.
fmt:
    nix fmt

# Bump all flake inputs to their latest revisions.
update:
    nix flake update
