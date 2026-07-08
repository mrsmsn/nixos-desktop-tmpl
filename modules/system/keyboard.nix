{ vars, ... }:

{
  # CapsLock を Ctrl に。加えて Alt を dual-role 化して IME 切替を作る。
  # system モードで動かし、対象ユーザを明示する。
  services.xremap = {
    enable = true;
    serviceMode = "system";
    userName = vars.username;
    config.modmap = [
      {
        name = "CapsLock to Ctrl";
        remap.CapsLock = "Ctrl_L";
      }
      # 左右 Alt を dual-role 化して macOS の英数/かな相当を作る:
      # 押しっぱなしは従来通り Alt(修飾キー)、単押しのときだけ IME 切替キーを送出する。
      #   左Alt 単押し -> Hangul_Hanja (fcitx5 の Deactivate = 英数/us 直接入力)
      #   右Alt 単押し -> Hangul       (fcitx5 の Activate   = mozc/かな)
      # あえて Henkan/Muhenkan ではなく Hangul 系キーシムを使う: Mozc は既定
      # キーマップでこれらを束縛しない (Korean 用) ため Mozc に消費されず、
      # fcitx5 の Activate/Deactivate が競合なく発火する。Henkan/Muhenkan だと
      # Mozc がカナ種切替として先に食ってしまい fcitx5 の切替が効かない。
      #
      # JIS 物理キーボード向けに Henkan/Muhenkan も併記する: 変換キーを「かな」、
      # 無変換キーを「英数」に割り当て、US/JIS どちらの配列でも IME 切替が効くようにする。
      # (元 repo の内蔵キーボードは JIS キーコードを吐くマシン固有事情で
      # KATAKANAHIRAGANA/RO を再マップしていたが、テンプレートでは汎用性のため削除した。)
      {
        name = "Dual-role Alt + JIS keys for IME toggle";
        remap = {
          LEFTALT = {
            held = "Alt_L";
            alone = "HANJA";
          }; # 左Alt: 修飾=Alt_L / 単押し=英数
          RIGHTALT = {
            held = "Alt_R";
            alone = "HANGEUL";
          }; # 右Alt: 修飾=Alt_R / 単押し=かな
          HENKAN = "HANGEUL"; # JIS 変換キー -> かな
          MUHENKAN = "HANJA"; # JIS 無変換キー -> 英数
        };
      }
    ];
  };
}
