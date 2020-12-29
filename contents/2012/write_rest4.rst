.. include:: warning.rst

.. post:: Dec 7, 2012
   :tags: sphinx
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

第7日目 Sphinxドキュメントを編集する その４
============================================

今日ご紹介するのは **リテラルブロック (コードブロック)** の書き方です。

Sphinxで **リテラルブロック** とはプログラムのソースコードやコマンドライン、他にエスケープ文字やSphinxで解釈されてしまうreST表記やディレクティブ等をそのまま表示させたい時に使う方法です。

.. highlight:: none

リテラルブロック
-----------------
* ``:: (コロン×2)`` の次に空行を空けてインデントをして記述します。

  記述例:

  .. code-block:: rest

     ::

      def fizzbuzz(a):
          if not(a%15):
              print "fizzbuzz"
          elif not(a%5):
              print "buzz"
          elif not(a%3):
              print "fizz"
          else:
              print a

      map(fizzbuzz,range(1,100))

  このように表示されます。::

      def fizzbuzz(a):
          if not(a%15):
              print "fizzbuzz"
          elif not(a%5):
              print "buzz"
          elif not(a%3):
              print "fizz"
          else:
              print a

      map(fizzbuzz,range(1,100))


* ``:: (コロン×2)`` の前に文字列を入れた場合は、文字列の後に ``: (コロン)`` が1つ表示されます。上記の例で使用している ``記述例::`` を見て下さい。

シンタックスハイライト
^^^^^^^^^^^^^^^^^^^^^^^
* ``:: (コロン×2)`` より前に ``highlight`` ディレクティブを入れる事によりシンタックスハイライトする事ができます。

  記述例:

  .. code-block:: rest

     .. highlight:: python
        :linenothreshold: 5

     記述例::

       def fizzbuzz(a):
       　　if not(a%15):
       　　　　print "fizzbuzz"
       　　elif not(a%5):
       　　　　print "buzz"
       　　elif not(a%3):
       　　　　print "fizz"
       　　else:
       　　　　print a

       map(fizzbuzz,range(1,100))

  このように表示されます。

  .. code-block:: python
     :linenos:

     import os
     def fizzbuzz(a):
         not(a%15):
             print "fizzbuzz"
         elif not(a%5):
             print "buzz"
         elif not(a%3):
             print "fizz"
         else:
             print a

     map(fizzbuzz,range(1,100))

* 1つのreSTファイルの頭に ``.. highlight:: python`` を入れておくと以降のリテラルブロックはPythonのシンタックスハイライトが適用されます。
* ``linenothreshold`` というオプションを付けると行番号が表示されます。 ``:linenothreshold: 5`` の場合は5行以上ある場合に行番号が表示されます。
* ``highlight`` や ``code-block`` で使える言語の引数は :doc:`こちら <write_rest5>`


code-blockディレクティブ
--------------------------
* ``:: (コロン×2)`` と ``highlight`` ディレクティブの組み合わせで、リテラルブロック＋シンタックスハイライトを表示させてきましたが ``code-block`` ディレクティブのみで表示させる事も可能です。1つのreSTファイルの中に異なるシンタックスハイライトで表示させたい場合に使います。


  記述例::

      .. code-block:: awk
         :linenos:

         #!/usr/bin/gawk
         BEGIN{i=0
             while (i<100) {
                            i++
                            fizzbuzz(i)
                            }
         }
         function fizzbuzz(a){
             if (!index(a / 15,".")) print "FizzBuzz"
                 else
                     if (!index(a / 3,".")) print "Fizz"
                         else
                             if (!index(a / 5,".")) print "Buzz"
                                 else
                                     print a
         }


  このように表示されます。

  .. code-block:: awk
     :linenos:

     #!/usr/bin/gawk
     BEGIN{i=0
         while (i<100) {
                        i++
                        fizzbuzz(i)
                        }
     }
     function fizzbuzz(a){
         if (!index(a / 15,".")) print "FizzBuzz"
             else
                 if (!index(a / 3,".")) print "Fizz"
                     else
                         if (!index(a / 5,".")) print "Buzz"
                             else
                                 print a
     }



明日は引き続き **リテラルブロック** 関連について説明します。

※ このアドベントカレンダーについては :ref:`at_the_beginning` を参照して下さい。
