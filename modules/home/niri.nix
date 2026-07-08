{ ... }:

{
  # niri の config.kdl は実行時に書き換わらないので read-only symlink で配布する。
  # 変更は dotfiles/niri/config.kdl を編集して rebuild する。
  xdg.configFile."niri/config.kdl".source = ../../dotfiles/niri/config.kdl;
}
