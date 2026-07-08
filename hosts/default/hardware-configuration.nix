# =============================================================================
# THIS IS A PLACEHOLDER — install.sh replaces this file with your machine's real
# hardware-configuration.nix (via `nixos-generate-config`). Do NOT boot a real
# machine from this stub: it defines only a dummy root filesystem so that
# `nix flake check` / eval passes on CI where no real hardware profile exists.
# =============================================================================
#
# NixOS は root ("/") の fileSystems 定義が無いと "The `fileSystems' option does
# not specify your root file system." というアサーションで eval に失敗する。実機
# では install.sh が nixos-generate-config の出力でこのファイルを丸ごと置換する。
{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
