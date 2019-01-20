#!/bin/bash

# ====================================================
#	System Request:Debian 8 + Ubuntu 16
#	Author:	fanghaizhou
#	Aria2+Oneindex
# ====================================================

#fonts color
Green="\033[32m" 
Red="\033[31m" 
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"

#folder
aria2_new_ver="1.33.1"

bit=`uname -m`
source /etc/os-release &>/dev/null
# 系统检测、仅支持 Debian8+ 和 Ubuntu16.04+
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    elif [[ "${ID}" == "ubuntu" && `echo "${VERSION_ID}" | cut -d '.' -f1` -ge 16 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${RedBG} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi
	port_exist_check 6800
	apt-get update
	apt install wget unzip net-tools bc curl sudo -y
}

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

port_exist_check(){
    if [[ 0 -eq `netstat -tlpn | grep "$1"| wc -l` ]];then
        echo -e "${OK} ${GreenBG} $1 端口未被占用 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 端口被占用，请检查占用进程 结束后重新运行脚本 ${Font}"
        netstat -tlpn | grep "$1"
        exit 1
    fi
}

get_Aria2Pass(){
    stty erase '^H' && read -p "请输入你的Aria2密钥:" pass
}


aria_install(){
echo -e "${GreenBG} 开始安装Aria2 ${Font}"
apt-get install build-essential cron -y
cd /root
mkdir Download
wget -N --no-check-certificate "https://github.com/q3aql/aria2-static-builds/releases/download/v${aria2_new_ver}/aria2-${aria2_new_ver}-linux-gnu-${KernelBit}bit-build1.tar.bz2"
Aria2_Name="aria2-${aria2_new_ver}-linux-gnu-${KernelBit}bit-build1"
tar jxvf "${Aria2_Name}.tar.bz2"
mv "${Aria2_Name}" "aria2"
cd "aria2/"
make install
cd /root
rm -rf aria2 aria2-${aria2_new_ver}-linux-gnu-64bit-build1.tar.bz2
mkdir "/root/.aria2" && cd "/root/.aria2"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/dht.dat"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/trackers-list-aria2.sh"
echo '' > /root/.aria2/aria2.session
chmod +x /root/.aria2/trackers-list-aria2.sh
chmod 777 /root/.aria2/aria2.session
echo "dir=/root/Download
rpc-secret=${pass}


disk-cache=32M
file-allocation=trunc
continue=true


max-concurrent-downloads=10
max-connection-per-server=5
min-split-size=10M
split=20
disable-ipv6=false
input-file=/root/.aria2/aria2.session
save-session=/root/.aria2/aria2.session

enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=6800



follow-torrent=true
listen-port=51413
enable-dht=true
enable-dht6=false
dht-listen-port=6881-6999
bt-enable-lpd=true
enable-peer-exchange=true
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
seed-time=0
bt-seed-unverified=true
on-download-complete=/root/.aria2/autoupload.sh
allow-overwrite=true
bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.open-internet.nl:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://allesanddro.de:1337/announce,udp://9.rarbg.to:2710/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.safe.moe:6969/announce,udp://tracker.piratepublic.com:1337/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker2.christianbro.pw:6969/announce,udp://tracker1.wasabii.com.tw:6969/announce,udp://tracker.zer0day.to:1337/announce,udp://public.popcorn-tracker.org:6969/announce,udp://tracker.xku.tv:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://inferno.demonoid.pw:3418/announce,udp://tracker.mg64.net:6969/announce,udp://open.facedatabg.net:6969/announce,udp://mgtracker.org:6969/announce" > /root/.aria2/aria2.conf
echo "0 3 */7 * * /root/.aria2/trackers-list-aria2.sh
*/5 * * * * /usr/sbin/service aria2 start
*/10 * * * * /usr/bin/php /var/www/html/one.php cache:refresh" >> /var/spool/cron/crontabs/root
}

init_install(){
echo -e "${GreenBG} 开始配置自启 ${Font}"
wget --no-check-certificate https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/gdlist/sh/aria2 -O /etc/init.d/aria2
chmod +x /etc/init.d/aria2
update-rc.d -f aria2 defaults
wget https://raw.githubusercontent.com/df123/aria2-oneindex/master/autoupload.sh
sed -i '4i\name='${name}'' autoupload.sh
sed -i '4i\folder='${folder}'' autoupload.sh
mv autoupload.sh /root/.aria2/autoupload.sh
chmod +x /root/.aria2/autoupload.sh
bash /etc/init.d/aria2 start
}

php_install(){
echo -e "${GreenBG} 开始安装PhP5.6 ${Font}"
apt-get install php5-common libapache2-mod-php5 php5-cli
apt-get install php5-curl
/etc/init.d/apache2 stop
/etc/init.d/apache2 start
}

oneindex_install(){
echo -e "${GreenBG} 开始安装oneindex ${Font}"
apt-get install git
cd /var/www/html/
rm -rf *
git clone https://github.com/donwa/oneindex.git
cd oneindex
mv * ../
cd ../
rm -rf oneindex
chmod +x *
chmod 777 *
}

main(){
      check_system
      is_root
	    sleep 2
			get_Aria2Pass
			aria_install
			php_install
			oneindex_install
			init_install
}

main
