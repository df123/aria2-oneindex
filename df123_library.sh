#!/bin/bash
#字体 颜色
Green="\033[32m" 
Red="\033[31m" 
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#信息颜色
Info="${Yellow}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"

#检查软件是否安装，通过dpkg -l，未安装则安装
check_software_installed_l(){
    if [[ 1 -le `dpkg -l | grep "$1" | wc -l` ]];then
        echo -e "${OK} ${GreenBG} $1 已经安装 ${Font}"
        sleep 1
    else
        echo -e "${info} ${Yellow} $1 未安装，现在安装 ${Font}"
        apt install $1
    fi
}

#检查软件是否安装，通过dpkg -s，未安装则安装
check_software_installed_s(){
    if [[ 1 -eq `dpkg -s $1 | grep "Status: install ok installed" | wc -l` ]];then
        echo -e "${OK} ${GreenBG} $1 已经安装 ${Font}"
        sleep 1
    else
        echo -e "${Info} ${Yellow} $1 未安装，现在安装 ${Font}"
        apt install $1 -y
    fi
}