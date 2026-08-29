:maatlog-post: true
:maatlog-published-at: 2025-01-04T00:00:00+09:00
:maatlog-slug: setup-python-environment-using-uv
:maatlog-tags: linux,python
:maatlog-categories: it-technology
:maatlog-authors: usaturn

.. _setup_python_environment_using_uv:

===========================================
uv を利用した Python 環境のセットアップメモ
===========================================

誰向けの記事？
==============

自分向けのメモ

前提条件
========

- Google Cloud Shell を使用します
- 対象のコンピュータがインターネット接続できていること
- Linux ディストリビューションを bash 等のシェルで操作できること

詳細手順
========

::

    # uv をインストールする（インストールスクリプトを取得してシェルで実行する）
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # シェルの補完を有効にする（bash 以外は zsh、fish などシェル名を指定する）
    echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc

    # uv 自身を最新版に更新する（インストールスクリプトで入れた場合のみ）
    uv self update

    # 指定したバージョンの Python をまとめてインストールする
    uv python install 3.10 3.11 3.12

    # 利用できる Python と、インストール済みの Python を一覧表示する
    uv python list

    # スクリプトを実行する（宣言された依存関係を隔離した仮想環境へ自動で入れてから走る）
    uv run example.py

    # ツールを一時的な環境で実行する（uv tool run のエイリアス。入れっぱなしにしない）
    uvx ruff

    # ツールを永続的にインストールする（pipx 相当。以降は ruff コマンドとして使える）
    uv tool install ruff

    # 新しいプロジェクトを作る（my-project ディレクトリが作成される）
    uv init my-project

    # アプリケーションプロジェクト（カレントディレクトリを対象にする）
    uv init --app .

    # ライブラリプロジェクト（配布するパッケージ向けの構成になる）
    uv init --lib my-lib

Google Cloud Shell まわりのメモです ::

    # Google Cloud の Python サンプル集を取得する
    git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

    # Cloud Shell エディタ（Theia）に VSCodeVim 拡張を手動で配置する
    sudo unzip vscodevim.vsix -d /google/devshell/editor/theia/plugins/vscode-vim
