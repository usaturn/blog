.. post:: 2016-12-12
   :tags: Gentoo, Linux
   :category: Linux
   :author: usaturn
   :location: Japan
   :language: ja

===================================
Gentoo に systemd-nspawn を導入する
===================================

この記事は `Gentoo Advent Calendar 2016 <http://www.adventar.org/calendars/1493#list-2016-12-12>`_ の記事です。

はじめに
========

systemd-nspawn は systemd 標準で使えるコンテナ環境です。筆者にとって Gentoo を sysytemd で使うメリットの半分以上を占めていると言っても過言ではありません。
前日のアドベントカレンダーは systemd-nspawn を快適に使う為の Gentoo インストール手順になっています。注意する所は主に 2 点です。

- systemd の USE フラグで *importd* を有効にする
- ファイルシステムに btrfs を使う

今日は systemd-nspawn のコンテナを作成する手順を記載します。

事前準備
========
systemd の USE フラグを nspawn の import 機能を使えるように USE フラグを設定しコンパイルし直す ::

    echo "sys-apps/systemd gnuefi importd  curl gcrypt  http lzma" > /etc/portage/package.use/systemd
    emerge -avt sys-apps/systemd


カーネルで下記を組み込むようビルドする ::

   CONFIG_VETH=y
   CONFIG_MACVLAN=y
   CONFIG_MACVTAP=y

``/var/lib/machines`` が btrfs の領域になるようマウントする


コンテナのセットアップ
======================
systemd-nspawn はデフォルトで ``/var/lib/machines`` 直下のディレクトリを参照します。
ここに stage3 ダウンロードしコンテナをセットアップします・

カレントを変更 ::

    cd /var/lib/machines


最新の stage3 のアーカイブをダウンロード、展開する ::

    MIRROR='ftp://ftp.iij.ad.jp/pub/linux/gentoo/';
    STAGE3=${MIRROR}/releases/amd64/autobuilds/$(curl -L ${MIRROR}/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt -s | awk '!/^\s*(#|$)/{print $1}');
    curl -LO ${STAGE3}.DIGESTS;
    curl -LO ${STAGE3};
    sha512sum -c *.DIGESTS;
    tar xpf stage3-*.tar.bz2 -C gbase;

gbase という名前のコンテナを作成する ::

    # 書式 machinectl import-tar [ファイル名] [コンテナ名]
    # 例 machinectl import-tar  stage3-amd64-systemd-20161118.tar.bz2 gbase

サブボリュームができた事を btrfs コマンドで確認 ::

    btrfs subvolume list /var/lib/machines

作成したディレクトリが認識されているかを確認 ::

    machinectl list-images
    machinectl image-status gbase

コンテナに chroot してパスワードを設定する ::

    systemd-nspawn -D /var/lib/machines/gbase
    passwd
    exit

今回作成するコンテナを起動する ::

    # 起動
    machinectl start gbase

    # 起動している事を確認
    machinectl status gbase

起動したコンテナにログインできる事を確認する ::

    machinectl login gbase
    # ログインできる事を確認したら Ctrl + ]]] で抜ける

    # コンテナをパワーオフする
    machinectl poweroff gbase

コンテナを OS のスタートアップに追加する場合は下記コマンドを打つ ::

    # systemd-nspawn のコンテナ自動起動を設定する
    systemctl start machines.target
    systemctl status machines.target
    systemctl enable machines.target

    # 対象のコンテナを指定する
    machinectl enable gbase

インターフェース設定
--------------------
コンテナ外部とネットワーク接続する為、コンテナのテンプレートユニットを書き換えてインターフェースを設定する

テンプレートユニットファイルの書き換え ::

   cp -ip /usr/lib64/systemd/system/systemd-nspawn@.service /etc/systemd/system
   vim /etc/systemd/system/systemd-nspawn@.service

      # インターフェース名はホストのインターフェースに合わせる事
      -ExecStart=/usr/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --network-veth --settings=override --machine=%I
      +ExecStart=/usr/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --network-macvlan=eno1 --bind=/usr/portage:/usr/portage --settings=override --machine=%I

コンテナを起動する ::

   systemctl daemon-reload
   machinectl start gbase


systemd-nspawn の引数が変更された事を確認する ::

   machinectl status gbase
   # supervisor の下の行に起動時のコマンドラインが表示される


ログインしてインターフェースが割り当てられた事を確認する ::

   machinectl login gbase

   # ip コマンドで確認する
   ip a

    # 表示例: mv-eno1@if2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1
    # mv-enp2s0 がインターフェース名である事がわかる

コンテナをパワーオフする ::

    machinectl poweroff gbase

ホストから systemd-networkd のインターフェースの設定ファイルを作成する ::

   vim /var/lib/machines/gbase/etc/systemd/network/mv-eno1.network

固定 IP アドレスを割り当てる場合 ::

   [Match]
   Name=mv-eno1

   [Network]
   DHCP=no
   DNS=10.16.128.1
   Domains=xlisting.local
   NTP=10.16.128.1

   [Address]
   Address=10.16.128.xxx/24
   Broadcast=10.16.128.255

   [Route]
   Gateway=10.16.128.254

DHCP で割り当てる場合 ::

   [Match]
   Name=mv-eno1

   [Network]
   DHCP=yes

コンテナにログインし IP アドレスが割り当てられた事を確認する ::

    machinctl start gbase
    systemctl status systemd-networkd
    ip a

ネットワークデーモンをスタートアップに追加する ::

    systemctl enable {systemd-networkd.service,systemd-resolved.service}

ステータスの確認 ::

    networkctl -a
    networkctl status mv-eno1

make.confの設定
---------------
コンパイルオプションの設定とミラーサイトの選択を記述する

エディタで編集をする ::

   nano /etc/portage/make.conf

お好みで ::

      # 例
      # -pipe はメモリを使ってコンパイル時間を短縮する
      CFLAGS="-march=native -O2 -pipe"
      CXXFLAGS="${CFLAGS}"
      # コア数 + 1 程度
      MAKEOPTS="-j12"
      # USEフラグ
      USE="mmx sse sse2 cjk unicode nptl nptlonly threads nls systemd"
      USE="${USE} acpi dbus hal xml pam nis nfs"
      USE="${USE} -bindist -alsa -cups -gnome -gtk -kde -oss -perl -qt3 -qt4 -ruby -X"

      LINGUAS="ja"
      GENTOO_MIRRORS="ftp://ftp.iij.ad.jp/pub/linux/gentoo/ ftp://ftp.jaist.ac.jp/pub/Linux/Gentoo/"

      # portage log
      PORT_LOGDIR="/var/log/portage"
      PORTAGE_ELOG_CLASSES="warn error log"
      PORTAGE_ELOG_SYSTEM="save"


portage のシンク先の設定
------------------------
gentoo.confの編集 ::

    mkdir /etc/portage/repos.conf
    vim /etc/portage/repos.conf/gentoo.conf

::

    [DEFAULT]
    main-repo = gentoo
    [gentoo]
    location = /usr/portage
    sync-type = rsync
    sync-uri=rsync://rsync.jp.gentoo.org/gentoo-portage
    auto-sync = yes


パッケージのコンパイルし直し
----------------------------
::

    emerge -avDN @world
    emerge --depclean


sshd 有効化
-----------
::

    systemctl enable sshd
        Created symlink from /etc/systemd/system/multi-user.target.wants/sshd.service to /usr/lib64/systemd/system/sshd.service.

.. note:: 本手順ではインターフェースに macvlan を利用している為、ホスト環境からコンテナのインターフェースには接続できません。
          よって ssh 接続をする際は別のマシンからから接続して下さい。


fstab の中身の消去
------------------
::

   echo "" > /etc/fstab

ロケールの設定
--------------
::

    # 使用可能なロケール一覧を確認する
    localectl list-locales
    # ja_JP.utf8 を指定
    localectl set-locale LANG=ja_JP.utf8

キー配列の指定 ::

  localectl set-keymap jp106

確認 ::

  localectl status


時刻の設定
----------
タイムゾーンを Tokyo にする ::

  timedatectl set-timezone Asia/Tokyo

Tokyo になった事を確認。また、RTC(hwclock)が UTC と同じ時刻である事を確認 ::

  timedatectl status


時刻同期の設定
--------------
systemd-timesyncd を有効にする。インターフェース設定に記述したものが使われる。 ::

    systemctl start systemd-timesyncd.service
    systemctl status systemd-timesyncd.service
    systemctl enable systemd-timesyncd.service

    # 時刻の確認
    timedatectl status
    date

その他パッケージインストール
----------------------------
システムユーティリティ一括インストール ::

  echo "app-misc/tmux vim-syntax" > /etc/portage/package.use/tmux
  emerge -avt app-portage/gentoolkit net-dns/bind-tools sys-apps/dstat app-portage/eix app-shells/zsh dev-vcs/rcs app-misc/tmux

eix のインデックス作成 ::

   eix-update

設定完了後の確認
----------------
リブート ::

    poweroff
    machinectl start gbase
    machinectl login gbase
    # 注意: 本手順では reboot コマンドを実行すると poweroff と同じ結果になる

インストールしたパッケージの確認 ::

  eix -cI --selected


以上で systemd-nspawn のコンテナ作成は完了です。明日は systemd-nspawn コマンドの使い方や便利な設定を紹介します。




