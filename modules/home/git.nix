{ ... }:

{
  # delta を git の pager / diff filter に統合する。
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;

    settings = {
      ghq.root = "~/src";

      # osxkeychain 等が先に答えないよう空 helper で chain を一度リセット。`gh auth
      # setup-git` は /nix/store/... の絶対パスを書いて Nix 環境で壊れるので、PATH
      # 解決の `gh` だけを書く (gh のバージョン更新でも壊れない)。
      credential."https://github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
    };

    # user.name / user.email はテンプレでは設定しない (README で案内)。
  };
}
