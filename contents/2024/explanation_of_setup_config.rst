.. post:: 2024-12-10
   :tags: Ubuntu, Linux, resonite, VR
   :category: "IT technology"
   :author: usaturn
   :location: Japan
   :language: ja

.. _explanation_of_setup_config:

========================
setup-config.yaml の解説
========================

`(2枚目) Resonite Advent Calendar 2024 <https://adventar.org/calendars/10544>`__ 10日目の記事です


この記事では :ref:`set_up_a_resonite_headless_server_on_compute_engine` で ヘッドレスサーバ_ を構築する際に指定する元となる
**setup-config.yaml** を生成するためのテンプレート **setup-config.yaml.template** について解説します

**setup-config.yaml** とは
==========================

手順で :command:`python gce_cloudinit_yaml_generator.py` を実行すると生成されるファイルです。
ユーザ名、パスワードなどを記載した **personal-information.json** を元に **setup-config.yaml.template** から生成されます

personal-information.json （再掲） ::

    {
        "HEADLESS_PASSWORD": "フレンド欄の resonite に /headlessCode とメッセージを送って返ってくる文字列",
        "STEAM_USER": "ヘッドレスサーバ用に作成した Steam アカウント名",
        "STEAM_PASSWORD": "Steam アカウントのパスワード",
        "HEADLESS_USER": "ヘッドレスサーバ用に作成した resonite ユーザ名"
    }

**setup-config.yaml** は GCE インスタンスを作成するコマンド :command:`gcloud compute instances create` の引数として
:command:`--metadata-from-file=user-data=${SETUP_RESONITE_HEADLESS_SERVER_SCRIPT}` のように指定しています。

`cloud-init <https://cloud-init.io/>`__ という仕組みを利用して GCE インスタンスの初回起動時にだけ **setup-config.yaml** の記述内容が実行されます

**setup-config.yaml.template** の全体は下記の通りです

.. literalinclude:: /contents/files/setup-config.yaml.template
  :language: bash

以降、 **setup-config.yaml.template** をブロックごとに解説します

setup-config.yaml.template の解説
=================================

各モジュール(bootcmd, write_files, runcmd)は優先順位が存在しており、bootcmd, write_files, runcmd の順番で優先実行されます

トップ行
--------

::

    #cloud-config ⇒ cloud-init のファイルという宣言です

    timezone: Asia/Tokyo ⇒ 時間の表示を日本時間にします
    locale: ja_JP.utf8 ⇒ システムの環境を日本語環境にします

bootcmd ブロック
----------------

今回使っているモジュールの中で、実行される優先順位が一番高いブロックです ::

    bootcmd:
      - mkdir -p /var/lib/resonite/ ⇒ Unit ファイルを格納するディレクトリを作成します
      - useradd -s /bin/bash -d /home/%%{USER} -m %%{USER} ⇒ Google Cloud Shell のユーザで、GCE インスタンスのユーザを作成します


write_files ブロック
--------------------

以下 4 ファイルを作成します

:resonite-headless.service: システムが起動する際に毎回実行される Unit ファイルです。 ヘッドレスサーバ_ の起動／停止を制御します
:start-resonite-headless.bash: **resonite-headless.service** が呼び出している ヘッドレスサーバ_ を起動するスクリプトです
:.tmux.conf: ヘッドレスサーバ_ は tmux のセッションとして起動しており、その tmux の設定ファイルです
:setup-resonite-headless-server.bash: runcmd モジュールで最後に実行されるスクリプトです（つまりインスタンス初回起動時のみ実行されます）

resonite-headless.service 行 ::

    - path: /etc/systemd/system/resonite-headless.service ⇒ このパスに以下のファイルを作成します

      # ファイルのパーミッションとオーナーを指定します
      permissions: 0644
      owner: root

      # content 以降がファイルに書き込まれる内容です
      content: |

        [Unit]
        Description=Resonite Headless Server
        After=network.service

        [Service]
        Type=forking
        # Restart=always
        WorkingDirectory=/home/%%{USER}
        ExecStart=/bin/bash /var/lib/resonite/start-resonite-headless.bash ⇒ インスタンス起動時に、このスクリプトを実行します。次のブロックで解説します
        ExecStop=/usr/bin/tmux kill-server ⇒ Unit が停止する時に実行されます。tmux を停止しますが、実質ここでヘッドレスサーバが停止します
        ExecStop=/usr/bin/rm -rf /home/%%{USER}/.local/share/Steam/steamapps/common/Resonite/Headless/Cache/Cache/ ⇒ 上記の直後に実施されます。ヘッドレスのキャッシュを削除します
        User=%%{USER}
        Group=%%{USER}

        [Install]
        WantedBy=multi-user.target

start-resonite-headless.bash 行 ::

    - path: /var/lib/resonite/start-resonite-headless.bash ⇒ このパスに content 以下のファイルを作成します

      permissions: 0644
      owner: root
      content: |

        #!/bin/bash
        # インスタンス内部から自身のインスタンス名を取得します（インスタンス名と同名のシークレットにアクセスする為の布石）
        export INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name 2>/dev/null)

        export HEADLESS_CONFIG_SECRET=${INSTANCE_NAME}
        export RESONITE_HEADLESS_DIR="/home/%%{USER}/.local/share/Steam/steamapps/common/Resonite/Headless"
        export HEADLESS_CONFIG_FILE=${RESONITE_HEADLESS_DIR}/Config/Config.json

        # ヘッドレスサーバが使用するディレクトリを作成します
        install -d -m 0755 -o %%{USER} -g %%{USER} ${RESONITE_HEADLESS_DIR}/Logs
        install -d -m 0755 -o %%{USER} -g %%{USER} ${RESONITE_HEADLESS_DIR}/Config


        # ヘッドレスサーバの Config.json をシークレットから生成します（ヘッドレスサーバ起動時に毎回書き換えていることに注意）
        gcloud secrets versions access latest --secret ${HEADLESS_CONFIG_SECRET} > ${HEADLESS_CONFIG_FILE}

        # steamcmd コマンドでヘッドレスサーバをアップデートします（ヘッドレスサーバ起動時に毎回実行しています）
        /usr/games/steamcmd +login %%{STEAM_USER} +app_update 2519830 validate +exit

        # tmux からヘッドレスサーバを起動します
        tmux new-session -d "dotnet ${RESONITE_HEADLESS_DIR}/Resonite.dll -HeadlessConfig ${HEADLESS_CONFIG_FILE} -Logs ${RESONITE_HEADLESS_DIR}/Logs"

.tmux.conf 行 ::

    - path: /home/%%{USER}/.tmux.conf
      permissions: 0644
      owner: %%{USER}
      content: |
        # cancel the key bindings for C-b
        unbind C-b
        # set prefix key
        #set -g prefix C-b
        # reduce delay of key stroke
        set -sg escape-time 1
        # begin index of window from 1
        set -g base-index 1
        # begin index of pane from 1
        setw -g pane-base-index 1
        # rireki
        set-option -g history-limit 500000
        # reload tmux config file
        bind r source-file ~/.tmux.conf \; display "Reloaded!"
        # set prefix key
        set-option -g prefix C-k
        unbind-key C-b
        bind-key C-k send-prefix
        # split the pane with a pipe in a vertical
        bind v split-window -h
        # split the pane with a pipe in a transverse
        bind w split-window -v
        # move between the panes in the key bindings for vim
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind -r C-h select-window -t :-
        bind -r C-l select-window -t :+
        # resize the pane in the key bindings for vim
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
        # use a 256-color terminal
        set -g default-terminal "screen-256color"
        # set the color of the status bar
        set -g status-fg white
        set -g status-bg black
        # set status bar
        ## set the left panel
        set -g status-left-length 40
        set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
        ## set the right panel
        set -g status-right-length 100
        set -g status-right '#[fg=cyan][%Y-%m-%d(%a) %H:%M]'
        ## set the refresh interval (default 15 seconds)
        set -g status-interval 60
        ## center shifting the position of the window list
        set -g status-justify centre
        ## enable the visual notification
        setw -g monitor-activity on
        set -g visual-activity on
        ## display the status bar at the top
        set -g status-position top
        # set the copy mode
        ## use the key bindings for vi
        setw -g mode-keys vi
        source /usr/share/powerline/bindings/tmux/powerline.conf
        run-shell "powerline-daemon -q"

setup-resonite-headless-server.bash 行 ::

    - path: /var/lib/resonite/setup-resonite-headless-server.bash ⇒ このパスに content 以下のファイルを作成します

      permissions: 0644
      owner: root
      content: |

        #!/bin/bash
        set -o pipefail

        # 本スクリプトログの出力先を指定しています
        declare -r command_log="/root/command.log"

        # 実行するコマンドを配列にしています
        declare -a command_lines=(
            'sudo apt update'
            'sudo apt install -y software-properties-common'
            'sudo add-apt-repository -y multiverse'
            'sudo dpkg --add-architecture i386'
            'sudo add-apt-repository -y ppa:dotnet/backports'
            'sudo apt update'

            # steam のインストール時に聞かれる質問をスキップする布石です
            'echo steam steam/license note "" | sudo debconf-set-selections'
            'echo steam steam/question select "I AGREE" | sudo debconf-set-selections'

            # 必要なアプリケーションをインストールします
            'sudo apt install -y lib32gcc-s1 curl libopus-dev libopus0 opus-tools libc-dev tmux dstat powerline gnupg ca-certificates vim nano dotnet-runtime-9.0 steamcmd'

            # GCE インスタンスのモニタリング用エージェントをインストールします
            'curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh'
            'sudo bash add-google-cloud-ops-agent-repo.sh --also-install'
            'sudo apt autoremove -y'

            # steamcmd でヘッドレスサーバをインストールします
            'sudo -u %%{USER} /usr/games/steamcmd +login %%{STEAM_USER} %%{STEAM_PASSWORD} +app_license_request 2519830 +app_update 2519830 -beta headless -betapassword %%{HEADLESS_PASSWORD} validate +exit'
            'export RESONITE_HEADLESS_DIR="/home/%%{USER}/.local/share/Steam/steamapps/common/Resonite/Headless"'

            # 新しく追加した Unit ファイル resonite-headless.service を認識させます
            'systemctl daemon-reload'
            # resonite-headless.service を即座に有効にし、なおかつシステム起動時に有効にします
            'systemctl --now enable resonite-headless.service'
            'sudo touch ~/INITIALIZED'
        )
        timedatectl set-timezone Asia/Tokyo
        get_datetime="date +'%Y-%m-%d %H:%M:%S'"

        # エラーハンドリング行です
        number_of_erros=0
        function err() {
            status=$?
            lineno=$1
            func_name=${2:-main}
            date_time=$(eval ${get_datetime})
            err_str="${date_time} ERROR: ${SCRIPT}:${func_name}() returned non-zero exit status ${status} at line ${lineno}. Message: ${command_result}"
            echo ${err_str} >> ${command_log}
            let number_of_erros++
            exit
        }


        # エラーハンドリングブロックの最後に実行する行です
        function finally() {
            if [ ${number_of_erros} = 0 ]; then
                finalize_message="Succeeded."
            else
                finalize_message="Failure: Number of errors is ${number_of_erros}"
            fi
            date_time=$(eval ${get_datetime})
            echo -e "${date_time} ${finalize_message}" >> ${command_log}
        }


        # Start error handling
        trap 'err ${LINENO[0]} ${FUNCNAME[1]}' ERR
        trap finally EXIT

        # Start acquiring logs
        date_time=$(eval ${get_datetime})
        echo -e "${date_time} Start Scrpt" > ${command_log}

        # 配列 command_lines の要素であるコマンドを実行していきます。エラーが出たところで止まり、ログにエラー出力します
        # Execute main processing
        for command in "${!command_lines[@]}"; do
            command_result=$(
                eval ${command_lines[command]} 2>&1
            )
            date_time=$(eval ${get_datetime})
            echo ${date_time} Executed: ${command_lines[command]} >> ${command_log}
        done

        exit 0

runcmd ブロック
===============

最後に実行されるブロックです。
必要なパッケージをインストールしたり、Unit を作成する為の **setup-resonite-headless-server.bash** を実行しています ::

  - /bin/bash /var/lib/resonite/setup-resonite-headless-server.bash


その他
======

本手順は、 `cloud-init <https://cloud-init.io/>`__ を利用するクラウドリソースを前提としていますが、自宅等の物理サーバで運用する場合も役に立つ部分があるかと思います。

cloud-init を使わずとも、resonite-headless.service や start-resonite-headless.bash は Linux システムを利用する場合は有効かと思います。

もっと良い方法があるよ！という方がいらっしゃれば是非フィートバックをお願いします。

:ref:`明日の記事 <about_operating_a_resonite_headless_server_on_gce_for_one_year>` へ続きます。

.. include:: /contents/include_files/resonite_headless_link.txt

