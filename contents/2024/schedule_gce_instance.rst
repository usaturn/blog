.. post:: 2024-12-07
   :tags: Ubuntu, Linux, Resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _schedule_gce_instance:

==========================================
GCE インスタンスのスケジュール設定をしよう
==========================================

`(2枚目) Resonite Advent Calendar 2024 <https://adventar.org/calendars/10544>`__ 7日目の記事です

resonite の ヘッドレスサーバ_ を必要な時にだけ自動起動／自動停止する手順です。

前提条件
========

:ref:`こちらでセットアップした <setup_cloud_shell>` `Google Cloud Shell`_ を利用して `Google Cloud`_ をコマンドラインから操作します。

インフラ設定用の環境変数を設定する
==================================

環境変数を読み込み、出力結果が正しいことを確認します（空欄がなければ良いです） ::

    reso

インスタンスを自動起動、自動停止する
====================================

Google Cloud のリファレンス「 `VM インスタンスの起動と停止をスケジュールする <https://cloud.google.com/compute/docs/instances/schedule-instance-start-stop?hl=ja>`__ 」を参考にしてください。

Compute Engine サービスエージェントに、権限を付与する
-----------------------------------------------------

Compute Engine のサービスエージェントに roles/compute.instanceAdmin.v1 を付与する必要がある

プロジェクトIDを変数にします ::

    PROJECT_ID=$(gcloud config list --format="value(core.project)")

プロジェクトナンバーを変数にする ::

    PROJECT_NUMBER=$(gcloud projects list --filter="projectId=${PROJECT_ID}" --format="value(projectNumber)")

Compute Engine のサービスエージェント名を変数にします ::

    COMPUTE_ENGINE_SERVICE_AGENT=service-${PROJECT_NUMBER}@compute-system.iam.gserviceaccount.com

ロール ``roles/compute.instanceAdmin.v1`` を Compute Engine のサービスエージェントに付与します ::

    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${COMPUTE_ENGINE_SERVICE_AGENT}" --role="roles/compute.instanceAdmin.v1"

インスタンススケジュールを作成する
----------------------------------

スケジュール名を変数に入れます（任意） ::

    SCHEDULE_NAME=kakko

スケジュールを作成します ::

    # 例: 火曜日の 20:30 に起動して、毎日 0:00 に停止する
    gcloud compute resource-policies create instance-schedule ${SCHEDULE_NAME} \
        --region=${REGION} \
        --vm-start-schedule='30 20 * * TUE' \
        --vm-stop-schedule='0 0 * * *' \
        --timezone=Japan

スケジュール一覧を出力します ::

    gcloud compute resource-policies list

スケジュールを削除する ::

    gcloud compute resource-policies delete ${SCHEDULE_NAME} --region=${REGION}

インスタンススケジュールをインスタンスに付与する ::

    # インスタンス名を変数に入れる
    RESONITE_HEADLESS_SERVER_INSTANCE_NAME=$(gcloud compute instances list --format="value(name)"|fzf)

    # インスタンススケジュールを付与する
    gcloud compute instances add-resource-policies ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} --resource-policies=${SCHEDULE_NAME}

    # 外す
    gcloud compute instances remove-resource-policies ${RESONITE_HEADLESS_SERVER_INSTANCE_NAME} --resource-policies=${SCHEDULE_NAME}

    # インスタンス一覧（スケジュール表示）
    gcloud compute instances list --format="table(name, resourcePolicies[0].basename(), zone, machineType, scheduling.preemptible, networkInterfaces[].accessConfigs[natIP], status)"

以上

:ref:`明日の記事 <clone_a_headless_server_instance>` へ続きます。

.. include:: /contents/include_files/resonite_headless_link.txt

