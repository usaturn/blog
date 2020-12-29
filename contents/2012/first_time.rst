.. include:: warning.rst

.. post:: Dec 1, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第1日目 Sphinx環境を構築しよう！
=================================

初日は私が普段Windows上でどのようにSphinx環境を構築しているかをご紹介します。


Pythonのインストール
---------------------
* SphinxはPythonの拡張モジュールなので、まずPythonのインストールが必要です。
  下記ページよりインストーラーをダウンロードします。

* Windows用インストーラ python-2.7.3.msi
    http://www.python.jp/Zope/download/pythoncore

.. note:: Windowsの64bit(x64)版の場合も、上記のバージョンをダウンロードして下さい。

パッケージ管理ツール **easy_install** のインストール
-----------------------------------------------------
A. Pythonの拡張モジュール **easy_installコマンド** をインストールします。

   1. 下記をダウンロードします。
        http://python-distribute.org/distribute_setup.py

   2. **distribute_setup.py** をPythonをインストールしたディレクトリに配置します。

       標準では下記ディレクトリに配置して下さい。

       ::

          C:\Python27\

   3. コマンドプロンプトを起動し、 **distribute_setup.py** を配置したディレクトリへ移動します。

        ::

          > cd \Python27

   4. Pythonで **distribute_setup.py** を実行します。

        ::

          > python.exe distribute_setup.py


   5. 大量のメッセージが流れるが、最後に下記のようなメッセージが出ていれば成功。

        ::

             Creating C:\Python27\Lib\site-packages\setuptools-0.6c11-py2.7.egg-info
             Creating C:\Python27\Lib\site-packages\setuptools.pth

環境変数PATHの設定
--------------------
1. コントロールパネルより **システムとセキュリティ** を選択します。
2. **システム** を選択します。
3. **システムの詳細設定** を選択します。
4. システムのプロパティが開くので、 **詳細設定** タブを選択します。
5. 右下の **環境変数** を選択します。
6. 環境変数PATHにディレクトリを追加します。

   A. 今Windowsにログインしているアカウントに **Admin権限が有る** 場合

      * ユーザー環境変数(上側)の **新規** を選択します。
      * **新しいユーザー変数** に下記のように入力します。

        :変数名: Path
        :変数値: ``C:\Python27;C:\Python27\Scripts``

   B. 今Windowsにログインしているアカウントに **Admin権限が無い** 場合

      * システム環境変数(下側)の変数 **Path** を選択します。
      * **編集** を選択し下記のようにディレクトリ名を追加します。

        :変数値: ``C:\Python27;C:\Python27\Scripts``

7. 入力し終わったら全てのウィンドウを **OK** を押下して閉じて下さい。
8. Windowsをリブートします。
9. コマンドプロンプトよりバージョンを確認します。

    ::

      > python -V
          Python 2.7.3 ※このように出力されればOK

.. note:: バージョン確認に失敗した場合は、コマンドプロンプトに **path** と打ち込みPython27のパスが入っているか確認して下さい。


パッケージ管理ツール **pip** のインストール
---------------------------------------------
* Pythonの拡張モジュール **pip** をインストールします。

  * コマンドプロンプトを開き下記コマンドを実行します
 
     ::
 
          easy_install -U pip


Sphinxのインストール
----------------------
1. コマンドプロンプトを起動しインストールコマンドを実行します。

   ::

      pip install sphinxjp.themes.bizstyle -U

2. 大量のメッセージが出力されるが下記メッセージが最後にでれば問題ありません。

   ::

      Finished processing dependencies for sphinx


この手順では私がよく利用させて頂いている `@shkumagaiさん作 <https://twitter.com/shkumagai>`_ の `sphinxjp.themes.bizstyle <http://pypi.python.org/pypi/sphinxjp.themes.bizstyle/>`_ をSphinxとその関連パッケージを同時に入れています。


さあ、これでSphinx環境が出来上がりました。明日はSphinxでドキュメントの作成を開始しましょう。

.. note:: 手軽にSphinxを始めたい場合は `@shimizukawaさん <https://twitter.com/shimizukawa>`_  が作成された `Windowsへのインストール(スタンドアロンインストール) <http://sphinx-users.jp/gettingstarted/install_windows_standalone.html>`_ が良いかもしれません。

.. note::  他に、 `@GoingMyWayNetさん <https://twitter.com/GoingMyWayNet>`_ の書かれた `Sphinx on windows (Admin権限なし版) <http://note.sicafe.net/sphinx_memo/installAtWinNoAdmin.html>`_ も非常に参考になります。


※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
