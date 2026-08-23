第10日目 Sphinxドキュメントを編集する その７
=============================================

:maatlog-post: true
:maatlog-published-at: 2012-12-10T00:00:00+09:00
:maatlog-slug: write-rest7
:maatlog-tags: sphinx
:maatlog-categories: it-technology
:maatlog-authors: usaturn

.. include:: warning.rst

.. highlight:: rest

昨日は `toctree <http://sphinx-users.jp/doc10/markup/toctree.html>`_ ディレクティブを使用してSphinxドキュメントを *ツリー構造化* する方法を説明しました。

今日からドキュメントのネットワーク構造(リンクの張り方)の説明をします。

外部URLへのリンク
------------------
* 一番単純なURLへのリンクの張り方は、単にURLを記述する事です。

  記述例::

    http://sphinx-users.jp/

  このように表示されます。

    http://sphinx-users.jp/

* URLを見せずに文字列を見せたい場合は下記のように記述します。

  記述例::

    `sphinx <http://sphinx-users.jp/>`_

  このように表示されます。

    `sphinx <http://sphinx-users.jp/>`_

  もし、同じリンクを使いまわしたい時は、

  まず *ターゲット定義* を書く::

    .. _`sphinx`: http://sphinx-users.jp/

  記述例::

    この `sphinx`_ を会得すると、身も心も `sphinx`_ 化してしまい、 どんなドキュメントも `sphinx`_ にしないと気が済まなくなるらしい。

  このように表示されます。

    この `sphinx`_ を会得すると、身も心も `sphinx`_ 化してしまい、 どんなドキュメントも `sphinx`_ にしないと気が済まなくなるらしい。


明日はSphinxドキュメント内へのリンクを説明します。


※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
