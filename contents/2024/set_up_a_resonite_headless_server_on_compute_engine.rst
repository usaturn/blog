.. post:: 2024-12-03
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _set_up_a_resonite_headless_server_on_compute_engine:

====================================================
Google Cloud で resonite ヘッドレスサーバ を構築する
====================================================

この記事は resonite_ の
`Headless Client(通称ヘッドレスサーバと呼ばれている為、以下ヘッドレスサーバと記載します) <https://wiki.resonite.com/Headless_Client>`__
を `Google Cloud`_ 上で動かす手順です。

resonite_ は開発スピードが速い為、基本的には最新情報を確認してください。
本手順は 3 ヶ月程度で使えなくなる可能性があります。

`Google Cloud`_ は `Google Cloud Shell`_ を使用してコマンドラインで操作します。

誰向けの記事？
==============

下記の全てに当てはまる方向けです。

- :ref:`こちらの記事を見て興味を持った方 <about_a_resonite_headless_server_on_compute_engine>`
- resonite_ を常用していて Linux で ヘッドレスサーバ_ を建てたいと考えている方
- 既に Windows 上で ヘッドレスサーバ_ を起動することが苦でない方（参考 `【手順解説】Resoniteヘッドレスサーバの建て方！(By akiRAMさん)  <https://note.com/akiram_vr/n/n695fca3ac4f8>`__ ）

  - 現在 .NET9 Runtime が必要。Windows の場合は下記コマンドでインストール可能です ::

      winget install Microsoft.DotNet.Runtime.9

  .. note:: 手順を実行する為にはヘッドレスサーバの概要を理解しており、ヘッドレスサーバを利用開始する為の条件をクリアしている必要があります。
            Windows 版を起動することにより理解することが可能です。Linux 版はその時々の不具合でハマることがあるので最低限 Windows の起動が問題ないことを確認してください

- Linux ディストリビューションでコマンドを打つのに抵抗が無い方(※Ubuntu24.04を使用します)
- `Google Cloud`_ に興味がある方

概要
====

`Google Cloud`_ の VPC を作成し Google Compute Engine のインスタンス(VM＝仮想マシン)上にヘッドレスサーバを構築します。
本手順は、構築／削除／再構築のサイクルが回しやすいように作られています。また、2～3ヶ月毎に再作成することをお勧めします。

改善点があれば resonite でお会いした時に教えてください。
または `プルリクエスト <https://github.com/usaturn/resonite-headless-infra>`__ をくれても良いです。

前提条件
========

:ref:`about_a_resonite_headless_server_on_compute_engine` を一読してください。

- `Google Cloud Shell`_ が利用できる環境であること

  - 作業端末がインターネットに接続している必要があります
  - 作業端末で Web ブラウザが利用できる必要があります

- Linux ディストリビューションを CUI 操作できること

  - bash 等のシェルを扱えること

- クレジットカードが使える方( `Google Cloud`_ への支払いが発生します)

.. warning:: 起動時間の料金がかかります。
             本手順を実行し、すぐにインスタンスを停止した場合は数十円かかります。
             本手順で使っているインスタンスタイプ(t2d-standard-2)を1か月起動しっぱなしにした場合は、
             1万2000円程度かかってしまうので、必要な時以外は停止することを忘れないようにしましょう。

構築及び設定するクラウドリソース
================================

※ `Google Cloud`_ や AWS その他パブリックラウドをある程度知ってる方向けなので、よくわからない方は読み飛ばしてください

- VPC
- サブネット
- VPC ファイアウォール
- Compute Engine のインスタンス（VM＝仮想マシン）
- `Secret Manager`_ のシークレット

構築するヘッドレスサーバについては :ref:`こちら <about_build_sesrver>` を確認してください。

準備作業の流れ
==============

#. `Google Cloud`_ を契約しクレジットカード登録する（省略）

   https://cloud.google.com/

#. `Google Cloud Shell`_ をセットアップする

   - mise、fzf をインストールする
   - ``${HOME}/.bashrc`` を作成する

#. Steamガードをオフにする

.. _setup_cloud_shell:

`Google Cloud Shell`_ をセットアップする
----------------------------------------

#. ブラウザで `Google Cloud Shell`_ にアクセスします https://shell.cloud.google.com

#. Google Cloud のプロジェクトを指定します

   .. figure:: images/google_cloud_project.png
      :scale: 30%

.. _clone_repository:

#. 作業用リポジトリをクローンします ::

    git clone https://github.com/usaturn/resonite-headless-infra.git

#. `Google Cloud Shell`_ セットアップ用チュートリアルを起動します ::

    teachme resonite-headless-infra/setup-cloudshell.md

#. :command:`teachme` コマンドを打つとブラウザの右側にチュートリアルが表示されますので指示に従ってください

.. note:: `Google Cloud Shell`_ は毎回 ${HOME} のみ保持をして(120日間)、それ以外は Google 標準のイメージをマウントする関係上、
           sudo apt install ～ でインストールをしても次回起動時に消えてしまいます。
           ツール類は mise で ${HOME} 配下にインストールすると良いでしょう

          `Google Cloud Shell`_ に 120 日間アクセスしないと ${HOME} は初期化されてしまうので、初期化されてしまった場合は初めから設定仕直しする必要があります

.. note:: `Google Cloud Shell`_ 手順がうまくいかなくなった、環境が壊れてしまったという場合は初期化し、手順を初めからやり直してください

          #. 削除コマンドを打ちます ::

              # 削除するファイルを確認する
              ls -a $HOME

              # ユーザディレクトリを削除する（全て消えるので注意）
              sudo rm -rf $HOME

          #. 右上の三点リーダーをクリックし、再起動をクリックします

             .. figure:: images/restart_cloudshell.webp
                :scale: 30%

          #. 「VMの状態をクリーンにしたい」にチェックして再起動をクリックする

             .. figure:: images/restart_cloudshell_param.webp
                :scale: 30%

Steamガードをオフにする
-----------------------

steamcmd を自動でインストールする為に、Steamガードをオフにします。
一般的にはセキュリティ上、推奨されていないことに留意してください。
また、使用する各アカウント（Steam アカウントと及び resonite アカウント）はセキュリティ上、 **必ずヘッドレスサーバ専用でクレカ登録せずに** 作成してください。

#. Windows で Steam を起動します
#. メニューの **Steam** をクリックし、設定をクリックします
#. セキュリティをクリックします
#. **Steam ガードを管理** をクリックします
#. **Steam ガードをオフ** をチェックします

   .. figure:: images/steam_gard.png
      :scale: 30%

#. **Steam ガードを無効化** をクリックします
#. Steam に登録したメールアドレスへ **Steamガード無効化の確認** というタイトルでメールが届くのでメールを見て **STEAMガードを無効にする** をクリックしてください

.. note:: Steam ガードを有効にしたままでは、steamcmd を自動インストールできない為、無効化しています。
          サーバ構築後は、Steam ガードを有効に戻すことをお勧めします

Google Cloud にインフラを構築する
=================================

#. `Google Cloud Shell`_ のターミナルでヘッドレスサーバ構築用チュートリアルを起動します ::

    cd ~/resonite-headless-infra
    teachme setup-headless-infra.md

ヘッドレスサーバ_ が起動して他のアカウントが参加できたら成功です。

:ref:`明日の記事 <explaining_resonite_headless_server_on_compute_engine>` へ続きます。

環境を削除する
==============

必要なくなったら一旦環境を削除しましょう

::

    # インスタンスを削除する
    gcloud compute instances delete ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

    # ファイアウォールルールを削除する
    gcloud compute firewall-rules delete allow-iap-forwarding-to-resonite-headless

    # サブネットの割り当てを外す
    gcloud compute networks subnets delete "${SUBNET_NAME}" --region ${REGION}

    # VPC を削除する
    gcloud compute networks delete ${VPC_NAME}

.. _Google Cloud: https://console.cloud.google.com/welcome
.. _Google Cloud Shell: https://cloud.google.com/shell/docs
.. _resonite: https://store.steampowered.com/app/2519830/Resonite/
.. _Secret Manager: https://cloud.google.com/security/products/secret-manager
.. _ヘッドレスサーバ: https://wiki.resonite.com/Headless_Client
.. _シークレット: https://cloud.google.com/security/products/secret-manager
.. _マシンイメージ: https://cloud.google.com/compute/docs/machine-images/create-machine-images

