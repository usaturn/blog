.. post:: 2016-09-04
   :tags: KVM, Linux, QEMU, libvirt
   :category: VIRTUAL
   :author: usaturn
   :location: Japan
   :language: ja

====================
libvirt の UEFI 設定
====================

概要
====
:ref:`build_uefi_for_qemu` で作成した仮想マシン用の UEFI ファームウェアを libvirt の仮想マシンに設定する

下記にビルドしたとして手順を進める ::

    edk2/Build/OvmfX64/DEBUG_GCC49/FV/OVMF_CODE.fd
    edk2/Build/OvmfX64/DEBUG_GCC49/FV/OVMF_VARS.fd


ファームウェアの配置
====================
ドメイン(libvirt に登録した仮想マシン)がファームウェアを読みだす為の共通のディレクトリを作成し、配置する ::

    mkdir -p /usr/share/OVMF
    cp -ip Build/OvmfX64/DEBUG_GCC49/FV/OVMF_CODE.fd Build/OvmfX64/DEBUG_GCC49/FV/OVMF_VARS.fd /usr/share/OVMF

qemu.conf の書き換え
====================
QEMU の設定にファームウェアの配置場所を記載する ::

    vim /etc/libvirtd/qemu.conf

        nvram = [
           "/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd",
        ]

ドメインの設定ファイルへの記述
==============================
ドメイン(libvirt に登録した仮想マシン)の設定ファイルを UEFI を利用するように書き換える ::

    virsh edit [ドメイン名]

      <os>
        <type arch='x86_64' machine='pc-i440fx-1.5'>hvm</type>
        <loader readonly='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
        <nvram template='/usr/share/OVMF/OVMF_VARS.fd'/>
        <boot dev='hd'/>
        <boot dev='cdrom'/>
      </os>

    # ドメインを起動し、nvram の記述が書き換わる事を確認する
    virsh start [ドメイン名]
    virsh edit [ドメイン名]

    # 表示例
    <nvram template='/usr/share/OVMF/OVMF_VARS.fd'>/var/lib/libvirt/qemu/nvram/vmbase_VARS.fd</nvram>

.. warning:: ドメインをクローンする場合の注意

             - UEFI の起動エントリは NVRAM ファイルに書き込まれる為、ドメインのクローンを作成する場合は ``[ドメイン名]_VARS.fd`` もコピーし設定も書き換える必要がある。
               NVRAM をコピーせずに新規のファイルを使う場合は起動エントリがない為、仮想ディスクに OS をインストールしていても起動しない事に注意する。

おまけ
======
qemu コマンドでの指定 ::

    mv OVMF.fd bios.bin
    qemu-system-x86_64 -enable-kvm -net none -m 1024 -drive file=/usr/share/ovmf/x86_64/bios.bin,format=raw,if=pflash,readonly

