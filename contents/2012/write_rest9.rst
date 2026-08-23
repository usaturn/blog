第12日目 Sphinxドキュメントを編集する その９
=============================================

:maatlog-post: true
:maatlog-published-at: 2012-12-12T00:00:00+09:00
:maatlog-slug: write-rest9
:maatlog-tags: sphinx
:maatlog-categories: it-technology
:maatlog-authors: usaturn

.. include:: warning.rst

.. highlight:: rest

昨日は他のドキュメント( **rstファイル** )やセクションへのリンクについて説明しました。
今日はファイルのダウンロードリンクや画像へのリンクについて説明します。

ファイルをダウンロードさせるリンク
-----------------------------------
* **プロジェクト** 内に存在するファイルへのダウンロード用リンクを張る事ができます。

  記述例::

    :download:`ダウンロードできます <./files/build_and_browsing.zip>`

  このように表示されます。

  :download:`ダウンロードできます <./files/build_and_browsing.zip>`


画像を表示する ～imageディレクティブ～
---------------------------------------
* 画像を表示させたい場合は ``.. image::`` というディレクティブを使います。

  まずはPythonの `pillowパッケージ <http://pypi.python.org/pypi/Pillow/>`_ をインストールしましょう。

  ::

    easy_install -U pillow

  `pillowパッケージ <http://pypi.python.org/pypi/Pillow/>`_ がインストール出来たら imageディレクティブのオプションが使えるようになります。

  記述例::

        .. image:: ./images/background.png
           :scale: 50
           :align: left
           :target: http://sphinx-users.jp/

  htmlこのように表示されます。

  .. image:: /contents/2012/images/background.png
     :scale: 50
     :align: left
     :target: http://sphinx-users.jp/

  * **scale** は縮小、拡大をする時のオプションです。100が1/1スケールです。
  * **target** リンク先を指定する事ができます。

明日は索引(インデックス)について説明します。

※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
