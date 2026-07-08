{ vars, pkgs, ... }:

{
  # 定番 CLI ツール一式。shell 統合 (starship/direnv/zoxide/fzf) は
  # 元 repo 同様プログラム側の programs.* を使わず、dotfiles/zsh/init.zsh の
  # `eval "$(... init zsh)"` で読み込む方式を踏襲する (再生成しやすさ優先)。
  # git と delta は modules/home/git.nix の programs.git / programs.delta が入れる。
  home.packages = with pkgs; [
    bat
    direnv
    fd
    fzf
    gh
    ghq
    jq
    just
    lazygit
    lsd
    neovim
    ripgrep
    starship
    tmux
    yazi
    zoxide
  ];

  home.stateVersion = vars.stateVersion;
}
