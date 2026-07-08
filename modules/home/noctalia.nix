{
  noctalia,
  vars,
  config,
  pkgs,
  lib,
  ...
}:

let
  # noctalia の settings シード先。noctalia は実行時にこのファイルを読み書きするため、
  # パスが変わってもここ 1 行の修正で済むよう let 変数に集約する
  # (元 repo 実績: ~/.local/state/noctalia/settings.toml)。
  settingsPath = "${config.xdg.stateHome}/noctalia/settings.toml";

  # @HOME@ プレースホルダを実 HOME に展開した settings.toml を store に生成する。
  seededSettings = pkgs.writeText "noctalia-settings.toml" (
    builtins.replaceStrings [ "@HOME@" ] [ config.home.homeDirectory ] (
      builtins.readFile ../../dotfiles/noctalia/settings.toml
    )
  );
in
{
  imports = [ noctalia.homeModules.default ];

  programs.noctalia.enable = true;

  # 壁紙 PNG (assets/wallpapers/tokyo-night.png は別トラックが生成する)。
  home.file."Pictures/Wallpapers/tokyo-night.png".source = ../../assets/wallpapers/tokyo-night.png;

  # settings.toml は noctalia の GUI が常時書き戻すため copy-if-absent シード。
  # store のファイルは read-only なので install -m 0644 で u+w を付けて配置する。
  home.activation.seedNoctaliaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${settingsPath}" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "${settingsPath}")"
      $DRY_RUN_CMD install -m 0644 ${seededSettings} "${settingsPath}"
    fi
  '';
}
