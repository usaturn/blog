.. include:: warning.rst

.. post:: Dec 3, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第3日目 Sphinxドキュメントを書く道具
=====================================

昨日はプロジェクトを作成した直後にhtmlを生成できる事を確認しました。
今日は、やっとSphinxドキュメントの作成に入ります・・・と思わせておいて、重要なテキストエディタについての説明をさせて下さい。

テキストエディタを使おう
-------------------------
  ドキュメント作成を始める前に、ちょっと待って下さい！あなたは普段、どんなテキストエディタを使ってますか？
  もしもWindows標準の *メモ帳* を使っているのなら、

  **文字コードをUTF-8に変更できるテキストエディタ**

  を探して来て下さい。もしもよくわからなければ、今日は :ref:`サクラエディタ <sakuraeditor>` の使い方を覚えましょう。

  * 秀丸、Emacs、Vim、Eclipse等々、既にお気に入りのエディタやIDEがあるのなら、今日は読み飛ばして下さい。

.. _sakuraeditor:

サクラエディタについて
-----------------------
  `サクラエディタ <http://sakura-editor.sourceforge.net/index.html>`_ はWindows用のフリーのテキストエディタとして長年親しまれ、今もなお開発が活発です。
  標準で色々な機能が付いていますので、Windows標準の *メモ帳* を使っているならば乗り換える事をお勧めします。

サクラエディタのインストール
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* 下記ページよりV2(UNICODE版)の最新版をダウンロードしインストーラに従ってインストールして下さい。

   http://sakura-editor.sourceforge.net/download.html

.. _change_cc:

文字コードの変更方法
^^^^^^^^^^^^^^^^^^^^^
* Sphinxドキュメントを作成するには **文字コード** を **UTF-8** に変更する必要があります。毎回、下記の作業を行う必要がありますので必ず覚えて下さい！

#. サクラエディタで文字コードを変更したいテキストを開き、右下に表示されている文字コードを確認して下さい。 *SJIS* と表示されているはずです。

   .. image:: /contents/2012/images/writing_tool01.png

#. メニューの *ファイル* -> *名前を付けて保存* をクリックします。

   .. image:: /contents/2012/images/writing_tool02.png

#. 文字コードセットを *UTF-8* に変更します。

   .. image:: /contents/2012/images/writing_tool03.png


   * 改行コードの変更は不要です。UNIX/Linuxの *LF* でも Windowsの *CRLF* でも問題ありません。

#. *保存* をクリックします。

   .. image:: /contents/2012/images/writing_tool04.png

#. 上書きしますか？と聞かれますので *はい* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool05.png

#. 右下に表示される文字コードが *UTF-8* に変わった事を確認して下さい。

   .. image:: /contents/2012/images/writing_tool06.png



シンタックスハイライト
^^^^^^^^^^^^^^^^^^^^^^^
* シンタックスハイライトとは特定の単語や構造に色を付けて分かり易くする機能です。
  Sphinxで使用する *reStructuredText* という記法をサクラエディタでシンタックスハイライトする為の設定を公開されている方がいらっしゃいます。

  **SakuraEditorTypeRest**

    https://github.com/tohosaku/SakuraEditorTypeRest

  ここで有り難く使わせて頂きましょう。


#. 下記リンク先のZIPファイルをダウンロードします。

   https://github.com/tohosaku/SakuraEditorTypeRest/archive/master.zip

#. 任意の場所にZIPファイルの中身を展開し *reST.ini* が存在する事を確認して下さい。
#. サクラエディタを起動し、メニューの *タイプ別設定一覧* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool07.png

#. *設定(数字)* をクリックしてから ** をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool08.png

   * 今回は *設定18* で進めます。

#. 2で展開した *reST.ini* をクリックし *開く* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool09.png

#. *バージョンが異なります* と出ますが無視して *はい* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool10.png

#. インポート条件を聞かれますので *OK* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool11.png

#. *OK* をクリックして下さい。

   .. image:: /contents/2012/images/writing_tool12.png

#. Sphinxドキュメントを開くと、色が付くようになります。

   .. image:: /contents/2012/images/writing_tool13.png



便利なショートカット
^^^^^^^^^^^^^^^^^^^^

.. list-table:: サクラエディタのキーバインド
   :header-rows: 1

   * - 効果
     - キー
   * - もとに戻す
     - Ctrl + z
   * - やり直し
     - Ctrl + y
   * - 一行切り取り
     - Shift + Delete
   * - 一行コピー 
     - Ctrl + c
   * - 現在行を複製 
     - F10
   * - 先頭(左側)の空白を削除 
     - Alt + l
   * - 末尾(右側)の空白を削除 
     - Alt + r
   * - 矩形選択開始 
     - Shift + F6
   * - 矩形貼り付け 
     - Shift + F9
   * - 
     - 

* 便利なショートカットや機能はまだまだ沢山ありますので、時間のある時にメニューバーを1つずつ開いてじっくり調べてみて下さい。


さあ、明日はSphinxドキュメントを書く為に必要な *reStructuredText* の説明です。

※ このアドベントカレンダーについては :ref:`about` を参照して下さい。
