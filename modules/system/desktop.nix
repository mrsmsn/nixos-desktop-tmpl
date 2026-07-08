{
  pkgs,
  lib,
  vars,
  ...
}:

{
  # niri (scrollable-tiling Wayland compositor)。
  # programs.niri.enable が niri.desktop の wayland-sessions 登録・
  # xdg-desktop-portal・polkit を自動設定する。package の default は
  # pkgs.niri-stable で、flake.nix で pkgs に組み込んだ niri.overlays.niri が供給する。
  # noctalia-greeter は wayland-sessions/*.desktop からセッション一覧を作るので、
  # これにより greeter のセッション選択に niri が載る。
  programs.niri.enable = true;

  # グラフィカルログインは greetd + noctalia-greeter (noctalia と見た目統一)。
  # GNOME/GDM は使わない。noctalia-greeter.nixosModules.default (flake で import) が
  # 下記オプションを提供する。調査結果:
  #   programs.noctalia-greeter.enable       -> greetd を有効化しこの greeter を default_session に設定
  #   programs.noctalia-greeter.package      -> 使用パッケージ (module default をそのまま使う)
  #   programs.noctalia-greeter.greeter-args -> `noctalia-greeter-session -- <args>` に渡る文字列
  #   programs.noctalia-greeter.settings     -> Nix attrset を TOML 化して
  #                                             /var/lib/noctalia-greeter/greeter.toml に配備
  # greetd の default_session.command はモジュールが
  #   "${cfg.package}/bin/noctalia-greeter-session -- ${cfg.greeter-args}"
  # に自動設定する。--session niri で niri を初期選択にする。
  # 出典: https://github.com/noctalia-dev/noctalia-greeter (README, nix/nixos-module.nix)
  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri"; # greeter 起動時に niri をデフォルト選択
    settings = {
      # greeter.toml (admin 設定)。noctalia 側テーマと揃える。
      # [session].default は cmdline の --session が勝つが、宣言的な保険として置く。
      session.default = "niri";
      keyboard.layout = "us";
    };
  };

  # 万一 noctalia-greeter が GPU 初期化失敗等で映らない場合は、上の
  # programs.noctalia-greeter ブロックを丸ごとコメントアウトし、代わりに
  # 以下の tuigreet (TTY greeter) に差し替えると確実にログインできる:
  #
  #   services.greetd = {
  #     enable = true;
  #     settings.default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
  #       user = "greeter";
  #     };
  #   };
  #
  # 復旧時は Ctrl+Alt+F2 で VT を切り替えて TTY ログインし、rebuild し直す。

  # このマシンが Intel iGPU (i915) のときだけ i915 を initrd で先にロードする。
  # そうしないと起動時に simpledrm が /dev/dri/card0 を先取りし、i915 は遅れて
  # card1 になる。すると niri がプライマリ GPU 選択で描画不可の simpledrm(card0) を
  # 掴み、表示できずログイン画面へ跳ね返される。i915 を initrd に入れて実 GPU を
  # card0 に確定させ、simpledrm の居座りを防ぐ。cpuVendor != intel の環境
  # (AMD/VM 等) では不要かつ有害になり得るので条件化する。
  boot.initrd.kernelModules = lib.mkIf (vars.cpuVendor == "intel") [ "i915" ];

  # 音声は PipeWire に統一 (PulseAudio は無効化)。
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 日本語入力は fcitx5 + mozc。niri は text-input-v3 のみ対応するため、
  # waylandFrontend を有効にして GTK_IM_MODULE/QT_IM_MODULE に依存せず
  # text-input-v3 経由で入力する。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # Chromium/Electron を Wayland ネイティブ (Ozone) で動かす。
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Noctalia のウィジェット (電池/電源プロファイル/Bluetooth) をフル機能で
  # 動かすための推奨サービス。
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;

  # ブラウザ。programs.chromium は NixOS ではポリシー設定のみで本体を
  # インストールしないため、Chromium は systemPackages で入れる。
  programs.firefox.enable = true;

  # バー/ランチャー/通知/ロック/壁紙/OSD は Noctalia デスクトップシェルが担う
  # (modules/home の programs.noctalia)。wl-clipboard は UI ではなく CLI
  # クリップボードの実体なので下で別途残す。
  environment.systemPackages = with pkgs; [
    chromium

    # ターミナル。
    ghostty

    # Wayland クリップボード CLI (wl-copy/wl-paste)。Noctalia の履歴 UI とは別物で、
    # lazygit 等が shell out するコピーコマンドの実体。
    wl-clipboard

    # xdg-open (zsh の gb 関数などが URL/ファイルを開くのに使う)。
    xdg-utils
  ];
}
