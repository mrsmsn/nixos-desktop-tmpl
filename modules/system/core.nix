{ pkgs, vars, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # niri を毎回ソースからフルビルドしないよう niri.cachix.org を追加する
    # (flake で niri に follows を付けない設計と対で、初回 switch を速くする)。
    # cache.nixos.org を消さないよう明示的に併記する。
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  # UI は英語、日付・通貨などの各種フォーマットは日本ロケールに寄せる。
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # ログインシェルは NixOS のシステム設定 (users.users.<name>.shell) が決める。
  # generic linux の home-manager でやっている /etc/shells + chsh 方式は NixOS
  # では不可能なので、ここで zsh を有効化しつつ下でユーザの shell に割り当てる。
  programs.zsh.enable = true;

  users.users.${vars.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  system.stateVersion = vars.stateVersion; # インストール時の値。変更しない。
}
