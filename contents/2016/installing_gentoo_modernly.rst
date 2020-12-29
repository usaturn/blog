.. post:: 2016-12-11
   :tags: Gentoo, Linux
   :category: Linux
   :author: usaturn
   :location: Japan
   :language: ja

=================================================
Gentoo Linux を sysytemd でインストールする（裏）
=================================================


概要
====
Gentoo のインストールに慣れている人向けに、筆者の手順を紹介します。
下記環境で決め打ち ＆ プライベートネットワーク内サーバのベースを想定してます。

    UEFI + GPT + SSD + btrfs + systemd

あまり一般的ではない所は、sysvinit & openrc を削除する部分とブートローダを使わない所でしょうか。

インストールの準備をする
========================

インストールメディアは `SystemRescueCd <http://www.sysresccd.org/Download>`_ を使用する。

BIOSで該当のメディアがブートされるように設定し、インストールメディアをセットしブートする

   .. figure:: images/srcd/srcd01.png
      :width: 400

      altanative kernel を選択

キーボードの選択

   .. figure:: images/srcd/srcd02.png
      :width: 400

      日本語キーボードは 22

対話シェルが起動した状態

   .. figure:: images/srcd/srcd03.png
      :width: 400

DHCP 環境の場合は下記コマンドでIPアドレスが割り当てられた事を確認する

::

   ip a

固定IPアドレスを振る例 ::

    # インターフェース名とIPアドレスは環境に合わせて置き換える
    ip link set dev eno1 up
    ip addr add 10.16.128.77/24 broadcast 10.16.128.255 dev eno1
    ip route add default via 10.16.128.254

リモートからsshで接続してインストール作業を実施する為、コンソールよりsshdの起動とrootパスワードの設定をする

::

   passwd
   # 任意のパスワード aaa等を入力

::

   # sshd が起動していない場合は起動する
   /etc/init.d/sshd start

   # 起動確認
   pgrep -l sshd

コンソールで上記設定ができたら、リモートより SSH 接続をする

ディスクの確認
==============
::

    lsblk -f
    blkid

パーティション設定 (GPT+UEFI)
=============================
先にコマンドで調べたストレージデバイスにパーティション、ファイルシステムを作成する。

gdiskコマンドを利用する ::

    # /dev/sdaに作成する例
    gdisk /dev/sda

        GPT fdisk (gdisk) version 1.0.0

        The protective MBR's 0xEE partition is oversized! Auto-repairing.

        Partition table scan:
          MBR: protective
          BSD: not present
          APM: not present
          GPT: present

        Found valid GPT with protective MBR; using GPT.

        Command (? for help):p ※pで現在のパーティション状況を表示

        Command (? for help): d ※不要なパーティションを削除する例
        Partition number (1-6): 1

        Command (? for help): o ※全てのパーティションを削除しGPTのパーティションテーブルを作成
        This option deletes all partitions and creates a new protective MBR.
        Proceed? (Y/N): y

        Command (? for help): n ※ESP(EFI System Partition)を作成する
        Partition number (1-128, default 1):
        First sector (34-500118158, default = 2048) or {+-}size{KMGTP}:
        Last sector (2048-500118158, default = 500118158) or {+-}size{KMGTP}: +512M
        Current type is 'Linux filesystem'
        Hex code or GUID (L to show codes, Enter = 8300): EF00
        Changed type of partition to 'EFI System'

        Command (? for help): n
        Partition number (3-128, default 3):
        First sector (34-500118158, default = 34605056) or {+-}size{KMGTP}:
        Last sector (34605056-500118158, default = 500118158) or {+-}size{KMGTP}: +20G ※ルートとして標準の「Linux filesystem」に割り当てる。
        Current type is 'Linux filesystem'
        Hex code or GUID (L to show codes, Enter = 8300):
        Changed type of partition to 'Linux filesystem'

        Command (? for help): p ※ 確認

        Command (? for help): w ※ 変更を書き込んで終了

        Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
        PARTITIONS!!

        Do you want to proceed? (Y/N): y
        OK; writing new GUID partition table (GPT) to /dev/sda.
        The operation has completed successfully.

ESPのフォーマット ::

    mkfs.vfat -F32 /dev/sda1

ルート領域をbtrfsでフォーマット ::

    mkfs.btrfs -f -L root /dev/sda2

        Detected a SSD, turning off metadata duplication.  Mkfs with -m dup if you want to force metadata duplication.
        btrfs-progs v4.2.2
        See http://btrfs.wiki.kernel.org for more information.

        Performing full device TRIM (20.00GiB) ...
        Label:              root
        UUID:               950dc1ea-feef-4ec8-9642-392bff95d977
        Node size:          16384
        Sector size:        4096
        Filesystem size:    20.00GiB
        Block group profiles:
          Data:             single            8.00MiB
          Metadata:         single            8.00MiB
          System:           single            4.00MiB
        SSD detected:       yes
        Incompat features:  extref, skinny-metadata
        Number of devices:  1
        Devices:
           ID        SIZE  PATH
            1    20.00GiB  /dev/sda3

ディスクのマウント
==================
::

    # btrfs のサブボリュームを作成する
    mkdir -p /mnt/btrfs
    mount /dev/sda2 /mnt/btrfs
    cd /mnt/btrfs

    btrfs subvolume create gentoo
    btrfs subvolume create usr-portage
    btrfs subvolume create var-log

    # ルート→サブボリューム→bootの順にマウントする
    mount -odefaults,subvol=gentoo,compress=lzo,ssd_spread /dev/sda2 /mnt/gentoo

    cd /mnt/gentoo
    mkdir -p usr/portage var/log
    mount -odefaults,subvol=usr-portage,compress=lzo,ssd_spread /dev/sda2 usr/portage
    mount -odefaults,subvol=var-log,compress=lzo,ssd_spread /dev/sda2 var/log
    mkdir -p /mnt/gentoo/boot
    mount /dev/sda1 /mnt/gentoo/boot

    # 確認
    btrfs filesystem show
    btrfs sub list /mnt/gentoo

マウントの状態とルートのディスク容量を確認 ::

    df -hT
    btrfs filesystem df /mnt/gentoo
    # 意図しないサイズの場合、リブートをしてサイズが意図通りになる事がある

インストール用ファイル準備
==========================

作業領域にカレントを移し、最新のstage3のアーカイブをダウンロード、展開する ::

    cd /mnt/gentoo
    MIRROR='ftp://ftp.iij.ad.jp/pub/linux/gentoo/';
    STAGE3=${MIRROR}/releases/amd64/autobuilds/$(curl -L ${MIRROR}/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt -s | awk '!/^\s*(#|$)/{print $1}');
    curl -LO ${STAGE3}.DIGESTS;
    curl -LO ${STAGE3};
    STAGE3_FILENAME=$(echo ${STAGE3}|awk -F/ '{print $NF}')
    RIGHT_HASH_VALUE=$(awk -v STAGE3_FILENAME=$STAGE3_FILENAME '/SHA512 HASH/{FLAG=1} $2==STAGE3_FILENAME {if(FLAG==1){ print; FLAG=0}}'  $STAGE3_FILENAME.DIGESTS)
    HASH_VALUE=$(sha512sum $STAGE3_FILENAME)
    [ "$HASH_VALUE" = "$RIGHT_HASH_VALUE" ] && echo OK
    tar xfp $STAGE3_FILENAME;

Portageスナップショットをダウンロードし、インストール

::

   cd /mnt/gentoo
   wget http://ftp.iij.ad.jp/pub/linux/gentoo/releases/snapshots/current/portage-latest.tar.bz2.md5sum
   wget http://ftp.iij.ad.jp/pub/linux/gentoo/releases/snapshots/current/portage-latest.tar.bz2
   md5sum -c portage-latest.tar.bz2.md5sum
   tar xf /mnt/gentoo/portage-latest.tar.bz2 -C /mnt/gentoo/usr

make.confの設定
===============
コンパイルオプションの設定とミラーサイトの選択を記述する

エディタで編集をする ::

   vim /mnt/gentoo/etc/portage/make.conf

お好みで ::

      CFLAGS="-march=native -O2 -pipe"
      CXXFLAGS="${CFLAGS}"
      # コア数 + 1 程度
      MAKEOPTS="-j9"
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
========================
gentoo.confの編集 ::

    mkdir /mnt/gentoo/etc/portage/repos.conf
    vim /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

::

    [DEFAULT]
    main-repo = gentoo
    [gentoo]
    location = /usr/portage
    sync-type = rsync
    sync-uri=rsync://rsync.jp.gentoo.org/gentoo-portage
    auto-sync = yes


DNS情報のコピー
===============
::

   cp -L /etc/resolv.conf /mnt/gentoo/etc/
   # 固定 IP アドレスを振っている場合は手動で編集

システムパーティションのマウント
================================
::

   mount -t proc none /mnt/gentoo/proc
   mount --rbind /sys /mnt/gentoo/sys
   mount --make-rslave /mnt/gentoo/sys
   mount --rbind /dev /mnt/gentoo/dev
   mount --make-rslave /mnt/gentoo/dev

chrootする
===========
::

  cd /mnt/gentoo && chroot /mnt/gentoo /bin/bash
  source /etc/profile && export PS1="(chroot) $PS1"


Vimのインストール
=================
インストール中の作業用に Vim をインストールする ::

   mkdir /etc/portage/package.use
   echo app-editors/vim python vim-pager lua luajit >> /etc/portage/package.use/vim
   emerge -avt app-editors/vim
   echo "set paste" > ~/.vimrc

デバイス確認系のツールをインストール
====================================
:ethtool: sys-apps/ethtool
:lspci, lsmod: pciutils
:lshw: sys-apps/lshw

まとめてインストール ::

   emerge -avt sys-apps/ethtool sys-apps/pciutils sys-apps/lshw

各種情報を出力し、メモをしておく ::

    lspci -k
    lsmod
    lshw -short

カーネルソースをインストール
============================
::

    echo "sys-kernel/gentoo-sources symlink"> /etc/portage/package.use/gentoo
    mkdir -p /etc/portage/package.keywords
    echo "sys-kernel/gentoo-sources ~amd64" > /etc/portage/package.keywords/gentoo
    emerge -avt gentoo-sources
    ls -l /usr/src


カーネル構成設定
================
::

  cd /usr/src/linux
  make menuconfig

.. literalinclude:: kernel_parameter.txt

カーネルをインストールする
==========================
カーネルconfigが終わったらコンパイル、インストールを実施する ::

  make && make modules_install
  make install

  # initramfs？モジュール読み込み？面倒だから全部組み込みで！

systemd の適用
==============

システムが systemd を使うように設定変更 ::

    # default/linux/amd64/13.0/systemd が選択されている事を確認
    eselect profile list

    # 例
        [12]  default/linux/amd64/13.0/systemd *

openrc と sysvinit を削除する ::

    emerge -C sys-apps/sysvinit sys-apps/openrc

systemd 関連の USE フラグを変更する ::

    mkdir /etc/portage/package.use
    echo "sys-apps/systemd gnuefi importd curl lzma gcrypt sysv-utils" > /etc/portage/package.use/systemd
    mkdir /etc/portage/package.keywords
    echo "sys-apps/systemd ~amd64" > /etc/portage/package.keywords/systemd
    echo "sys-apps/util-linux ~amd64" >> /etc/portage/package.keywords/systemd
    echo "sys-libs/libseccomp ~amd64" >> /etc/portage/package.keywords/systemd

Python に sqlite の USEフラグ を付ける ::

   echo "dev-lang/python sqlite gdbm ipv6 ncurses readline ssl threads xml" >> /etc/portage/package.use/python
   mkdir /etc/portage/package.keywords
   echo "dev-lang/python ~amd64" >> /etc/portage/package.keywords/python

パッケージのコンパイルし直し ::

    emerge -avDN @world
    emerge --depclean

fstabの修正
===========
エディタで編集する ::

  vim /etc/fstab

例 ::

    /dev/sda1                /boot             vfat    defaults,noatime                                                        1 2
    /dev/sda2                /                 btrfs   defaults,noatime,subvol=gentoo,compress=lzo,ssd_spread,space_cache      0 1
    /dev/sda2                /usr/portage      btrfs   defaults,noatime,subvol=usr-portage,compress=lzo,ssd_spread,space_cache 0 1
    /dev/sda2                /var/log          btrfs   defaults,noatime,subvol=var-log,compress=lzo,ssd_spread,space_cache     0 1

ネットワーク設定
================

固定IPアドレス割り当て ::

    vim /etc/systemd/network/eno1.network

        [Match]
        Name=eno1
        Virtualization=no

        [Network]
        DHCP=no
        DNS=10.16.128.1
        Domains=usaturn.local
        NTP=10.16.128.1

        [Address]
        Address=10.16.128.77
        Broadcast=10.16.128.255

        [Route]
        Gateway=10.16.128.254

ネットワークデーモンをスタートアップに追加する ::

    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service

ステータスの確認 ::

    networkctl -a
    networkctl status eno1

sshdの設定
==========
とりあえず内部ネットワーク用にゆるく設定しとく ::

  vim /etc/ssh/sshd_config
    PermitRootLogin yes         # rootログイン
    UsePAM yes
    PasswordAuthentication yes  # パスワードログイン許可
    RSAAuthentication no        # ssh v1 不可
    PubkeyAuthentication yes    # ssh v2 許可

sshd 有効化 ::

    systemctl enable sshd
        Created symlink from /etc/systemd/system/multi-user.target.wants/sshd.service to /usr/lib64/systemd/system/sshd.service.

rootのパスワードの設定
======================
::

   passwd

必要なパッケージをインストールする
==================================
ファイルシステムに *btrfs* を利用している場合は専用パッケージが必要 ::

   emerge -avt sys-fs/btrfs-progs

マイクロコードのアップデート ::

   emerge -avt sys-kernel/linux-firmware

ブート設定
==========
::

    bootctl --path=/boot install
        Copied "/usr/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/systemd/systemd-bootx64.efi".
        Copied "/usr/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/Boot/BOOTX64.EFI".
        Created EFI boot entry "Linux Boot Manager".

efibootmgr のインストール ::

    emerge -avt sys-boot/efibootmgr

エントリの確認 ::

    efibootmgr -v

uefi 変数がカーネルでサポートされていて正しく動作していることを確認する ::

    efivar -l

ブートローダ(grub, systemd-boot)を使わずに UEFI に直接カーネルを読ませるエントリを追加する ::

           NEWVMLINUZ=$(ls -lt /boot|awk '/vmlinuz/{print $NF}'|head -1)
           VERSION=$(echo $NEWVMLINUZ|awk 'BEGIN{FS="-"}{print $2}')
           PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2)
           efibootmgr -d /dev/sda -p 1 -c -L "Gentoo ${VERSION}/GNU Linux" -l /${NEWVMLINUZ} -u "root=PARTUUID=${PARTUUID} rw reboot=warm"
           # systemd の USE フラグに sysv-utils を使っている場合 はカーネルパラメータに init=/usr/lib/systemd/systemd reboot=warm" は不要

.. note:: efibootmgr のその他使い方

          ::

              ブート順の設定例 ::

                  efibootmgr -o 0007,0004,0000,0002,000A,0001,0003,0008,0009,0005,0006

              UEFI エントリ削除 ::

                  efibootmgr -b 0007 -B

システムの再起動
================
再起動をするが、再起動する前にchrootを抜けmountした領域を外す必要がある

::

   exit
   cd
   umount -l /mnt/gentoo/dev{/shm,/pts,}
   umount /mnt/gentoo{/boot,/sys,/proc,}

再起動を実施する ::

   reboot

.. note:: 再起動後に問題があった場合 SystemRescueCd で chroot する所までのコマンド

   ::

         mount /dev/sda2 /mnt/gentoo
         mkdir -p /mnt/gentoo/boot
         mount /dev/sda1 /mnt/gentoo/boot
         mount -t proc none /mnt/gentoo/proc
         mount --rbind /sys /mnt/gentoo/sys
         mount --make-rslave /mnt/gentoo/sys
         mount --rbind /dev /mnt/gentoo/dev
         mount --make-rslave /mnt/gentoo/dev
         cd /mnt/gentoo && chroot /mnt/gentoo /bin/bash
         env-update
         source /etc/profile && export PS1="(chroot) $PS1"

名前解決の設定
==============
``/etc/resolv.conf`` をインターフェース設定で生成される resolv.conf のシンボリックリンクにする ::

    rm /etc/resolv.conf
    ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

ホスト名の設定
==============
::

    # hostnamectl set-hostname <HOSTNAME>
    # /etc/hostname に書き込まれる
    # FQDNは使わない。FQDNはhostsに書く
    # 例
    hostnamectl set-hostname afxw

    # 確認
    hostnamectl

ロケールの設定
==============
ロケールの指定 ::

    # 使用可能なロケール一覧を確認する
    localectl list-locales
    # ja_JP.utf8 を指定
    localectl set-locale LANG=ja_JP.utf8

キー配列の指定 ::

  localectl set-keymap jp106

確認 ::

  localectl

時刻の設定
==========
タイムゾーンを Tokyo にする ::

  timedatectl set-timezone Asia/Tokyo

Tokyo になった事を確認。また、RTC(hwclock)が UTC と同じ時刻である事を確認 ::

  timedatectl status

時刻同期の設定
==============
systemd-timesyncd を有効にする。インターフェース設定に記述したものが使われる。 ::

    systemctl start systemd-timesyncd.service
    systemctl status systemd-timesyncd.service
    systemctl enable systemd-timesyncd.service

    # 時刻の確認
    timedatectl status
    date

デフォルトエディタの設定
========================
profile を編集する ::

    vim /etc/profile

      EDITOR=/usr/bin/vim
      export EDITOR=${EDITOR:-/bin/nano} # この行の上に追加

ドットコマンドで profile を読み込む ::

    . /etc/profile

sudoの設定
==========
::

  echo "app-admin/sudo -sendmail" >> /etc/portage/package.use/sudo
  emerge -avt app-admin/sudo

  visudo
    %wheel ALL=(ALL) ALL

その他パッケージインストール
============================
システムユーティリティ一括インストール ::


  echo "app-misc/tmux vim-syntax" > /etc/portage/package.use/tmux
  emerge -avt app-portage/gentoolkit net-dns/bind-tools sys-apps/dstat app-portage/pfl sys-apps/gptfdisk sys-apps/the_silver_searcher app-portage/eix app-shells/zsh dev-vcs/rcs app-misc/tmux

eix のインデックス作成 ::

  eix-update

設定完了後の確認
================
リブート ::

    systemctl reboot

インストールしたパッケージの確認 ::

  eix -cI --selected

スタートアップの確認 ::

    systemctl list-unit-files|grep enabled

eix-sync の定期実行
=====================
eix-sync を実行するユニット *eixsync.service* を作成する ::

    vim /etc/systemd/system/eixsync.service

        [Unit]
        Description=execute eix-sync

        [Service]
        Type=simple
        ExecStart=/usr/bin/eix-sync
        RemainAfterExit=no


*eixsync.service* が正常に実行できる事を確認する ::

    # 実行
    systemctl start eixsync.service

    # ログの確認
    systemctl status eixsync.service
    journalctl -f -u eixsync

timer ユニットを作成する ::

    vim /etc/systemd/system/eixsync.timer

        # 毎朝 9 時に eixsync.service を実行する
        [Unit]
        Description=execute eix-sync

        [Timer]
        OnCalendar=*-*-* 9:30:00
        Unit=eixsync.service

        [Install]
        WantedBy=multi-user.target

*eixsync.timer* を有効にする ::

    systemctl daemon-reload
    systemctl start eixsync.timer
    systemctl status eixsync.timer
    systemctl enable eixsync.timer

timer ユニット一覧を確認する ::

    systemctl list-unit-files -t timer
    systemctl list-timers

SSD の場合に実施する設定
========================
fstrim コマンドを定期的に実行する ::

    systemctl start fstrim.timer
    systemctl status fstrim.timer
    systemctl enable fstrim.timer

    # timer ユニット一覧の確認
    systemctl list-unit-files -t timer

