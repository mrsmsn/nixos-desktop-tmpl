{ ... }:

{
  # ghostty の config は実行時に書き換わらないので read-only symlink で配布する。
  xdg.configFile."ghostty/config".source = ../../dotfiles/ghostty/config;
}
