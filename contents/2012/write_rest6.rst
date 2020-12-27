.. include:: warning.rst

.. post:: Dec 9, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第9日目 Sphinxドキュメントを編集する その６
============================================

.. highlight:: rest

昨日までに、基本的な **reStructuredText** を説明しましたので *index.rst* 1つなら十分編集する事が出来るようになったと思います。

今日から、複数のファイルを作成しSphinxでドキュメントを構造化する方法を説明します。

まずはドキュメントを構造化する際に骨となる `toctree <http://sphinx-users.jp/doc10/markup/toctree.html>`_ ディレクティブの説明です。
とても重要なディレクティブですので必ず読んで下さい。

ドキュメントを構造化する
-------------------------
ドキュメントを作成する際は、大抵、大項目をいくつか挙げ、その下に紐付く中項目、小項目をぶら下げる *ツリー構造* で考える事が多いのではないでしょうか？
*ツリー構造* であれば見通しがよくなりドキュメントの作成を進めやすいですよね。

Sphinxの場合は *ツリー構造* にする方法が2つあります。

1. ``toctree`` ディレクティブ
------------------------------
* *index.rst* と同じディレクトリ階層に2つのreSTファイルを置くと仮定します。

  1. first.rst::

       1つ目のファイル
       ================
       * これは1つ目のファイルです。

  2. second.rst::

       2つ目のファイル
       ================
       * これは2つ目のファイルです。


  これらのファイルを *index.rst* に読み込ませるには下記のように記述します。

  ::

    .. toctree::

       first
       second

  html化すると `このようになるはずです。 <http://usaturn.net/sample/02/>`_


2. ディレクトリ管理
--------------------
* 単純にreSTファイルをディレクトリに小分けして格納するだけです。

  ::

     .. toctree::

        unyo/tejun01
        unyo/tejun02
        unyo/tejun03
        kochiku/network
        kochiku/kanshi
        kochiku/server

  例では *index.rst* と同じ階層に *unyo* , *kochiku* というディレクトリを作成し、それぞれのディレクトリ配下にreSTファイルを作成してあります。

  * unyoディレクトリ

    * tejun01.rst
    * tejun02.rst
    * tejun03.rst

  * kochikuディレクトリ

    * network.rst
    * kanshi.rst
    * server.rst

  ※例は省きます


明日はネットワーク構造(リンクの張り方)の説明をします。

※ このアドベントカレンダーについては :ref:`about` を参照して下さい。
