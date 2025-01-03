.. post:: 2024-12-04
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _explaining_resonite_headless_server_on_compute_engine:

===============================================================
Google Cloud で resonite ヘッドレスサーバ を構築する ～解説編～
===============================================================

この記事は :ref:`set_up_a_resonite_headless_server_on_compute_engine` で使用したチュートリアルをブログで確認する目的で書き起こしています。
一部、補足説明を入れました。

この記事だけでは構築できませんので ヘッドレスサーバ_ を構築する際は :ref:`set_up_a_resonite_headless_server_on_compute_engine` の手順を実施してください。

手順の流れ
==========

`Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

- インフラ構築用の環境変数を設定する
- VPC ネットワークを作成する

  - SUBNET 割り当て
  - ネットワークファイアウォールルール作成

    - Config.json の forceport に設定したポートを inbound で許可する

- GCE インスタンス作成
- ヘッドレスサーバ確認

インフラ構築用の環境変数を設定する
==================================

環境変数を読み込みます ::

    source ~/resonite-headless-infra/scripts/env-headless-server.bash

環境変数が設定されたことを確認します ::

    echo -e \
        "RESONITE_HEADLESS_ENVIRONMENT\t\t=\t${RESONITE_HEADLESS_ENVIRONMENT}"\\n\
        "VPC_NAME\t\t\t\t=\t${VPC_NAME}"\\n\
        "SUBNET_NAME\t\t\t\t=\t${SUBNET_NAME}"\\n\
        "REGION\t\t\t\t\t=\t${REGION}"\\n\
        "SUBNET_RANGE\t\t\t\t=\t${SUBNET_RANGE}"\\n\
        "RESONITE_HEADLESS_SERVER_INSTANCE_NAME\t=\t${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}"\\n\
        "IMAGE_PROJECT\t\t\t\t=\t${IMAGE_PROJECT}"\\n\
        "IMAGE_FAMILY_SCOPE\t\t\t=\t${IMAGE_FAMILY_SCOPE}"\\n\
        "IMAGE_FAMILY\t\t\t\t=\t${IMAGE_FAMILY}"\\n\
        "ZONE\t\t\t\t\t=\t${ZONE}"\\n\
        "SETUP_RESONITE_HEADLESS_SERVER_SCRIPT\t=\t${SETUP_RESONITE_HEADLESS_SERVER_SCRIPT}"\\n\
        "MACHINE_TYPE\t\t=\t${MACHINE_TYPE}"\\n\

環境変数それぞれの意味を記載しておきます

:RESONITE_HEADLESS_ENVIRONMENT: 東京 ※台湾、シンガポールなど他のリージョンで作る際に記載するタイトルでデータ的な意味はありません
:VPC_NAME: resonite-headless-network ※作成する VPC に付ける名前です
:SUBNET_NAME: subnet-${VPC_NAME} ※割り当てるサブネットの名前です
:REGION: asia-northeast1 ※リージョン名です。東京です
:ZONE: asia-northeast1-b ※ゾーン名です。東京リージョンの b です
:SUBNET_RANGE: 192.168.1.0/24 ※サブネットの範囲です
:FIREWALL_TAG_NAME: resonite-headless ※ファイアウォールのタグ名です。GCE インスタンスにつけるタグと連動することによりファイアウォールで通信制御します
:RESONITE_HEADLESS_SERVER_INSTANCE_NAME: resonite-headless-server ※ヘッドレスサーバを起動する GCE インスタンスに付ける名前です
:IMAGE_PROJECT: ubuntu-os-cloud ※IMAGE_FAMILYと合わせて作成するGCEインスタンスの OS を決定します
:IMAGE_FAMILY_SCOPE: zonal ※作成するGCEインスタンスの OS を決定します
:IMAGE_FAMILY: ubuntu-minimal-2404-lts-amd64 ※作成するGCEインスタンスの OS を決定します。作成しなおす時は最新かどうか確認が必要です
:MACHINE_TYPE: t2d-standard-2 ※GCEインスタンスの性能が決まります。一番コストパフォーマンスが良いと筆者が考えている物を指定しています
:SETUP_RESONITE_HEADLESS_SERVER_SCRIPT: setup-config.yaml ※GCEインスタンス起動時に実行される cloud-config のスクリプト名です
:MACHINE_IMAGE_NAME: resonite-headless ※マシンイメージを作成する時につける名前です

.. note:: 編集する時は Cloud Shell Editor で編集してください

   ::

       edit ~/resonite-headless-infra/scripts/env-headless-server.bash

gcloud CLI の構成を管理する
===========================

gcloud コマンドを使用してヘッドレスサーバのインフラを構築していきます。
事前に gcloud CLI の構成を設定します ::

    PROJECT_NAME=$(gcloud config list --format="value(core.project)")
    gcloud config set project ${PROJECT_NAME}
    gcloud config set compute/zone ${ZONE}
    gcloud config set compute/region ${REGION}

VPC ネットワークを作成する
==========================

VPC を作成します ::

    gcloud compute networks create ${VPC_NAME} --subnet-mode custom --mtu=1500

VPC が作成されたことを確認します ::

    gcloud compute networks list --filter="name=${VPC_NAME}"
    gcloud compute networks describe ${VPC_NAME}

作成したVPCネットワークにリージョンとサブネットを割り当てます ::

    gcloud compute networks subnets create ${SUBNET_NAME} \
        --network ${VPC_NAME} \
        --region ${REGION} \
        --range ${SUBNET_RANGE} \
        --enable-private-ip-google-access

サブネットが割り当てられたことを確認します ::

    gcloud compute networks subnets list --filter="name=${SUBNET_NAME}"
    gcloud compute networks subnets describe ${SUBNET_NAME}


ファイアウォールルールを作成する
================================

IAP から VPC ネットワークへのアクセスを許可します。IAP は Google 内部ネットワーク経由でアクセスする手段です。
`詳しくはこちら <https://cloud.google.com/iap/docs/concepts-overview>`__ ::

    gcloud compute firewall-rules create \
      allow-iap-forwarding-to-resonite-headless \
      --direction=INGRESS \
      --priority=1000 \
      --network=${VPC_NAME} \
      --allow=tcp:22,tcp:80,tcp:443,tcp:8080,icmp \
      --source-ranges=35.235.240.0/20

ヘッドレスサーバの forcePort へのアクセスを許可します。 udp/49151～49160 を想定しています ::

    gcloud compute firewall-rules create allow-resonite-headless-forceport \
      --target-tags=${FIREWALL_TAG_NAME} \
      --direction=INGRESS \
      --priority=1000 \
      --network=${VPC_NAME} \
      --allow=udp:49151-49160 \
      --enable-logging \
      --source-ranges=0.0.0.0/0

ファイアウォールルールが作成されたことを確認します ::

    gcloud compute firewall-rules list --filter="NOT(name:default)"

.. note:: forcePort について

   Config.json 内で標準で null が指定されています ::

      "overrideCorrespondingWorldId": null,
      "forcePort": null,
      "keepOriginalRoles": false,

   手順通りに実行した場合、49151 から 49160 の間で設定してください。
   わかる人は ``--allow=udp:49151-49160`` の数字を 1025 ～ 65535 の間で使用していないとわかっている番号にしても構いません。

Config をシークレットに格納する
===============================

ヘッドレスサーバの設定ファイル ``Config.json`` を `Secret Manager`_ に格納します。

#. カレントディレクトリを :ref:`クローンしたリポジトリ <clone_repository>` に変更します ::

    REPOSITORY_DIR="${HOME}/resonite-headless-infra" && cd ${REPOSITORY_DIR}/config/

    # Config.json が存在することを確認する
    HEADLESS_CONFIG_FILE=Config.json && ls -l ${HEADLESS_CONFIG_FILE}

#. ``Config.json`` を編集します（※Ctrl+s で上書き保存する） ::

    edit ${HEADLESS_CONFIG_FILE}

#. `シークレット <Secret Manager>`_ をインスタンス名で作成します ::

    # インスタンス名をシークレット名の変数に入れる
    HEADLESS_CONFIG_SECRET=${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} && echo ${HEADLESS_CONFIG_SECRET}

    # ヘッドレスの config ファイルを Secret Manager に格納する
    gcloud secrets create ${HEADLESS_CONFIG_SECRET} --data-file ${HEADLESS_CONFIG_FILE}

    # シークレットに格納されたことを確認する
    gcloud secrets versions list ${HEADLESS_CONFIG_SECRET}

    # シークレットの内容を出力する
    gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET}

.. note:: `Secret Manager`_ は API キー、パスワード、証明書などの機密情報を安全に保存・管理するためのサービスです。
          以下の特徴がありますが、ここでは専ら Config.json をローカルで書き換えてクラウドに保存し、
          ヘッドレスサーバが起動するごとにシークレットから読みだすという目的の為に使用しています。

          - 暗号化されたストレージで機密情報を保存
          - バージョン管理により、シークレットの履歴管理が可能
          - IAM (Identity and Access Management) による詳細なアクセス制御

#. GCE インスタンス内部からシークレットへアクセスできるように設定する

   ::

       GSA=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")-compute@developer.gserviceaccount.com && echo ${GSA}

       # 作成したシークレットに対して IAM ポリシーバインディングを設定する
       gcloud secrets add-iam-policy-binding ${HEADLESS_CONFIG_SECRET} \
           --member serviceAccount:${GSA} \
           --role roles/secretmanager.secretAccessor

       # シークレットへのアクセス権限を確認する
       gcloud secrets get-iam-policy ${HEADLESS_CONFIG_SECRET}

   .. note:: config.json を格納したシークレットは、そのままでは GCE インスタンスから読みだすことができません。
             GCE インスタンスに割り当てられている Google Service Account をシークレットの IAM ポリシーに紐づけることにより、GCE インスタンス内部から対象のシークレットを読みだすことができます

             GCE インスタンス起動時にデフォルトの Google Service Account [PROJECT_NUMBER]-compute@developer.gserviceaccount.com が割り当てられていますが、
             ベストプラクティスは新しく Service Account を作って割り当てる、ということになっています。本手順は標準で割り当てられているものをそのまま使っています

   .. note:: インスタンスを作成した後であれば、 Google Service Account は下記コマンドで確認できます

          ::

              GSA=$(gcloud compute instances describe ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} --format="value(serviceAccounts[0].email)") && echo ${GSA}

resonite Headless Server 用インスタンスを作成する
=================================================

#. カレントディレクトリをスクリプトが配置されたディレクトリに変更し OS セットアップファイルのテンプレートがあることを確認します ::

    cd ${REPOSITORY_DIR}/scripts/ && ls -l setup-config.yaml.template

#. ヘッドレスサーバを作成する為に必要な情報を編集します ::

    edit personal-information.json

    # 編集内容
    {
        "HEADLESS_PASSWORD": "フレンド欄の resonite に /headlessCode とメッセージを送って返ってくる文字列",
        "STEAM_USER": "ヘッドレスサーバ用に作成した Steam アカウント名",
        "STEAM_PASSWORD": "Steam アカウントのパスワード",
        "HEADLESS_USER": "ヘッドレスサーバ用に作成した resonite ユーザ名"
    }

#. GCE インスタンスを作成する為の設定ファイルを生成します ::

    python gce_cloudinit_yaml_generator.py

#. ``#cloud-config`` で始まるファイルが生成された事を確認します  ::

    edit setup-config.yaml

#. GCE インスタンスを作成します

   ::

       gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
           --tags=${FIREWALL_TAG_NAME} \
           --image-project=${IMAGE_PROJECT} \
           --image-family=${IMAGE_FAMILY} \
           --image-family-scope=${IMAGE_FAMILY_SCOPE} \
           --machine-type=${MACHINE_TYPE} \
           --subnet=${SUBNET_NAME} \
           --metadata-from-file=user-data=${SETUP_RESONITE_HEADLESS_SERVER_SCRIPT} \
           --network-tier=STANDARD \
           --scopes cloud-platform

   .. note:: テスト用に、落ちることが許容されるインスタンスを作成するなら値段が 1/4 の Spot VM を利用することをお勧めします

      ::

          gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
              --tags=${FIREWALL_TAG_NAME} \
              --image-project=${IMAGE_PROJECT} \
              --image-family=${IMAGE_FAMILY} \
              --image-family-scope=${IMAGE_FAMILY_SCOPE} \
              --machine-type=${MACHINE_TYPE} \
              --subnet=${SUBNET_NAME} \
              --metadata-from-file=user-data=${SETUP_RESONITE_HEADLESS_SERVER_SCRIPT} \
              --network-tier=STANDARD \
              --scopes cloud-platform \
              --provisioning-model=SPOT \
              --instance-termination-action=STOP \
              --maintenance-policy=TERMINATE

#. GCE インスタンスが作成され、ステータスが Running であることを確認します ::

    gcloud compute instances describe ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} --format="value(status)"

5分程待つと ヘッドレスサーバ_ が起動します。

ヘッドレスサーバ_ が起動しない場合の調査
========================================

インスタンスにログインして原因を調査します

#. SSH で GCE インスタンスへログインします

   ::

       gcloud compute ssh --tunnel-through-iap ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

       # 以下のようなメッセージが出ますが、全て Enter を押して問題ない
       WARNING: The private SSH key file for gcloud does not exist.
       WARNING: The public SSH key file for gcloud does not exist.
       WARNING: You do not have an SSH key for gcloud.
       WARNING: SSH keygen will be executed to generate a key.
       This tool needs to create the directory [/home/${HOME}/.ssh] before being able to generate SSH keys.

       Do you want to continue (Y/n)?  ← Enter で良い

       Generating public/private rsa key pair.
       Enter passphrase (empty for no passphrase): ※ ssh が使う秘密鍵のパスフレーズを要求されるが入力しなくても良い。鍵を削除し gcloud compute ssh 実行すればを再作成される
       Enter same passphrase again: 
       Your identification has been saved in /home/${HOME}/.ssh/google_compute_engine
       ～省略～
       Waiting for SSH key to propagate.
       ～省略～

#. OS ログイン後、GCE インスタンスの OS セットアップが完了しているかどうかを確認します ::

       # /root/INITIALIZED というファイルが存在していればセットアップが完了している
       sudo ls -l /root/INITIALIZED

       # INITIALIZED が存在していなかった場合、ログを確認し、エラーが出ていた場合は出力メッセージを元にして調査をする
       # エラーが出ていない場合は Succeeded. と表示されるまで待つ
       sudo tail -f /root/command.log

#. ヘッドレスサーバの自動起動設定及び、起動確認をします

        ::

            # 構築時に作ったヘッドレスサーバの Unit ファイルを読み込ませる
            sudo systemctl daemon-reload

            # ヘッドレスサーバのサービスをスタートアップに入れつつ、即座に起動する
            sudo systemctl --now enable resonite-headless.service

            # ヘッドレスサーバのサービスが動いていることを確認する
            systemctl status resonite-headless.service

   .. note:: ヘッドレスサーバのサービスをリスタートする

             ::

                 sudo systemctl restart resonite-headless.service

#. ログオフします ::

    # GCE インスタンスのシェルから抜ける
    exit

#. GCE インスタンスを終了します ::

    gcloud compute instances stop ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}


#. GCE インスタンスを起動して自動でヘッドレスサーバが起動することを確認してください ::

    gcloud compute instances start ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

#. GCE インスタンスが不要になったら削除しましょう

       ::

           gcloud compute instances delete ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

   .. note:: GCE インスタンスは使わない時は停止して、必要な時に起動してください。
             停止している間は基本的に課金されませんが、例外として停止中も1日に数円単位でディスク使用料金がかかります

:ref:`明日の記事 <access_a_headless_server_interactive_shell>` へ続きます。

.. _Google Cloud: https://console.cloud.google.com/welcome
.. _Google Cloud Shell: https://cloud.google.com/shell/docs
.. _resonite: https://store.steampowered.com/app/2519830/resonite/
.. _Secret Manager: https://cloud.google.com/security/products/secret-manager
.. _ヘッドレスサーバ: https://wiki.resonite.com/Headless_Client

