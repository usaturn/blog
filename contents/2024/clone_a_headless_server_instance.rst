.. _clone_a_headless_server_instance:

========================================================
resonite ヘッドレスサーバの GCE インスタンスを複製しよう
========================================================

:maatlog-post: true
:maatlog-published-at: 2024-12-08T00:00:00+09:00
:maatlog-slug: clone-a-headless-server-instance
:maatlog-tags: ubuntu,linux,resonite,vr
:maatlog-categories: it-technology
:maatlog-authors: usaturn

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

#. 作成する マシンイメージ_ の名前を考えて変数にします（例: resonite-image） ::

    MACHINE_IMAGE_NAME=resonite-image

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

       # 削除したインスタンス用のシークレットを削除する
       NOT_REQUIRED_SECRET=$(gcloud secrets list --format="value(name)"|fzf) && echo ${NOT_REQUIRED_SECRET}
       gcloud secrets delete ${NOT_REQUIRED_SECRET}


同じマシンタイプでインスタンスを複数作成する際の注意事項
========================================================

上記の複製方法でインスタンスのクローンを作成していると、5個目を作成（及び起動）しようとしたところで、下記のようなエラーが出ます

::

    ERROR: (gcloud.compute.instances.create) Could not fetch resource:
     - Quota 'T2D_CPUS' exceeded.  Limit: 8.0 in region asia-northeast1.
            metric name = compute.googleapis.com/t2d_cpus
            limit name = T2D-CPUS-per-project-region
            limit = 8.0
            dimensions = region: asia-northeast1
    Try your request in another zone, or view documentation on how to increase quotas: https://cloud.google.com/compute/quotas.

本手順で使っているマシンタイプ **t2d-standard-2** は 1台あたり 2 vCPU なので、
リージョンあたりの ``T2D_CPUS`` の割り当て（初期値 8）を 4台で使い切ってしまうということのようです。
対処方法は以下の3通りが考えられます

別のリージョン・ゾーンで作成する
--------------------------------

割り当てはリージョン単位なので、別のリージョンのゾーンを指定すれば作成できます。
指定できるゾーンは `リージョンとゾーン <https://cloud.google.com/compute/docs/regions-zones?hl=ja>`__ を参照してください（例: asia-northeast2（大阪）、asia-northeast3（ソウル）） ::

    # 新しい ZONE でインスタンスを作成する
    gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
        --machine-type ${MACHINE_TYPE} \
        --source-machine-image=${MACHINE_IMAGE_NAME} \
        --zone=${ZONE}

    # Spot VM で作成する場合
    gcloud compute instances create ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} \
        --machine-type ${MACHINE_TYPE} \
        --source-machine-image=${MACHINE_IMAGE_NAME} \
        --provisioning-model=SPOT \
        --instance-termination-action=STOP \
        --maintenance-policy=TERMINATE

別のマシンタイプを使用する
--------------------------

T2D 以外のマシンタイプは別の割り当てでカウントされるので、マシンタイプを変更する手もあります（例: c2-standard-4、c3-highcpu-4） ::

    MACHINE_TYPE=c2-standard-4

.. note:: Compute Optimized (C3) のマシンタイプは ``pd-standard`` のディスクと組み合わせられないようです。
   ``pd-balanced`` や ``pd-ssd`` といった、より新しい永続ディスクタイプを指定してください

       ::

           ERROR: (gcloud.compute.instances.create) Could not fetch resource:
            1. [pd-standard] features and [instance_type: VIRTUAL_MACHINE
           family: COMPUTE_OPTIMIZED
           generation: GEN_3
           cpu_vendor: INTEL
           architecture: X86_64
           ] InstanceTaxonomies are not compatible for creating instance.

割り当ての引き上げを申請する
----------------------------

#. Google Cloud コンソールの [IAM と管理] > [割り当て] に移動する
#. 「T2D_CPUS」を検索する
#. 該当する割り当てを選択し、[制限を編集] をクリックする
#. 必要な値への引き上げを申請する

Google による審査後（筆者の場合は1営業日程度でした）、承認されれば利用できるようになります

複製したインスタンスで認証に失敗する場合
========================================

同じマシンイメージから作成した4台のインスタンスを起動して参加しようとすると、認証失敗で入れなくなる事象が再現できました。

まず気になったのが :command:`hostnamectl` で表示される Machine ID で、複製した4台とも同じ値になっていました ::

    hostnamectl
    # 出力例（複製元・複製先とも同じ値になっている）
    # Machine ID: 9791f922163f4d3688c0cad7aa903ef8

複製したインスタンスでは、machine-id を削除して生成し直しておきます ::

    # machine-id ファイルを削除して、新しい machine-id を生成する
    sudo rm /etc/machine-id && sudo systemd-machine-id-setup

そのうえで、ヘッドレスサーバ_ を停止して ``Resonite_Data`` を削除し、起動し直します ::

    sudo systemctl stop resonite-headless.service && \
    rm -rf ${HOME}/.local/share/Steam/steamapps/common/Resonite/Resonite_Data && \
    sudo systemctl start resonite-headless.service

筆者の環境では、上記のコマンドを1回ずつ打ったところ4台中3台は参加できるようになり、
残りの1台も再度コマンドを打って参加をリトライしていたら、そのうち入れるようになりました。

.. note:: サービスの状態確認・操作は下記の通りです

       ::

           systemctl status resonite-headless.service
           sudo systemctl restart resonite-headless.service
           sudo systemctl stop resonite-headless.service
           sudo systemctl start resonite-headless.service


:ref:`明日の記事 <check_the_price_and_choose_an_instance>` へ続きます。

.. include:: /contents/include_files/resonite_headless_link.txt

