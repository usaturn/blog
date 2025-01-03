.. post:: 2024-11-30
   :tags: Linux, CLI, Development
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _setup_mise:

=======================
mise をセットアップする
=======================


誰向けの記事？
==============

自分向けのメモです

概要
====

開発用ランタイムを総合管理する mise_ の覚書です。
筆者は `asdf <https://asdf-vm.com/>`__ から乗り換えようと考えました

mise_ は主に以下の機能があるようです。

- 多種多様な開発用ランタイム（CLIツール、言語処理系など）を管理する。asdf、nvm、pyenv、rbenv などの代替となる
- 異なるプロジェクトディレクトリで環境変数のセットを切り替える（direnvの代替）
- タスクランナーとして、make や npm スクリプトの代替となる

`公式リファレンス <https://mise.jdx.dev/getting-started.html>`__ の通りに進めます。

筆者は `Gentoo Linux <https://www.gentoo.org/>`__ 上にセットアップしますが、Linux ディストリビューションの場合はインストールスクリプトを使うか、Rust のパッケージ管理ツール cargo を使うかのどちらかだと思います

手順
====

ターミナルを起動し、インストールコマンドを打ちます ::

    curl https://mise.run | sh

出力例 ::

    mise: installed successfully to /home/usaturn/.local/bin/mise
    mise: run the following to activate mise in your shell:
    echo "eval \"\$(/home/usaturn/.local/bin/mise activate zsh)\"" >> "/home/usaturn/.zshrc"

    mise: this must be run in order to use mise in the terminal
    mise: run `mise doctor` to verify this is setup correctly

``${HOME}/.local/bin/mise`` にインストールされるようです ::

    # 筆者の例
    /home/usaturn/.local/bin/mise

使用しているシェルの設定にインストール先を追記しましょう ::

    export PATH=${PATH}:${HOME}/.local/bin/

使用しているシェルの設定ファイルに追記するように指示されているのでコマンドを打ちます ::

    # 筆者の例
    #echo "eval \"\$(/home/usaturn/.local/bin/mise activate zsh)\"" >> "/home/usaturn/.zshrc"

シェルを再起動するとアクティベイトされるようです

バージョンを確認しましょう ::

    mise --version
    # 出力例
    # 2024.12.2 linux-x64 (d1b9749 2024-12-07)
    # mise 2024.12.2 linux-x64 (d1b9749 2024-12-07)

管理できるツールを確認しましょう ::

    mise plugins ls-remote | less

fzf コマンドをグローバルにインストールしてみましょう ::

    mise use --global fzf
    # 出力例
    # mise ~/.config/mise/config.toml tools: fzf@0.56.3

    # インストールした fzf の情報を表示する
    mise ls fzf

fzf をアンインストールしてみましょう ::

    mise uninstall fzf

以上、mise で便利ツールをグローバルで管理する方法をメモしました。

.. _mise: https://mise.jdx.dev/
