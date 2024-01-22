.. post:: 2024-01-20
   :tags: Ubuntu, Linux, Resonite
   :category: VR
   :author: usaturn
   :location: Japan
   :language: ja

.. _set_up_a_resonite_headless_server_on_ubuntu:

==========================================================
Ubuntsu 22.04 LTS 上で Resonite Headless Client を起動する
==========================================================

この記事は Resonite_ の
`Headless Client(通称ヘッドレスサーバと呼ばれている為、以下ヘッドレスサーバと記載します) <https://wiki.resonite.com/Headless_Client>`__
を Linux ディストリビューション(Ubuntu22.04)で動かす手順です。

Resonite_ は開発スピードが速い為、基本的には最新情報を確認してください。

誰向けの記事？
==============

Linux ディストリビューション(Ubuntu22.04)でヘッドレスサーバを動かしたいと考えている方向けです。

手順を実行する為にはヘッドレスサーバの概要を理解しており、ヘッドレスサーバを利用開始する為の条件をクリアしている必要があります。

既に Windows 版のヘッドレスサーバを利用していると理解が早いでしょう。

ヘッドレスサーバの利用条件や Windows 版の手順に関しては
`akiRAM <https://misskey.resonite.love/@akiRAM>`__ さんが
`【手順解説】Resoniteヘッドレスサーバの建て方！ <https://note.com/akiram_vr/n/n695fca3ac4f8>`__
という詳細な記事を書いてくださっているので参考にしてください。

前提条件
========

- 手元に Ubuntu22.04 をインストールしたコンピュータ(パソコンやサーバ)があること
- 対象のコンピュータがインターネット接続できていること
- Linux ディストリビューションを bash 等のシェルで操作できること

.. note:: インストールするバージョンは 2024年1月現在では Ubuntu Server 22.04.3 LTS が良いでしょう。
          X の使用を想定していませんがデスクトップ版をインストールしてターミナルでシェル操作しても構いません。
          普段の作業端末が Windows や Mac であれば、ssh でリモート接続した方が楽です。













.. _Resonite: https://store.steampowered.com/app/2519830/Resonite/?l=japanese
