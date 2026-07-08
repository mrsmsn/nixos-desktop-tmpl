{ config, lib, ... }:

let
  fcitx5Dir = "${config.xdg.configHome}/fcitx5";

  # copy-if-absent シード。fcitx5-configtool は設定を直書きするため、既存ファイルが
  # あれば尊重し、無い場合のみ store のシードを配置する。store のファイルは read-only
  # なので `install -m 0644` で配置し、configtool が保存できるよう u+w を付ける。
  seed = dest: src: ''
    if [ ! -e "${dest}" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "${dest}")"
      $DRY_RUN_CMD install -m 0644 ${src} "${dest}"
    fi
  '';
in
{
  home.activation.seedFcitx5 = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    seed "${fcitx5Dir}/config" ../../dotfiles/fcitx5/config
    + seed "${fcitx5Dir}/conf/mozc.conf" ../../dotfiles/fcitx5/conf/mozc.conf
    + seed "${fcitx5Dir}/profile" ../../dotfiles/fcitx5/profile
  );
}
