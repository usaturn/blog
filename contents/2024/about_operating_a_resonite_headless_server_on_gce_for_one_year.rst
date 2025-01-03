.. post::
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja



.. _about_operating_a_resonite_headless_server_on_gce_for_one_year:

================================================================================
Google Cloud Compute Engine で resonite ヘッドレスサーバを運用しての感想（駄文）
================================================================================

**未完**

- アップデートできなかった

  - steamcmd でアップデートできない事がある。何回かアップデートを繰り返すとうまくいく（原因不明）
  - 空き容量がない

    - キャッシュ削除: ${HOME}/.local/share/Steam/steamapps/common/Resonite/Headless/Cache/Cache
    - インスタンスの空き容量監視

- resonite ネットワークに繋がらなかった

  - 原因不明。同じタイミングで他の人も自宅ヘッドレスを起動しても入れなかった

- 指定したインスタンスタイプが、Google 側のリソース不足で起動できなかった
- 起動しっぱなしを防ぐために、 shutdown ユニット作る
- 肌感で Linux 版は Windows 版より不安定
- 費用感と料金の確認方法
- インスタンスの選び方

