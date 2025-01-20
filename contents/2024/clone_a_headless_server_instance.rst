.. post:: 2024-12-08
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _clone_a_headless_server_instance:

========================================================
resonite ヘッドレスサーバの GCE インスタンスを複製しよう
========================================================

`(2枚目) Resonite Advent Calendar 2024 <https://adventar.org/calendars/10544>`__ 8日目の記事です

この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で構築した ヘッドレスサーバ_ を複製します。
同様の ヘッドレスサーバ_ を複数台準備したい時に便利な手順です

手順の流れ
==========

:ref:`こちらでセットアップした <setup_cloud_shell>` `Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

流れとしては以下の通り

#. ヘッドレスサーバ_ の ``Config.Json`` を シークレット_ に格納する
#. GCE インスタンスのマシンイメージを作成し、マシンイメージから新規インスタンスを構築する

インフラ設定用の環境変数を設定する
==================================

環境変数を読み込み、出力結果が正しいことを確認します（空欄がなければ良いです） ::

    reso

``Config.Json`` を シークレット_ に格納する
===========================================

新規で作成する ヘッドレスサーバ_ の ``Config.Json`` を先に作って シークレット_ に格納します。

#. 複製するインスタンス名を変数にする ::

    SOURCE_INSTANCE_NAME=$(gcloud compute instances list --format="value(name)"|fzf)

#. 新規で作成するインスタンス名を考えて変数にする（例: インスタンス名を clone-server01 にする） ::

    RESONITE_HEADLESS_SERVER_INSTANCE_NAME=clone-server01 && echo ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

#. カレントディレクトリを :ref:`クローンしたリポジトリ <clone_repository>` に変更します ::

    REPOSITORY_DIR="${HOME}/resonite-headless-infra" && cd ${REPOSITORY_DIR}/config/

#. ``Config.json`` が存在することを確認する ::

    HEADLESS_CONFIG_FILE=Config.json && ls -l ${HEADLESS_CONFIG_FILE}

#. ``Config.json`` を編集します（※Ctrl+s で上書き保存する） ::

    edit ${HEADLESS_CONFIG_FILE}

#. 新しい シークレット_ をインスタンス名で作成し ``Config.json`` の内容を格納します ::

    gcloud secrets create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} --data-file ${HEADLESS_CONFIG_FILE}

#. シークレット_ に格納されたことを確認します ::

    gcloud secrets versions list ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

#. シークレット_ の内容を読みだして確認します ::

    gcloud secrets versions access latest --secret ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

GCE インスタンス内部からシークレットへアクセスできるように設定する
==================================================================

``Config.Json`` はインスタンス内部で毎回 シークレット_ から読みだす設定になっている為、アクセス許可の設定をします。

#. GCE インスタンスに割り当てられている Google Service Account を変数にする ::

    GSA=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")-compute@developer.gserviceaccount.com && echo ${GSA}

#. 作成したシークレットに対して IAM ポリシーバインディングを設定する ::

    gcloud secrets add-iam-policy-binding ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
        --member serviceAccount:${GSA} \
        --role roles/secretmanager.secretAccessor

#. シークレットへのアクセスを確認する ::

    gcloud secrets get-iam-policy ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}


マシンイメージを作成する
========================

複製元のインスタンスから マシンイメージ_ を作成します

#. 作成する マシンイメージ_ の名前を考えて変数にします（例: resonite_image） ::

    MACHINE_IMAGE_NAME=resonite_image

#. インスタンスからマシンイメージを作成します ::

    gcloud compute machine-images create ${MACHINE_IMAGE_NAME} --source-instance=${SOURCE_INSTANCE_NAME}

#. マシンイメージが作成されたことを確認します ::

    gcloud compute machine-images describe ${MACHINE_IMAGE_NAME}

マシンイメージからインスタンスを作成する
========================================

#. 作成したマシンイメージを元にして新しいインスタンスを作成します ::

    gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
        --machine-type ${MACHINE_TYPE} \
        --source-machine-image=${MACHINE_IMAGE_NAME}

#. 作成されたことを確認します（※作成すると同時に起動します） ::

    gce-list

.. note:: テスト用に、落ちることが許容されるインスタンスを作成するなら値段が 1/4 の Spot VM を利用することをお勧めします

       ::

           gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
               --machine-type ${MACHINE_TYPE} \
               --source-machine-image=${MACHINE_IMAGE_NAME} \
               --provisioning-model=SPOT \
               --instance-termination-action=STOP \
               --maintenance-policy=TERMINATE

.. note:: その他のコマンド

   ::

       # マシンイメージの一覧を表示する
       gcloud compute machine-images list

       # マシンイメージの一覧から選択して変数に入れる
       MACHINE_IMAGE_NAME=$(gcloud compute machine-images list --format="value(name)"|fzf)

       # マシンイメージを削除する
       gcloud compute machine-images delete ${MACHINE_IMAGE_NAME}

       # マシンイメージを変数に入れる
       MACHINE_IMAGE_NAME=$(gcloud compute machine-images list --format="value(name)"|fzf)

:ref:`明日の記事 <check_the_price_and_choose_an_instance>` へ続きます。

.. include:: /contents/include_files/resonite_headless_link.txt

