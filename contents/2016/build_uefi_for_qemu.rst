.. post:: Sep 03, 2016
   :tags: KVM, Linux, QEMU
   :category: VIRTUAL
   :author: usaturn
   :location: Japan
   :language: ja

.. _build_uefi_for_qemu:

===========================================
QEMU の為の UEFI ファームウェアのビルド手順
===========================================


.. _OVMF.fd: http://www.tianocore.org/ovmf/

概要
====
仮想環境 KVM 上の VM で UEFI を利用したい場合は OSS の仮想マシン用 UEFI ファームウェア
`OVMF.fd`_ を使用する。

Webで公開されている `OVMF.fd`_ は 2014/02/10 の物で大変古い上にファームウェアと NVRAM が分離していない為に不便である。

ファームウェアの **OVMF_CODE.fd** と NVRAM の **OVMF_VARS.fd** に分離可能な最新版を使う為に
`GitHub の edk2 プロジェクトの最新版のソース <https://github.com/tianocore/edk2.git>`_ を
clone してビルドする。

下記は `Gentoo Linux <https://www.gentoo.org/>`_  の環境を使った手順である。


環境構築
========
gcc をアップデート、その他必要なパッケージを導入する。 ::

    emerge -uvt sys-devel/gcc
    gcc-config -l

    emerge -avt dev-lang/nasm
    emerge -avt sys-power/iasl

    # Git のインストール
    emerge -avt dev-vcs/git

    # python の USEフラグに sqlite が必要なので適宜リビルドする
    USE=sqlite emerge -avt python

ソースの入手
============
Github よりソースを clone する ::

    git clone https://github.com/tianocore/edk2.git

    # 2回目以降は clone せずに pull する
    git clean -fxd
    git pull

edk2 の環境設定
===============
OVMF をビルドする為の設定を実施する ::

    cd edk2
    make -C BaseTools
    source edksetup.sh

target.txt を書き換える  ::

    vim Conf/target.txt

        ACTIVE_PLATFORM       = OvmfPkg/OvmfPkgX64.dsc

        # gcc の表記はバージョンに合わせる
        TOOL_CHAIN_TAG        = GCC49

        TARGET_ARCH              = X64

ソースのビルド
==============
build コマンドを打ちソースをビルドする ::

    build

    # 成功した場合の表示例
    #    - Done -
    #    Build end time: 20:30:02, Sep.03 2016
    #    Build total time: 00:01:45


    # オプションを付けてビルドする事も可能
    build -a X64 -p OvmfPkg/OvmfPkgX64.dsc

ビルドされたバイナリの場所
==========================

::

    edk2/Build/OvmfX64/DEBUG_GCC49/FV/OVMF_CODE.fd
    edk2/Build/OvmfX64/DEBUG_GCC49/FV/OVMF_VARS.fd

