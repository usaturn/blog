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

`(2枚目) Resonite Advent Calendar 2024 <https://adventar.org/calendars/10544>`__ 5日目の記事です

この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で構築した ヘッドレスサーバ_ について以下を実施します

- GCE インスタンスの起動／停止
- GCE インスタンスへの ssh アクセス
- ヘッドレスサーバ_ の対話シェル(headless server interface)操作

前提条件
========

:ref:`こちらでセットアップした <setup_cloud_shell>` `Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

インフラ設定用の環境変数を設定する
==================================

環境変数を読み込み、出力結果が正しいことを確認します（空欄がなければ良いです） ::

    reso

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
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=TERMINATED" --format="value(name)"| fzf)
           if [ -n "${INSTANCE_NAME}" ]; then
               ZONE=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(zone)")
               gcloud compute instances start ${INSTANCE_NAME} --zone=${ZONE}
           else
               echo Instance is not specified.
           fi
           gcloud compute instances list
       }

       function gce-stop(){
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=RUNNING" --format="value(name)"| fzf)
           if [ -n "${INSTANCE_NAME}" ]; then
               ZONE=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(zone)")
               gcloud compute instances stop ${INSTANCE_NAME} --zone=${ZONE}
           else
               echo Instance is not specified.
           fi
           gcloud compute instances list
       }

       function gce-ssh(){
           INSTANCE_NAME=$(gcloud compute instances list --filter="status=RUNNING" --format="value(name)"| fzf)
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

.. include:: /contents/include_files/resonite_headless_link.txt

