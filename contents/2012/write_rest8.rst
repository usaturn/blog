.. include:: warning.rst

.. post:: Dec 11, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第11日目 Sphinxドキュメントを編集する その８
=============================================

.. highlight:: rest

昨日は外部リンクの張り方を説明しました。今日は **プロジェクト** 内へのリンクを説明します。


ドキュメントへのリンク
-----------------------
* 他のドキュメント( **rstファイル** )へリンクを張りたい時は ``:doc:`` というマークアップをします。

  記述例::

     昨日のタイトルは :doc:`write_rest7` です。一昨日は :doc:`toctree <write_rest6>` について説明しましたね。

  このように表示されます。

    昨日のタイトルは :doc:`write_rest7` です。一昨日は :doc:`toctree <write_rest6>` について説明しましたね。

* ファイルへのパスは拡張子が不要です。
* ファイルパスはドキュメントの起点となる *index.rst* を */ (ルート)* とした絶対パスか、相対パスで記述して下さい。

.. _link_section:

セクションへのリンク
---------------------

アンカーを設置する
~~~~~~~~~~~~~~~~~~~
* **セクション** へリンクを張る為にはリンクを張りたい **セクション** にアンカーを配置する必要があります。

  .. note:: **セクション** は同じ **プロジェクト** 内であれば違う **rstファイル** であっても構いません。

  記述例::

         .. _schedule:

         タイトル(予定かつ順不同)
         -------------------------

  アンカー自体は表示されません。

アンカーを配置したセクションへリンクする
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ``:ref:`` でセクションへリンクします。

  記述例::


        このアドベントカレンダーについての :ref:`schedule` へジャンプしましょう。

        :ref:`こういう書き方 <schedule>` もできますよ。

  このように表示されます。

        このアドベントカレンダーについての :ref:`schedule` へジャンプしましょう。

        :ref:`こういう書き方 <schedule>` もできますよ。

  .. note:: アンカーは前に **:: (セミコロン×2)** と文字列の頭に **_ (アンダーバー)** が付いていますが ``:ref:`` で指定する際はどちらも外します。


明日は画像ファイルやダウンロードをさせるリンクを説明します。

※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
