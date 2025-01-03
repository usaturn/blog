.. post:: 2024-12-06
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _update_a_resonite_headless_server_config:

=====================================================================
GCE インスタンス上の resonite ヘッドレスサーバ の Config を更新しよう
=====================================================================

この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で構築した ヘッドレスサーバ_ について以下を実施します

- シークレットに配置した ヘッドレスサーバ_ の設定ファイル ``Config.json`` を書き換える

前提条件
========

:ref:`こちらでセットアップした <setup_cloud_shell>` `Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

インフラ設定用の環境変数を設定する
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


gcloud CLI の構成を設定します ::

    PROJECT_NAME=$(gcloud config list --format="value(core.project)")
    gcloud config set project ${PROJECT_NAME}
    gcloud config set compute/zone ${ZONE}
    gcloud config set compute/region ${REGION}

インスタンス停止中に Config を更新する手順
==========================================

インスタンスが停止している時に実施することを想定しています（起動していても問題はありません）。

#. 更新対象のインスタンス名を変数にします ::

    RESONITE_HEADLESS_SERVER_INSTANCE_NAME=$(gcloud compute instances list --format="value(name)"|fzf)
    HEADLESS_CONFIG_SECRET=${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} && echo ${HEADLESS_CONFIG_SECRET}

#. Config.Json を変数にします ::

    HEADLESS_CONFIG_FILE=${HOME}/resonite-headless-infra/Config/Config.json

#. 最新のシークレット(ヘッドレスサーバに適用されている Config.Json)をローカルに書き出します ::

    gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET} > ${HEADLESS_CONFIG_FILE}

#. ローカルの Config.Json を編集します(Ctrl+s で保存) ::

    edit ${HEADLESS_CONFIG_FILE}

#. 書き換えたローカルの Config.Json をシークレットに追加します ::

    gcloud secrets versions add ${HEADLESS_CONFIG_SECRET} --data-file=${HEADLESS_CONFIG_FILE}

#. シークレット_ の最新バージョンが更新されたことを確認します ::

    gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET}

以上

インスタンス起動中に OS にログインして更新する手順
==================================================

トラブル対応などで OS にログインして修正⇒起動を繰り返す場合を想定しています

#. インスタンスを指定して起動します ::

    gce-start


#. ``Config.json`` を編集します（※Ctrl+s で上書き保存する） ::

    # シークレット名、Config.json のパスを変数にする
    INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name 2>/dev/null)
    HEADLESS_CONFIG_SECRET=${INSTANCE_NAME}
    RESONITE_HEADLESS_DIR="${HOME}/.local/share/Steam/steamapps/common/Resonite/Headless"
    HEADLESS_CONFIG_FILE=${RESONITE_HEADLESS_DIR}/Config/Config.json

    # Config.json を編集する
    nano ${HEADLESS_CONFIG_FILE}

#. ヘッドレスサーバ_ の起動確認をします ::

    sudo systemctl daemon-reload
    systemctl status resonite-headless.service
    sudo systemctl restart resonite-headless.service

#. 問題がなければ、 ヘッドレスサーバ_ の ``Config.json`` を シークレット_ に追加します ::

    gcloud secrets versions add ${HEADLESS_CONFIG_SECRET} --data-file=${HEADLESS_CONFIG_FILE}

#. シークレット_ の最新バージョンが更新されたことを確認します ::

    gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET}

以上

ちょっと解説
============

シークレット_ は管理上わかりやすくする為にインスタンス名と同名にしています。
インスタンス内部から自身のインスタンス名を知る為には以下のようにメタデータへアクセスします ::

    curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name

インスタンス停止時にも ``Config.json`` 更新する為、 シークレット_ に丸ごと格納し、ヘッドレスサーバを起動するたびにシークレットから ``Config.json`` を呼び出すという手法をとっています。
Unit ``resonite-headless.service`` では ``/var/lib/resonite/start-resonite-headless.bash`` を呼び出しており、その中で ``Config.json`` を シークレット_ から書き出す処理をしています ::

   export INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name 2>/dev/null)
   export HEADLESS_CONFIG_SECRET=${INSTANCE_NAME}
   export RESONITE_HEADLESS_DIR="${HOME}/.local/share/Steam/steamapps/common/Resonite/Headless"
   export HEADLESS_CONFIG_FILE=${RESONITE_HEADLESS_DIR}/Config/Config.json
   gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET} > ${HEADLESS_CONFIG_FILE}
   /usr/games/steamcmd +login usaturnless +app_update 2519830 validate +exit

以上

:ref:`明日の記事 <schedule_gce_instance>` へ続きます。

.. _Google Cloud: https://console.cloud.google.com/welcome
.. _Google Cloud Shell: https://cloud.google.com/shell/docs
.. _resonite: https://store.steampowered.com/app/2519830/resonite/
.. _Secret Manager: https://cloud.google.com/security/products/secret-manager
.. _ヘッドレスサーバ: https://wiki.resonite.com/Headless_Client
.. _シークレット: https://cloud.google.com/security/products/secret-manager
.. _マシンイメージ: https://cloud.google.com/compute/docs/machine-images/create-machine-images

