{ ... }:

{
  # zsh は raw file 配布 (元 repo の dot_zshrc 方式を踏襲)。programs.zsh は使わない。
  home.file.".zshrc".source = ../../dotfiles/zsh/zshrc;

  xdg.configFile = {
    # zsh 分割設定 (env/aliases/functions/keybindings/tmux/init)。
    "zsh/env.zsh".source = ../../dotfiles/zsh/env.zsh;
    "zsh/aliases.zsh".source = ../../dotfiles/zsh/aliases.zsh;
    "zsh/functions.zsh".source = ../../dotfiles/zsh/functions.zsh;
    "zsh/keybindings.zsh".source = ../../dotfiles/zsh/keybindings.zsh;
    "zsh/tmux.zsh".source = ../../dotfiles/zsh/tmux.zsh;
    "zsh/init.zsh".source = ../../dotfiles/zsh/init.zsh;

    # starship プロンプト。
    "starship.toml".source = ../../dotfiles/starship.toml;

    # tmux 設定と参照スクリプト (pane-border.sh は実行ビットが要る)。
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "tmux/pane-border.sh" = {
      source = ../../dotfiles/tmux/pane-border.sh;
      executable = true;
    };
    "tmux/new-session".source = ../../dotfiles/tmux/new-session;

    # lazygit。
    "lazygit/config.yml".source = ../../dotfiles/lazygit/config.yml;
  };
}
