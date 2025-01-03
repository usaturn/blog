.. post:: 2016-12-13
   :tags: Gentoo, Linux, container
   :category: Linux
   :author: usaturn
   :location: Japan
   :language: ja

=====================================
systemd-nspawn コンテナを便利に使おう
=====================================



eix-update の定期実行
=====================
eix-update を実行するユニット *eixupdate.service* を作成する ::

    vim /etc/systemd/system/eixupdate.service

        [Unit]
        Description=execute eix-update

        [Service]
        Type=simple
        ExecStart=/usr/bin/eix-update
        RemainAfterExit=no


*eixupdate.service* が正常に実行できる事を確認する ::

    # 実行
    systemctl start eixupdate.service

    # ログの確認
    systemctl status eixupdate.service
    journalctl -f -u eixupdate

timer ユニットを作成する ::

    vim /etc/systemd/system/eixupdate.timer

        # 毎朝 9 時に eixupdate.service を実行する
        [Unit]
        Description=execute eix-update

        [Timer]
        OnCalendar=*-*-* 9:30:00
        Unit=eixupdate.service

        [Install]
        WantedBy=multi-user.target

*eixupdate.timer* を有効にする ::

    systemctl daemon-reload
    systemctl start eixupdate.timer
    systemctl status eixupdate.timer
    systemctl enable eixupdate.timer

timer ユニット一覧を確認する ::

    systemctl list-unit-files -t timer
    systemctl list-timers







Appendix


.. note:: reboot ができない対処

          ``--keep-unit`` オプションは machinectl コマンドで制御する為に必要だが使うと reboot コマンドを打つと shutdown されてしまう。
          これを回避する為には対象のコンテナについては専用 Unit を書き machinectl を使わずに制御する。



個別設定のユニットを作りたい場合はスタートアップに追加した時に作られるユニットをコピーする ::

    cp -ip /etc/systemd/system/machines.target.wants/systemd-nspawn@mailbase.service /etc/systemd/system/container-mailbase.service
    # %I をコンテナ名に書き換え、ExecStart 等を追加、変更する
    vim container-mailbase.service
    # 起動を確認
    systemctl daemon-reload
    systemctl status container-mailbase.service
    systemctl start container-mailbase.service




コマンド一覧
============

コンテナの起動停止 ::

    machinectl start gbase
    machinectl poweroff
    # machinectl reboot
    # machinectl terminate
    # machinectl kill

コンテナのスタートアップ ::

    machinectl enable gbase
    machinectl disable gbase

その他 ::

    machinectl copy-to
    machinectl copy-from
    machinectl bind

稼働中のコンテナの確認 ::

    machinectl list
    machinectl status gbase
    machinectl show gbase

コンテナイメージの確認 ::

    machinectl list-images
    machinectl image-status
    machinectl show-image

コンテナイメージの複製 ::

    machinectl clone [From] [To]

コンテナイメージのリネーム、削除 ::

    machinectl rename [From] [To]
    machinectl remove [コンテナ名]

コンテナイメージの容量制限 ::

    machinectl set-limit

コンテナイメージのアーカイブ、展開 ::

    # アーカイブ
    machinectl export-tar --format=[gz, bzip2, xz] [コンテナ名] [ファイル名]
    # xz でマルチスレッド圧縮をする例 (一番お勧め！)
    maxz() { machinectl export-tar $1 $1.tar && nice -n 20 xz -z -f -T $(nproc) -vv $1.tar; }
    maxz gbase

    # インポート
    machinectl import-tar [ファイル名] [コンテナ名]

.. list-table::
   :header-rows: 1

   * - format
     - size
     - Compression speed
     - Expanding speed
   * - 無圧縮
     - 980305920
     - 00:06
     - 00:06
   * - gzip
     - 320368608
     - 00:34
     - 00:09
   * - bzip2
     - 279357808
     - 01:16
     - 00:31
   * - xz
     - 209442372
     - 04:39
     - 00:19
   * - xz(maxz)
     - 214837408
     - 01:10
     - 省略

Web サーバからイメージをダウンロードする ::

    # machinectl pull-tar [URL] [name]
    machinectl pull-tar --verify=no http://spica:8000/gbase.tar.gz gbase

    # pull の最中に Ctrl+C で処理をバックグラウンドにする事ができるが、バックグラウンドの処理を見たい時に実行する。
    machinectl list-transfers

    #ワンライナーで Web サーバ
    python3 -m http.server

コンテナイメージ操作 未調査 ::

    # machinectl export-raw
    # machinectl import-raw

.. 名前解決
       vim /etc/nsswitch.conf
       hosts: files mymachines resolve myhostname

本番用 Tips
===========
ディスククォータの設定 ::

    set-limit

- MemoryLimit ?

    ulimit -m

使用する CPU の固定 ::

    # Unit で cpuaffinity
    CPUAffinity=0 1 2 3

