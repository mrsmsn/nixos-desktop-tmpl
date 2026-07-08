{
  description = "nixos-desktop-tmpl: 日本人向け NixOS デスクトップテンプレート (niri + noctalia + fcitx5-mozc)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri (scrollable-tiling Wayland compositor)。あえて inputs.nixpkgs.follows
    # は付けない: follows すると niri.cachix.org のバイナリキャッシュとハッシュが
    # ずれ、niri 本体 (Rust) を毎回ローカルフルビルドすることになるため。
    niri.url = "github:sodiboo/niri-flake";

    # Noctalia (Quickshell ベースのデスクトップシェル: バー/ランチャー/通知/
    # ロック/壁紙/OSD)。v5 は nixpkgs 未収録 (nixpkgs は v4 系) なので flake から
    # 入れる。重い依存の quickshell は nixpkgs 側にあるので follows で nixos.org
    # キャッシュを使わせる (noctalia 本体は QML で軽量)。
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-greeter (greetd 用のグラフィカルログイン。noctalia と見た目統一)。
    # nixosModules.default を desktop.nix で import する。
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      xremap,
      niri,
      noctalia,
      noctalia-greeter,
      ...
    }:
    let
      # このテンプレートは x86_64-linux デスクトップ専用。
      system = "x86_64-linux";

      vars = import ./vars.nix;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # niri.overlays.niri は pkgs.niri-stable / niri-unstable を生やす。
        # nixosSystem に nixpkgs.pkgs を注入する構成なので、niri モジュール
        # (nixpkgs.overlays を自前設定しない設計) に pkgs.niri-stable を届けるには
        # overlay をこの注入 pkgs 側に組み込む必要がある。overlay 方式は niri の
        # 依存 (特に mesa) を system の nixpkgs に整合させ、GPU 描画を保証する。
        overlays = [ niri.overlays.niri ];
      };

      # cpuVendor に応じて nixos-hardware の CPU マイクロコード/最適化モジュールを選ぶ。
      # "other" のときは CPU 固有モジュールを入れない (未知/VM 環境で安全側)。
      cpuModules =
        if vars.cpuVendor == "intel" then
          [ nixos-hardware.nixosModules.common-cpu-intel ]
        else if vars.cpuVendor == "amd" then
          [ nixos-hardware.nixosModules.common-cpu-amd ]
        else
          [ ];

      host = nixpkgs.lib.nixosSystem {
        inherit system;
        # system モジュール群は vars (username/hostname/stateVersion/cpuVendor) を参照する。
        specialArgs = { inherit vars; };
        modules = [
          ./modules/system
          # 実機では install.sh がこのファイルを nixos-generate-config の出力で置換する。
          # 初期状態は CI/eval を通すための placeholder stub。
          ./hosts/default/hardware-configuration.nix
          { nixpkgs.pkgs = pkgs; }
          nixos-hardware.nixosModules.common-pc-ssd
          xremap.nixosModules.default
          niri.nixosModules.niri
          noctalia-greeter.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home モジュールが noctalia flake input と vars を参照できるよう渡す。
            home-manager.extraSpecialArgs = { inherit vars noctalia; };
            home-manager.users.${vars.username}.imports = [ ./modules/home ];
          }
        ]
        ++ cpuModules;
      };
    in
    {
      # default は CI 用の安定名。${vars.hostname} は install.sh が検出した実機名で
      # `nixos-rebuild switch --flake .#<hostname>` を通すためのエイリアス。
      nixosConfigurations = {
        default = host;
        ${vars.hostname} = host;
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      # raw KDL は Nix の型検査に載らないので、niri 自身の validate をチェックにする。
      checks.${system}.niri-config =
        pkgs.runCommand "niri-config-check" { nativeBuildInputs = [ pkgs.niri-stable ]; }
          ''
            niri validate -c ${./dotfiles/niri/config.kdl}
            touch $out
          '';
    };
}
