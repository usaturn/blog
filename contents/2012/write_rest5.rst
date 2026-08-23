第8日目 Sphinxドキュメントを編集する その５
============================================

:maatlog-post: true
:maatlog-published-at: 2012-12-08T00:00:00+09:00
:maatlog-slug: write-rest5
:maatlog-tags: sphinx
:maatlog-categories: it-technology
:maatlog-authors: usaturn

.. include:: warning.rst

昨日に引き続き **リテラルブロック (コードブロック)** 関連の説明です。


ソースコード等をファイルから読み込む
--------------------------------------
* 別のファイルを読み込みリテラルブロックの表示をしたい時は ``literalinclude`` ディレクティブを使います。

  記述例::

    .. literalinclude:: ./files/yes_or_no.sh
       :language: bash
       :linenos:

  このように表示されます。

  .. literalinclude:: ./files/yes_or_no.sh
     :language: bash
     :linenos:

* ``language`` オプションを付ける事によりシンタックスハイライトが表示されます。
* ``linenos`` オプションを付ける事により行番号が表示されます。

シンタックスハイライトで使える言語
-----------------------------------
* Sphinxのシンタックスハイライトは **pygments** というライブラリを使っており、次のコマンドで対応一覧が出力できます。

  ::

    > pygmentize -L lexers

出力結果

  * ``* (アスタリスク)`` の行にある文字列が ``highlight`` や ``code-block`` 、 ``literalinclude`` の ``language`` オプションの引数として使えます。

  .. literalinclude:: ./files/lexers.txt



明日はSphinxドキュメントを構造化する重要な `toctree <http://sphinx-users.jp/doc10/markup/toctree.html>`_ ディレクティブについて説明します。

※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
