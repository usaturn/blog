.. _How_to_use_claude_code:

=====================================
初心者が Claude Code を使い始めたメモ
=====================================

:maatlog-post: true
:maatlog-published-at: 2025-06-28T00:00:00+09:00
:maatlog-slug: how-to-use-claude-code
:maatlog-tags: ai
:maatlog-categories: it-technology
:maatlog-authors: usaturn

誰向けの記事？
==============

自分向けのメモです

概要
====

MAX プラン契約してるのに Web/デスクトップでしか使ってなかったので、いい加減 Claude Code を使い始めようと思い自分用のメモを作成しました

セットアップする
================

2025年6月現在、Claude Code は Unix/Linux 環境でしか使えないので、筆者の場合は Windows の WSL2 上に環境構築しました。
手順は `公式のセットアップガイド <https://docs.anthropic.com/ja/docs/claude-code/setup>`__ の通りです

:command:`claude -p "質問"` を打つとワンショットで起動できます ::

    claude -p "カレントディレクトリについて教えて"

:command:`claude` と打つと対話モードが始まります ::

    claude

対話モードが始まったら、スラッシュコマンドでモデルの設定をします。
筆者の場合は手動で sonnet|opus を切り替えたいので標準で sonnet を設定しておきます。
精度の高いことをやらせたい時だけ opus に変更します ::

    /model sonnet
    /model opus

その他の設定は :command:`/config` で確認・変更できます

CLAUDE.md を用意する
====================

Git リポジトリを作成して開発する想定でセットアップします。
空のディレクトリ ``pyhack`` を作り、そこをカレントディレクトリにしてから :command:`/init` を打つと、
リポジトリを解析して CLAUDE.md を作成してくれます ::

    /init

CLAUDE.md は英語で作成されるので、日本語に直してもらいます ::

    @CLAUDE.md を日本語に直して ultrathink

CLAUDE.md は対話の際に毎回読み込まれるので、セットアップ方法やコーディングスタイルなど、
毎回指示したい内容を書いておくと良さそうです

``@ファイル名`` で他のファイルを参照させられるので、別ファイルに切り出した資料を CLAUDE.md から参照させることもできます ::

    処理のシーケンス図を考えて mermaid 記法でファイルを作成して
    CLAUDE.md に @ マークを利用して作成したシーケンス図を参照できるようにして

なお Claude Desktop の場合は、毎回入れておきたい指示は「プロジェクトの指示」に書いておくと同じことができます

対話モードの操作
================

覚えておきたい操作をメモしておきます

- 適宜 :command:`/clear` しないと過去の会話履歴を参照してしまう
- :command:`/compact` で会話履歴を要約してくれる
- ESC 2回で会話履歴を遡ってやり直せる
- Ctrl+v で画像を貼り付けられる（Web サイトの UI のスクリーンショットなど）
- URL を貼ると参照してくれる
- Shift+Tab でプランモードに入る。いきなりコードを書かせず、どう実装するのか計画を立てさせられる

プロンプトで考える量の上限を指定できます。下にいくほど長く考えます ::

    think
    think hard
    think harder
    ultrathink

権限確認のたびに止まるのが煩わしい場合は :command:`--dangerously-skip-permissions` を付けて起動できますが、
名前の通り危険なので、捨てても良い環境以外では使わない方が良さそうです

VSCode と連携する
=================

VSCode を起動して拡張 **Claude Code for VSCode** をインストールします

- VSCode のチャット欄で Claude マークを押すと、どのファイルを開いているのかが表示される
- ターミナルから :command:`/ide` を打つと VSCode と連携する

MCP Server と連携する
====================

登録済みの MCP Server は :command:`claude mcp list` で確認できます ::

    claude mcp list

Claude Desktop に登録済みの MCP Server を取り込めます ::

    claude mcp add-from-claude-desktop

対話モード中は :command:`/mcp` で接続状況を確認できます。
追加方法は MCP Server ごとに異なるので、それぞれのドキュメントを確認します

筆者が試してみようと思っている MCP Server は以下です

- Context7
- DeepWiki
- Sequential Thinking

カスタムスラッシュコマンドを作る
================================

``.claude/commands`` 配下に Markdown ファイルを置くと、ファイル名がそのままスラッシュコマンドになります。
例えば ``commit.md`` を作ると :command:`/commit` が使えるようになります ::

    .claude/commands/commit.md

どういうコマンドを作ると便利かは `awesome-claude-code <https://github.com/hesreallyhim/awesome-claude-code>`__ が参考になります。
筆者は :command:`/commit` がお勧めです

以上、Claude Code を使い始めるにあたって覚えたことをメモしました

参考ソース
==========

主に以下を参考にしました。
特に、 `にゃんたさんの Youtube チャンネル <https://www.youtube.com/@aivtuber2866>`__ はめちゃくちゃわかりやすく説明されているのでお勧めです

- `公式ドキュメント <https://docs.anthropic.com/ja/docs/claude-code/overview>`__
- `CLIの使用法とコントロール <https://docs.anthropic.com/ja/docs/claude-code/cli-usage>`__
- `Claude Code: Best practices for agentic coding <https://www.anthropic.com/engineering/claude-code-best-practices>`__
- `How we built our multi-agent research system <https://www.anthropic.com/engineering/built-multi-agent-research-system>`__
- `slash-commands, CLAUDE.md files, CLI tools, and other resources <https://github.com/hesreallyhim/awesome-claude-code>`__
- `Anthropic のエンジニアが使っている python-sdk の CLAUDE.md <https://github.com/modelcontextprotocol/python-sdk/blob/main/CLAUDE.md>`__
- `gemini-cli の google_web_search <https://zenn.dev/mizchi/articles/gemini-cli-for-google-search>`__
- `Claude Codeって何が良いの？触ってみて便利だと感じた機能について紹介してみた <https://youtu.be/pDMT68OJGL0?si=uRQT9ukR19hcVC-Z>`__
- `最新AIエージェント！AnthropicのClaude Codeが凄かったので解説してみた <https://youtu.be/tHoJAwrs1q8?si=TIoyt0CjSwiIcaSt>`__
- `MCP Server って便利なのか？色々触ってみて感じたことを解説してみた <https://youtu.be/LIz-3-T5mpc?si=ZcHZNSROosNEroV2>`__

