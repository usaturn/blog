.. post:: 2024-12-05
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _access_a_headless_server_interactive_shell:

======================================================================
GCE インスタンスの resonite ヘッドレスサーバ対話シェルにアクセスしよう
======================================================================

この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で構築した ヘッドレスサーバ_ について以下を実施します

- GCE インスタンスの起動／停止
- GCE インスタンスへの ssh アクセス
- ヘッドレスサーバ_ の対話シェル(headless server interface)操作

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

GCE インスタンスを起動／停止する
================================

インスタンスを確認します ::

    gce-list

起動コマンド
------------

以下のコマンドを実行すると、停止しているインスタンスが表示されるので選択して Enter を押してください

.. code-block:: bash

   gce-start


起動コマンド
------------

以下のコマンドを実行すると、停止しているインスタンスが表示されるので選択して Enter を押してください

.. code-block:: bash

   gce-start

停止コマンド
------------

以下のコマンドを実行すると、起動しているインスタンスが表示されるので選択して Enter を押してください

.. code-block:: bash

   gce-stop

GCE インスタンスに ssh でアクセスする
=====================================

以下のコマンドを実行すると、起動しているインスタンスが表示されるので選択して Enter を押してください

.. code-block:: bash

   gce-ssh

ヘッドレスサーバ_ の対話シェル(headless server interface)に入る
---------------------------------------------------------------

ヘッドレスサーバ_ は tmux(ターミナルマルチプレクサの一種) から起動している為、起動中の tmux セッションに入ることでアクセスできます

ヘッドレスサーバの対話シェルにアクセスします ::

    tmux a

tmux の config は標準と違い、prefix キーを `C-k` に変更しています ::

    Ctrl+k ⇒ c 新しくウィンドウを作成する
    Ctrl+k ⇒ n 次のウィンドウを表示する
    Ctrl+k ⇒ p 前のウィンドウに表示する
    Ctrl+k ⇒ d セッションをデタッチする（ヘッドレスサーバは起動したまま）

    # コピーモード ※画面をスクロールできるようになる
    Ctrl+k ⇒ [ コピーモードを開始する
    h           カーソルを左に移動する
    j           カーソルを下に移動する
    k           カーソルを上に移動する
    l           カーソルを右に移動する
    Ctrl-b      ページアップ
    Ctrl-f      ページダウン

元のシェルに戻り、ログオフします ::

    # セッションをデタッチする（ヘッドレスサーバは起動したまま）
    Ctrl+k ⇒ d

    # GCE インスタンスのシェルから抜ける
    exit

ヘッドレスサーバの Unit （自動起動設定）の確認をします ::

    # ヘッドレスサーバのサービスが動いていることを確認する
    systemctl status resonite-headless.service

    # ヘッドレスサーバのサービスをリスタートする
    sudo systemctl restart resonite-headless.service

    # ヘッドレスサーバのサービスを停止する
    systemctl status resonite-headless.service

SFTP 接続をする
---------------

IAP のポート転送を使うことができます ::

    INSTANCE_NAME=$(gcloud compute instances list --filter="status=TERMINATED" --format="value(name)"|fzf)
    gcloud compute start-iap-tunnel ${INSTANCE_NAME} 22 --local-host-port=localhost:10022 --zone=${ZONE}

    sftp -P 10022 localhost

GCE インスタンスを削除する
==========================

GCE インスタンスが不要になったら削除しましょう ::

    gcloud compute instances delete ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME}

.. note:: GCE インスタンスは使わない時は停止して、必要な時に起動してください。
             停止している間は基本的に課金されませんが、例外として停止中も1日に数円単位でディスク使用料金がかかります

.. note:: gce コマンドは ``${HOME}/.bashrc`` に書かれているので確認してみてください

   .. code-block:: bash

       function gce-start(){
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=TERMINATED" --format="value(name)"|fzf)
           if [ -n "${INSTANCE_NAME}" ]; then
               ZONE=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(zone)")
               gcloud compute instances start ${INSTANCE_NAME} --zone=${ZONE}
           else
               echo Instance is not specified.
           fi
           gcloud compute instances list
       }

       function gce-stop(){
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=RUNNING" --format="value(name)"|fzf)
           if [ -n "${INSTANCE_NAME}" ]; then
               ZONE=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(zone)")
               gcloud compute instances stop ${INSTANCE_NAME} --zone=${ZONE}
           else
               echo Instance is not specified.
           fi
           gcloud compute instances list
       }

       function gce-ssh(){
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=RUNNING" --format="value(name)"|fzf)
           if [ -n "${INSTANCE_NAME}" ]; then
               ZONE=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(zone)")
               gcloud compute ssh --tunnel-through-iap ${INSTANCE_NAME} --zone=${ZONE}
           else
               echo Instance not specified.
           fi
       }

       alias gce-list='gcloud compute instances list --format="table[BOX](name, resourcePolicies[0].basename(), zone, machineType, scheduling.preemptible, networkInterfaces[].accessConfigs[natIP], status)"'

.. warning:: ※注意事項

        ``gce-ssh`` は Google Cloud の IAP という仕組みを使っています

        https://cloud.google.com/compute/docs/connect/ssh-using-iap?hl=ja

        IAP 経由の ssh ログインをした場合、自動的にローカルのユーザ名でユーザが作成されます。
        本手順は Cloud Shell を起動したローカルのユーザ名を元にしてディレクトリ配置をしているので、ローカルのユーザ名が違う端末から ssh アクセスしようとするとうまくいきません。

以上

:ref:`明日の記事 <update_a_resonite_headless_server_config>` へ続きます。

.. _Google Cloud: https://console.cloud.google.com/welcome
.. _Google Cloud Shell: https://cloud.google.com/shell/docs
.. _resonite: https://store.steampowered.com/app/2519830/resonite/
.. _Secret Manager: https://cloud.google.com/security/products/secret-manager
.. _ヘッドレスサーバ: https://wiki.resonite.com/Headless_Client
.. _シークレット: https://cloud.google.com/security/products/secret-manager
.. _マシンイメージ: https://cloud.google.com/compute/docs/machine-images/create-machine-images

