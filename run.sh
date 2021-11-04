#!/bin/bash

user=$1
echo $user
mkdir ./projects/$user

# ポート取得の参考:https://qiita.com/KEINOS/items/98a5ce4415b3691a0d22
function getPortUsed() {
    # この取得処理が一番重いので変数に入れて使い回すために用意
    echo `lsof -i -P | grep -i "tcp" | sed 's/\[.*\]/IP/' \
                   | sed 's/:/ /' | sed 's/->/ /'| awk -F' ' '{print $10}' \
                   | awk '!a[$0]++'`
}

function getPortRandom() {

    # 使用中のポート一覧がセットされていなければ関数内で取得
    if [ -z ${port_list+x} ]; then
        port_list="$(getPortUsed)"
    fi

    # 検索ポートの範囲指定（デフォルト範囲）
    port_min=${1:-1}
    port_max=${2:-65535}

    # 希望するポートがセットされていない場合や範囲外の場合は初期化
    if [ -z "$port" ] || [ $port_min -gt $port ] || [ $port_max -lt $port ]; then
        port="$(jot -w %i -r 1 $port_min $((port_max+1)))"
    fi

    port=$((port+0)) #文字列の数字を数値に変換

    while :
    do
        # ポートの衝突フラグをリセット（１なら使用中）
        port_collide=0

        # 使用中のポート一覧と $port を比較
        for port_used in $port_list
        do
            if [ "$port" = "$port_used" ]; then
                port_collide=1 # 使用中のポートと同じ
                break          # 処理を抜けてランダム番号を再取得
            fi
        done

        # 現在の $port が使用中ポートと重ならない場合は処理を抜ける
        if [ $port_collide -eq 0 ]; then
            break
        fi

        # ランダムな番号を取得
        port="$(jot -w %i -r 1 $port_min $((port_max+1)))"
    done

    echo "$port"
}

port="$(getPortRandom 18000 20000)" # ポート番号の範囲を指定（18000?20000）
echo $port

docker run -it -p $port:$port   \
     --mount type=bind,source="/var/local/projects/$user",target="/home/coder/project" \
     --env PASSWORD="$user" \
    alpine/codeserver code-server --auth=password --bind-addr=0.0.0.0:$port
