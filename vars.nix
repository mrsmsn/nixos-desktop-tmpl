# install.sh が実機の値に書き換える唯一のファイル。
# placeholder のままでも pure eval / CI が通るよう、すべて有効な値にしてある。
{
  username = "nixos-user"; # 実機では install.sh が $USER を検出して差し替える
  hostname = "nixos"; # 実機では install.sh が hostname を検出して差し替える
  stateVersion = "25.11"; # install 時に nixos-version から検出して固定。以後変更しない
  cpuVendor = "other"; # "intel" | "amd" | "other" -> nixos-hardware の CPU モジュール切替
}
