#!/bin/bash
#!/usr/bin/expect
source ./df123_library.sh
# ====================================================
#	System Request:Debian 9+
#	Author:	df123
#	Aria2+Oneindex
# ====================================================

default_version="php7.3"
bit=`uname -m`
source /etc/os-release &>/dev/null
# 系统检测、仅支持 Debian9+
check_system(){
	KernelBit="$(getconf LONG_BIT)"
    if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]];then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    else
        echo -e "${Error} ${RedBG} 当前系统为不在支持的系统列表内，安装中断 ${Font} "
        exit 1
    fi

	port_exist_check 6800

	apt update

    requirement_software=("wget" "unzip" "net-tools" "curl" "git")
	for item in ${requirement_software[@]}
    do
        check_software_installed_s $item
    done
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



# 检查端口是否被占用
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
    read -p "请输入你的Aria2密钥:" pass
}

create_aria_user()
{
    useradd test2
    spawn passwd test2
    #Enter new UNIX password
    expect "Enter new UNIX password:"
    send "123456\n"
    expect "Retype new UNIX password:"
    send "123456\n"
    expect eof
}

aria_install(){
    echo -e "${GreenBG} 开始安装Aria2 ${Font}"

    check_software_installed_s "aria2"

    mkdir "/root/.aria2" && cd "/root/.aria2"

    echo "dir=/root/Download
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
    allow-overwrite=true" > /root/.aria2/aria2.conf

    echo "*/10 * * * * /usr/bin/php /var/www/html/one.php cache:refresh" >> /var/spool/cron/crontabs/root
}

init_install(){
echo -e "${GreenBG} 开始配置自启 ${Font}"
wget https://raw.githubusercontent.com/df123/aria2-oneindex/master/autoupload.sh
sed -i '4i\name='${name}'' autoupload.sh
sed -i '4i\folder='${folder}'' autoupload.sh
mv autoupload.sh /root/.aria2/autoupload.sh
chmod +x /root/.aria2/autoupload.sh
bash /etc/init.d/aria2 start
}

php_install(){
    install_software_list=("-cli" "-curl")
    echo -e "${GreenBG} 开始安装PHP7 ${Font}"
    read -p "${Yellow}请输入你想要安装的php版本（默认php7.3）:${Font}" php_version

    if [ "$php_version" = "" ]; 
    then
        php_version=$default_version
        default_version=$php_version
        check_software_installed_s $php_version
        for item in ${install_software_list[@]}
        do
            check_software_installed_s $php_version$item
        done
    fi
}

oneindex_install(){
    echo -e "${GreenBG} 开始安装oneindex ${Font}"
    cd /var/www/
    git clone https://github.com/donwa/oneindex.git
    chown -R www-data:www-data oneindex/
    chmod -R 744 oneindex/
}

apache2_sites(){

echo "<VirtualHost *:8080>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/oneindex

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf
</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" > /etc/apache2/sites-available/oneindex.conf
    ln -s /etc/apache2/sites-available/oneindex.conf /etc/apache2/sites-enabled/oneindex.conf
    /etc/init.d/apache2 restart
}

nginx_sites(){
    echo "##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
	listen 8080 default_server;
	listen [::]:8080 default_server;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	root /var/www/oneindex;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html index.php;

	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files \$uri \$uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
	
		# With php-fpm (or other unix sockets):
		fastcgi_pass unix:/run/php/$default_version-fpm.sock;
		# With php-cgi (or other tcp sockets):
		#fastcgi_pass 127.0.0.1:9000;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}


# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
#server {
#	listen 80;
#	listen [::]:80;
#
#	server_name example.com;
#
#	root /var/www/example.com;
#	index index.html;
#
#	location / {
#		try_files \$uri \$uri/ =404;
#	}
#}" > /etc/nginx/sites-available/oneindex
    ln -s /etc/nginx/sites-available/oneindex /etc/nginx/sites-enabled/oneindex
    service nginx restart
}

check_webserver(){
    installed_server=" "
    if [[ 1 -eq `dpkg -s apache2 | grep "Status: install ok installed" | wc -l` ]];then
        echo -e "${OK} ${GreenBG} apache2 已经安装 ${Font}"
        apache2_sites
        sleep 1
    elif [[ 1 -eq `dpkg -s nginx | grep "Status: install ok installed" | wc -l` ]];then
        echo -e "${OK} ${GreenBG} nginx 已经安装 ${Font}"
        fpm="-fpm"
        check_software_installed_s $default_version$fpm
        sleep 1
    else 
        echo -e "${Info} ${Yellow} apache2和nginx均未安装，现在安装apache2 ${Font}"
    fi
}

main(){
    # check_system
    # is_root
    # check_webserver
    # php_install
    # oneindex_install
    nginx_sites
	#     sleep 2
	# 		get_Aria2Pass
	# 		aria_install
	# 		php_install
	# 		oneindex_install
	# 		init_install
}

main
