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

`(2枚目) Resonite Advent Calendar 2024 <https://adventar.org/calendars/10544>`__ 6日目の記事です

この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で構築した ヘッドレスサーバ_ について以下を実施します

- シークレットに配置した ヘッドレスサーバ_ の設定ファイル ``Config.json`` を書き換える

前提条件
========

:ref:`こちらでセットアップした <setup_cloud_shell>` `Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

インフラ設定用の環境変数を設定する
==================================

環境変数を読み込み、出力結果が正しいことを確認します（空欄がなければ良いです） ::

    reso

インスタンス停止中に Config を更新する手順
==========================================

インスタンスが停止している時に実施することを想定しています（起動していても問題はありません）。

#. 更新対象のインスタンス名を変数にします ::

    RESONITE_HEADLESS_SERVER_INSTANCE_NAME=$(gcloud compute instances list --format="value(name)"|fzf)
    HEADLESS_CONFIG_SECRET=${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} && echo ${HEADLESS_CONFIG_SECRET}

#. Config.Json を変数にします ::

    HEADLESS_CONFIG_FILE=${HOME}/resonite-headless-infra/config/Config.json

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

#. ヘッドレスサーバ_ の ``Config.json`` を シークレット_ に追加します ※先に ヘッドレスサーバ_ を起動すると ``Config.json`` が巻き戻ります ::

    gcloud secrets versions add ${HEADLESS_CONFIG_SECRET} --data-file=${HEADLESS_CONFIG_FILE}

#. シークレット_ の最新バージョンが更新されたことを確認します ::

    gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET}

#. ヘッドレスサーバ_ の起動確認をします ::

    sudo systemctl daemon-reload
    systemctl status resonite-headless.service
    sudo systemctl restart resonite-headless.service


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

.. include:: /contents/include_files/resonite_headless_link.txt

