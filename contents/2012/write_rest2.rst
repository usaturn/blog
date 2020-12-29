.. include:: warning.rst

.. post:: Dec 5, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第5日目 Sphinxドキュメントを編集する その２
============================================

昨日は **reStructuredText** で記述されたサンプルをコピペし **HTMLドキュメント** を生成しましたね。
今日は、サンプルの中で使用した **reStructuredText** の記法をご紹介します。


インラインマークアップ(文字の修飾)
-----------------------------------
* 斜体にするには次のように **\* (アスタリスク)** で囲みます。

  * 文中に入れる場合は、前後に *半角スペース* を入れて下さい。

  記述例::

    *index.rst*
    *UTF-8*
    *サクラエディタ*
    *メジャーなツール*

  このように表示されます。

|  　　　   *index.rst*
|  　　　   *UTF-8*
|  　　　   *サクラエディタ*
|  　　　   *メジャーなツール*

* 太字にするには **\** (アスタリスク×２)** で囲みます。

  記述例::

    **あふｗ**
    **Paper Plane xUI**
    **内骨格**


  このように表示されます。

| 　　　  **あふｗ**
| 　　　  **Paper Plane xUI**
| 　　　  **内骨格**

* リテラルに(そのまま表示)するには **\`` (バッククォート×２)** で囲みます。


  記述例::

    ``C:\cygwin\bin\vim-nox.exe``

  このように表示されます。

    ``C:\cygwin\bin\vim-nox.exe``

  * Windowsのパス等、エスケープ文字を含む場合に使うといいでしょう。


タイトルリファレンス
----------------------
* 書籍などの説明に使われる記法です。種別を *: セミコロン* で挟み、半角スペースを入れた後に名称を記述します。

  記述例::

    :ファイラ: あふｗ
    :エディタ: Vim
    :処理系: AutoHotKey
    :処理系: Python
    :シェル: nyaos

  このように表示されます。

  :ファイラ: あふｗ
  :エディタ: Vim
  :処理系: AutoHotKey
  :処理系: Python
  :シェル: nyaos


番号無しリスト(箇条書き)
--------------------------
* 箇条書きにする為には **\* (アスタリスク)** **\- (ハイフン)** **\+ (プラス)** のいずれかを文頭に置きます。

  記述例::

   * TortoiseHg
   * TortoiseBzr

   - Cygwin
   - gow

   + xyzzy
   + Gvim

  このように表示されます。

   * TortoiseHg
   * TortoiseBzr

   - Cygwin
   - gow

   + xyzzy
   + Gvim

  入れ子にする事もできます。

  記述例::

   * TortoiseHg
   * TortoiseBzr

     * Cygwin
     * gow

       * xyzzy
       * Gvim

  このように表示されます。

   * TortoiseHg
   * TortoiseBzr

     * Cygwin
     * gow

       * xyzzy
       * Gvim

* インデントの半角スペースの数や、空行などにより表示が変化します。後日また説明します。

番号付きリスト(箇条書き)
-------------------------
* 番号付きのリストを使う事もできます。番号には **半角英数** が使えます。

  記述例::

    1. Python
    2. Mercurial
    3. Sphinx
    4. Vim

  このように表示されます。

    1. Python
    2. Mercurial
    3. Sphinx
    4. Vim

  入れ子にする事もできます。

  記述例::

    A. Editor

       i. Vim
       ii. Emacs
       iii. SakuraEditor
       iv. ed

    B. Filer

       i. Afxw
       ii. mfiler4
       iii. VimFiler

    C. Launcher

       i. CraftLaunch
       ii. HoeKey
       iii. Bluewind

  このように表示されます。

    A. Editor

       i. Vim
       ii. Emacs
       iii. SakuraEditor
       iv. ed

    B. Filer

       i. Afxw
       ii. mfiler4
       iii. VimFiler

    C. Launcher

       i. CraftLaunch
       ii. HoeKey
       iii. Bluewind

* 使用するThemeにより、表示は変わります。今回は全て数字になりましたがThemeによっては、アルファベットがそのまま表示されます。


セクション(ブロックの区切り)
-----------------------------
* 下記記号をアンダーラインのように使う事によりセクションにする事ができます。

  * **\#**
  * **\***
  * **\=**
  * **\-**
  * **\^**
  * **\~**
  * **\"**

記号を使った順にレベル分けされます。

  記述例::

    レベル2
    -------

    レベル3
    ~~~~~~~

    レベル4
    """""""

    レベル2
    -------

次のように表示されます。


レベル2
-------

レベル3
~~~~~~~

レベル4
"""""""

レベル2
-------

明日も引き続き、よく使う記述をご紹介していきます。

※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
