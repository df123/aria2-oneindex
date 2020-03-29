#!/bin/bash
#!/usr/bin/expect
source ./df123_library.sh
# ====================================================
#	System Request:Debian 9+
#	Author:	df123
#	Aria2+Oneindex
# ====================================================

start_path=""
default_version="php7.3"
bit=`uname -m`
source /etc/os-release &>/dev/null

# 判定是否为root用户
is_root(){
    if [ `id -u` == 0 ]
        then echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font} "
        sleep 1
    else
        echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}" 
        exit 1
    fi
}

# 系统检测、仅支持 Debian9+
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${RedBG} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi

    start_path=`pwd`
}

install_requirement_software(){
    apt update

    requirement_software=("wget" "unzip" "net-tools" "curl" "git")
	for item in ${requirement_software[@]}
    do
        check_software_installed_s $item
    done
}

# 检查端口是否被占用
port_exist_check(){
    if [[ 0 -eq `netstat -tlpn | grep "$1"| wc -l` ]];then
        echo -e "${OK} ${GreenBG} $1 端口未被占用 ${Font}"
        return 0
    else
        echo -e "${Error} ${RedBG} $1 端口被占用，请检查占用进程 结束后重新运行脚本 ${Font}"
        netstat -tlpn | grep "$1"
        return 1
    fi
}


#寻找未被发现的端口
available_port="8080"
find_port(){
    port=$1
    port_exist_check $port
    while [[ 1 -eq $? ]]
    do
        let 'port += 1'
        port_exist_check $port
    done
    available_port=$port
}

get_Aria2Pass(){
    read -p "请输入你的Aria2密钥:" pass
}

aria_install(){
    echo -e "${GreenBG} 开始安装Aria2 ${Font}"
    user_path="/home/$1"
    check_software_installed_s "aria2"

    mkdir "$user_path/.aria2"
    chown aria2:aria2 "$user_path/.aria2"

    mkdir "$user_path/downloads/"
    chown aria2:aria2 "$user_path/downloads"

    touch $user_path/.aria2/aria2.session
    chown aria2:aria2 $user_path/.aria2/aria2.session
    chmod 744 $user_path/.aria2/aria2.session

    find_port 6800

    echo "dir=$user_path/downloads
rpc-secret=${pass}

daemon=true

disk-cache=32M
file-allocation=trunc
continue=true

max-concurrent-downloads=10
max-connection-per-server=5
min-split-size=10M
split=20
disable-ipv6=false
input-file=$user_path/.aria2/aria2.session
save-session=$user_path/.aria2/aria2.session

enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=$available_port

follow-torrent=true
listen-port=6881-6999
enable-dht=true
enable-dht6=true
dht-listen-port=6881-6999
bt-enable-lpd=true
enable-peer-exchange=true
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
seed-time=0
bt-seed-unverified=true
on-download-complete=$user_path/.aria2/automatic_move.sh
on-download-stop=$user_path/.aria2/automatic_delete.sh
allow-overwrite=true" > $user_path/.aria2/aria2.conf

    chown aria2:aria2  $user_path/.aria2/aria2.conf

    chown aria2:aria2 $start_path/automatic_*
    chmod 755 $start_path/automatic_*
    mv $start_path/automatic_* $user_path/.aria2/ 
    
    mv $start_path/aria2.service $user_path/.aria2/
    systemctl enable $user_path/.aria2/aria2.service
    systemctl start aria2.service
}

create_aria2_user(){
    useradd -m -s /bin/false $1
}


main(){
    is_root
    check_system
    install_requirement_software
    get_Aria2Pass
    create_aria2_user aria2
    aria_install aria2
    php_install
    check_webserver
    oneindex_install
}

main
