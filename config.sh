#!/bin/bash
clear 
G='\e[32m'
R='\033[01;31m'
W='\e[39m' 
echo -e "$G|=====================================================================|"
echo -e "  _____             _              _____           _          "
echo -e " |  __ \           | |            / ____|         | |         "
echo -e " | |__) |__ _ _ __ | |_ ___  _ __| |     __ _  ___| |__   ___ "
echo -e " |  _  // _\` | '_ \| __/ _ \| '__| |    / _\` |/ __| '_ \ / _ \\"
echo -e " | | \ \ (_| | |_) | || (_) | |  | |___| (_| | (__| | | |  __/"
echo -e " |_|  \_\__,_| .__/ \__\___/|_|   \_____\__,_|\___|_| |_|\___|"
echo -e "             | |                                              "
echo -e "             |_|                                              "
echo -e "|=====================================================================|$W"     
echo ""
echo -e "$G== Init Config$W" 
echo ""
if [[ $EUID -ne 0 ]]; then
  echo -e "$RError! Use user root$W" 
exit 0 
fi

ARQ=`uname -m`
if [ $ARQ != x86_64 ] ; then
   echo -e "$RError! Not is 64 bits$W"
exit 0
fi

DHCP=`cat /etc/network/interfaces 2> /dev/null | grep "dhcp" | wc -l`
if [ $DHCP != 0 ]; then
   echo -e "$RError! Use IP static in config /etc/network/interfaces$W"
exit 0
fi	

IPSERV=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')		

HOST_NAME="raptor.os"					

apt-get update -y
if [ $? -ne 0 ]; then
   echo -e "$RError! Internet Connection$W"
exit 0
fi
apt-get upgrade -y

mv /etc/sysctl.conf /etc/sysctl.conf_
touch /etc/sysctl.conf
echo "fs.file-max = 819201
net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sysctl --system
echo 819200 > /proc/sys/fs/file-max
echo "*         soft        nofile          819200
*         hard        nofile          819200
root      soft        nofile          819200
root      hard        nofile          819200
proxy     soft        nofile          819200
proxy     hard        nofile          819200" > /etc/security/limits.conf

RPPROFILE=`cat /etc/profile 2> /dev/null | grep "Unlimit" | wc -l`
if [ $RPPROFILE == 0 ]; then
echo "
# Unlimit
ulimit -Hn 819201
ulimit -Sn 819200" >> /etc/profile
fi

if [ $(cat /etc/resolv.conf | grep -v "127.0.0.1" | grep -E 'nameservers|nameserver' | head -1 | awk '{print $2}' | wc -w) == 0 ]; then
DNS1="8.8.8.8"
else 
DNS1=`cat /etc/resolv.conf | grep -v "127.0.0.1" | grep -E 'nameservers|nameserver' | head -1 | awk '{print $2}'`	
fi

# == Dev ==
#apt-get install -y --force-yes libcap2-dev 
apt-get install -y --force-yes libltdl-dev 
#apt-get install -y --force-yes libcppunit-dev 
#apt-get install -y --force-yes libssl-dev 
# == Squid ==
apt-get install -y --force-yes lsb-release
apt-get install -y --force-yes build-essential 
apt-get install -y --force-yes bridge-utils 
apt-get install -y --force-yes beep

mkdir /usr/local/raptor/
mkdir /usr/local/raptor/cache-ssl
chmod 777 /usr/local/raptor/cache-ssl
mkdir -p /var/spool/squid3
chmod 777 /var/spool/squid3/
chown proxy:proxy /var/spool/squid3
mkdir -p /var/log/squid3
chown proxy:proxy /var/log/squid3

if [ ! -f sq8.tar.gz ]; then
wget https://www.dropbox.com/s/mjrg7yzaqu6efvw/sq8.tar.gz --no-check-certificate
fi	

mv sq8.tar.gz /tmp
tar -xzvf /tmp/sq8.tar.gz -C /
chmod a+x /usr/sbin/squid3
chmod a+rwx /var/log/squid3 && chmod a+x /etc/init.d/squid3 

update-rc.d squid3 defaults

chmod 777 /var/log/squid3/

touch /etc/squid3/blacklist.lst
echo "cracks.st #name#crack site" > /etc/squid3/blacklist.lst
mv /etc/squid3/squid.conf /etc/squid3/squid.conf_
touch /etc/squid3/squid.conf
echo "#=====================================================================#
#                           Squid 3.x Conf                            #
#=====================================================================#
http_port 3128 intercept
http_port 3126
visible_hostname $HOST_NAME
icp_port 0
#----------------------------------------------------------------------
acl google url_regex -i (googlevideo\.com|www\.youtube\.com)
acl mobile browser -i regexp (iPhone|iPad|Windows.*Phone|BlackBerry|PlayBook|Trident|IEMobile)
request_header_access User-Agent deny google !mobile
request_header_replace User-Agent Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
#----------------------------------------------------------------------
#error_directory /usr/share/squid3/errors/Spanish/
#----------------------------------------------------------------------
acl blacklist url_regex -i \"/etc/squid3/blacklist.lst\"
#----------------------------------------------------------------------
# Servidor DNS y Politica de Cambios
#----------------------------------------------------------------------
dns_nameservers $DNS1 8.8.4.4
dns_retransmit_interval 5 seconds
dns_timeout 2 minutes
#----------------------------------------------------------------------
acl built-in proto cache_object
 
acl localnet src 10.0.0.0/8     # RFC 1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC 1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC 1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl CONNECT method CONNECT

acl Safe_ports port 80          # http
acl Safe_ports port 443         # https
acl SSL_ports port 443          # https

http_access deny blacklist
http_access allow localhost built-in
http_access deny built-in
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost
http_access allow localnet
#----------------------------------------------------------------------
coredump_dir /var/spool/squid3 
include /etc/raptor/peers
cache_mgr raptor.os
shutdown_lifetime 2 seconds
half_closed_clients off
server_persistent_connections off
client_persistent_connections off
quick_abort_min 0 KB
quick_abort_max 0 KB
quick_abort_pct 95
max_filedescriptors 819200
qos_flows local-hit=0x48
#---------------------------------------------------------------------- " > /etc/squid3/squid.conf

/etc/init.d/squid3 stop
chmod 775 /lib/squid3/ssl_crtd
mkdir /var/lib/squid3
mkdir /var/lib/squid3/ssl_crtd
chmod 775 /lib/squid3/ssl_crtd
/lib/squid3/ssl_crtd -c -s /var/lib/squid3/ssl_db -M 4MB
chown -R proxy:proxy /var/lib/squid3/ssl_db/
#squid3 -NCd1
clear
sleep 1
echo "== Done SQ"
beep -f 999.9
beep -f 999.9

# == Packages ==
apt-get install -y --force-yes libcurl3
apt-get install -y --force-yes sudo 
apt-get install -y --force-yes apache2
apt-get install -y --force-yes php5
apt-get install -y --force-yes libapache2-mod-php5
apt-get install -y --force-yes libstdc++6
apt-get install -y --force-yes php-db
apt-get install -y --force-yes ebtables
apt-get install -y --force-yes smartmontools
apt-get install -y --force-yes ifstat
apt-get install -y --force-yes sysstat
apt-get install -y --force-yes ioping
apt-get install -y --force-yes hddtemp
apt-get install -y --force-yes squidclient
apt-get install -y --force-yes curl
apt-get install -y --force-yes ipset

# == Dev ==
#apt-get install -y --force-yes libcurl4-dev
#apt-get install -y --force-yes libblkid-dev
#apt-get install -y --force-yes gcc
#apt-get install -y --force-yes g++
#apt-get install -y --force-yes php5-dev 

#apt-get update -y

# == Mysql ==
clear 
sleep 1
echo "== Config Database"
#
MY=`which mysql | wc -l`
if [ $MY != 0 ]; then
apt-get purge --remove -y mysql*
apt-get purge --remove -y percona*
rm -rf /etc/mysql/
fi
sleep 1
apt-get install -y --force-yes libdbd-mysql-perl
apt-get install -y --force-yes mysql-common
apt-get install -y --force-yes libmysqlclient18
apt-get install -y --force-yes libaio1
apt-get install -y --force-yes libnuma1
apt-get install -y --force-yes libjemalloc1
apt-get install -y --force-yes php5-mysql 
#apt-get install -y --force-yes libmysqlclient15-dev 
if [ -f /etc/mysql/my.cnf ]; then
sed -i 's/tokudb_fanout.*//g' /etc/mysql/my.cnf
fi
if [ ! -f percona56.tar.gz ]; then
wget https://www.dropbox.com/s/kvmbhteapg4aj3w/percona56.tar.gz --no-check-certificate
fi
tar -xzvf percona56.tar.gz
cd /root/percona
dpkg -i percona-server-common-5.6_5.6.36-82.0-1.jessie_amd64.deb
dpkg -i libperconaserverclient18.1_5.6.36-82.1-1.jessie_amd64.deb
dpkg -i percona-server-client-5.6_5.6.36-82.0-1.jessie_amd64.deb
DBPASS="raptor"
export DBPASS
echo percona-server-server-5.6 percona-server-server/root_password password $DBPASS | debconf-set-selections
echo percona-server-server-5.6 percona-server-server/root_password_again password $DBPASS | debconf-set-selections
dpkg -i percona-server-server-5.6_5.6.36-82.0-1.jessie_amd64.deb
dpkg -i percona-server-tokudb-5.6_5.6.36-82.0-1.jessie_amd64.deb
/etc/init.d/mysql restart
if [ $? -ne 0 ]; then
   echo -e "$RError! Mysql restart$W"
fi
ps_tokudb_admin --enable -uroot -praptor
wget www.raptor.alterserv.com/var/raptor_d8.sql
mv raptor_d8.sql /var/tmp/
mysql -uroot -praptor << eof
CREATE DATABASE raptor;
eof
mysql -uroot -praptor raptor < /var/tmp/raptor_d8.sql
cd /root	
beep -f 999.9
beep -f 999.9

# == Raptor ==
#wget https://www.dropbox.com/s/i873igc4uyg3kzt/libmysqlclient16_5.1.49-3_amd64.deb --no-check-certificate
#dpkg -i libmysqlclient16_5.1.49-3_amd64.deb
clear
if [ ! -f core_2.0.6.tar.gz ]; then
wget https://www.dropbox.com/s/xxk28dg50dsu2e8/core_2.0.6.tar.gz --no-check-certificate
fi
mv core_2.0.6.tar.gz /tmp
tar -xzvf /tmp/core_2.0.6.tar.gz -C /
chmod a+x /usr/sbin/raptor
mkdir /var/log/raptor  
mkdir /usr/local/raptor
mkdir /var/backup_raptor_db
chmod 777 /var/backup_raptor_db
mkdir /var/tmp/upld
chmod 777 /var/tmp/upld
mkdir /usr/local/tmp
chmod 777 /usr/local/tmp
chmod a+rwx /var/log/raptor  
chmod a+x /etc/init.d/raptor 
chown -R www-data /usr/local/raptor/  
chmod -R 777 /usr/local/raptor/  
umask 000 /usr/local/raptor/ 
chmod 644 /etc/logrotate.d/raptor
update-rc.d raptor defaults
#
chmod 777 /etc/raptor/run.v/*
chmod 777 /etc/raptor/up.v/*
# 
chmod 777 /etc/raptor/*  
chmod 777 /usr/include/raptor/*
#
chmod a+x /usr/bin/rpcnx
#sed -i 's/#comment#/#name#/g' /etc/raptor/fw.sh

echo "#cache deny all
#----------------------------------------------------------------------
acl sys_lst url_regex -i \"/etc/raptor/sys.lst\"
acl raptor_lst url_regex -i \"/etc/raptor/raptor.lst\"
acl wth_lst url_regex -i \"/etc/raptor/whitelist.lst\"
acl host_lst req_header Host -i \"/etc/raptor/host.lst\"
acl exts url_regex -i \.(cab|exe|msi|msu|zip|deb|rpm|bz|bz2|gz|tgz|rar|bin|7z|mp3|mp4|flv)$
acl head_html req_header Accept -i text/html.+
cache deny raptor_lst
cache_peer $IPSERV parent 8080 0 proxy-only no-digest
dead_peer_timeout 2 seconds
cache_peer_access $IPSERV allow host_lst
cache_peer_access $IPSERV allow exts
cache_peer_access $IPSERV deny head_html
cache_peer_access $IPSERV deny wth_lst
cache_peer_access $IPSERV allow raptor_lst
cache_peer_access $IPSERV allow sys_lst
cache_peer_access $IPSERV deny all 
cache deny all !google !str1
#----------------------------------------------------------------------" >> /etc/squid3/squid.conf 
clear
squid3 -z
/etc/init.d/squid3 restart
sleep 1
/etc/init.d/squid3 restart
if [ $? -ne 0 ]; then
   echo -e "$RError! Squid3 restart$W"
fi
/etc/init.d/raptor start
if [ $? -ne 0 ]; then
   echo -e "$RError! Raptor restart$W"
fi
sleep 1
echo "== Done Raptor2"

beep -f 999.9
beep -f 999.9

# == Services ==
wget https://www.dropbox.com/s/1yvetyqzppqjesl/services_1.0.1.tar.gz --no-check-certificate
if [ $? -ne 0 ]; then
   echo "Error! Internet Connection"
   exit 0
fi
mv services_1.0.1.tar.gz /tmp
tar -xzvf /tmp/services_1.0.1.tar.gz -C /
chmod a+x /usr/bin/clean
chmod a+x /usr/bin/cleandomain
chmod a+x /usr/bin/cleanhit
chmod a+x /usr/bin/serv
chmod a+x /usr/bin/rprst
chmod a+x /usr/bin/rptr
chmod a+x /usr/bin/rpcnx

# == Address List ==
IFS=$'\n' 
mkdir /usr/local/raptor/address
chmod 777 /usr/local/raptor/address
wget https://www.dropbox.com/s/785sy1rdzd3v1d7/address_list_default.tar.gz --no-check-certificate
if [ $? -ne 0 ]; then
   echo "Error! Internet Connection"
   exit 0
fi
mv address_list_default.tar.gz /tmp
tar -xzvf /tmp/address_list_default.tar.gz -C /
chmod 777 /usr/local/raptor/address/*
COMMAND=`ls /usr/local/raptor/address`
for LINE in $COMMAND; do
	echo "Restore list => $LINE"
	ipset restore -f /usr/local/raptor/address/${LINE}
done
IFS=$old_IFS 

# == Cron ==
RPCRON=`cat /etc/crontab 2> /dev/null | grep "Raptor" | wc -l`
if [ $RPCRON == 0 ]; then
echo "
## Raptor
# min(0-59)  hora(0-23)  diames(1-31)  mes(1-12)  diasem(0-7)  user   comando
59              1               *       *               *       root    clean 45
30              23              *       *               *       root    squid3 -k rotate
*/1              *              *       *               *       root    /etc/raptor/./cl0
45              23              *       *               *       root    bash /etc/raptor/exp.sh
57              22              *       *               *       root    bash /etc/raptor/rprotate.sh
*/2             *               *       *               *       root    serv
#*/3             *               *       *               *       root    frch
59              22              *       *               *       root    rprst
*/10            *               *       *               *       root    /usr/bin/php /usr/share/raptor/models/req/ssl.php
*/1             *               *       *               *       root    vnstat -u -i eth0" >> /etc/crontab
fi

# == Hosts and Resolv ==	
#mv /etc/hosts /etc/hosts_
#touch /etc/hosts
#echo "127.0.0.1	localhost
#$IPSERV	$HOST_NAME	proxy
##
#::1	localhost	ip6-localhost	ip6-loopback
#fe00::0 ip6-localnet
#fe00::0 ip6-mcastprefix
#ff02:1 ip6-allnodes
#ff02::2 ip6-allrouters
#ff02::3 ip6-allhosts" >> /etc/hosts
#mv /etc/hostname /etc/hostname_
#touch /etc/hostname
#echo "$HOST_NAME" >> /etc/hostname

mv /etc/resolv.conf /etc/resolv.conf_
touch /etc/resolv.conf
echo "search $HOST_NAME
##-##nameserver 127.0.0.1
nameserver $DNS1
nameserver 8.8.4.4" > /etc/resolv.conf

# == Bind ==
clear
apt-get install -y --force-yes bind9 
apt-get install -y --force-yes dnsutils 
apt-get install -y --force-yes bind9-doc 
mv /etc/bind/named.conf.options /etc/bind/named.conf.options_
touch /etc/bind/named.conf.options
echo "options {	
	directory \"/var/cache/bind\";		
	forwarders {
		8.8.8.8;
		8.8.4.4;
	};	
	auth-nxdomain no; # conform to RFC1035
	listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

mv /etc/bind/named.conf.local /etc/bind/named.conf.local_
touch /etc/bind/named.conf.local
echo "include \"/etc/bind/zones.rfc1918\";
logging {
category lame-servers {null; }; 
category edns-disabled { null; }; 
};" > /etc/bind/named.conf.local

RPCRON=`cat /etc/crontab 2> /dev/null | grep "DNS Cache" | wc -l`
if [ $RPCRON == 0 ]; then
echo "
# DNS Cache
*/1               *               *       *               *       root    rndc dumpdb" >> /etc/crontab
fi            

RPSHUT=`cat /etc/crontab 2> /dev/null | grep "Shutdown" | wc -l`
if [ $RPSHUT == 0 ]; then
echo "
# Shutdown
##-##59 23 * * * root shutdown -h now #name#shutdown-server" >> /etc/crontab
fi 

beep -f 999.9
beep -f 999.9

# == WebPanelRaptor ==
if [ ! -f panel_1.4.5.tar.gz ]; then
wget https://www.dropbox.com/s/ihyrz55e0oj20gf/panel_1.4.5.tar.gz --no-check-certificate
fi
mv panel_1.4.5.tar.gz /tmp
tar -xzvf /tmp/panel_1.4.5.tar.gz -C /
clear
chmod 777 /usr/share/raptor/*
chmod 777 /usr/share/raptor/main/settings.php
chmod 777 /usr/share/raptor/models/req/ssl.php
chmod 777 /usr/share/raptor/models/req/upHttp.php
chmod 777 /usr/share/raptor/models/req/upHttps.php
#
chmod 777 /etc/squid3/squid.conf
chmod 777 /etc/raptor/raptor.conf
chmod 777 /etc/raptor/fw.sh
chmod 777 /etc/raptor/raptor.lst
chmod 777 /etc/raptor/whitelist.lst
chmod 777 /etc/raptor/idst.pl
chmod 777 /etc/raptor/jumplog
chmod 777 /etc/squid3/blacklist.lst
chmod 777 /etc/network/interfaces
chmod 777 /etc/resolv.conf
chmod 777 /etc/fstab
#
touch /etc/apache2/sites-available/raptor.conf
echo "Listen 82
<VirtualHost *:82>
	DocumentRoot /usr/share/raptor
	ServerName raptor.os
	#ErrorLog /var/log/apache2/virtual82-error.log
	ErrorLog /dev/null
	#CustomLog /var/log/apache2/virtual82-access.log common
	CustomLog /dev/null common
	 <Directory /usr/share/raptor>
	                Options Indexes FollowSymLinks MultiViews
	                AllowOverride All
	                Order allow,deny
	                allow from all
	 </Directory>	
 </VirtualHost>" > /etc/apache2/sites-available/raptor.conf
#echo "ServerName $HOST_NAME" >> /etc/apache2/apache2.conf 
chown -R www-data.www-data /usr/share/raptor
a2enmod rewrite
a2ensite raptor.conf
cp /etc/mysql/my.cnf /etc/mysql/my.cnf_
if [ ! -f my.tar.gz ]; then
wget http://www.raptor.alterserv.com/var/my.tar.gz
fi
mv my.tar.gz /tmp
tar -xzvf /tmp/my.tar.gz -C /
chmod 664 /etc/mysql/my.cnf
/etc/init.d/apache2 restart
if [ $? -ne 0 ]; then
   echo -e "$RError! Apache2 restart$W"
fi
clear
sleep 1
# == 
apt-get install -y --force-yes vnstat 
vnstat -u -i eth0
# == Sensors ==
apt-get install -y --force-yes lm-sensors
clear
#/etc/init.d/module-init-tools restart
echo YES | sensors-detect --auto
clear
#echo Y | apt-get --purge remove sudo
#apt-get install -y --force-yes sudo
RPSUDO=`cat /etc/sudoers 2> /dev/null | grep "www-data ALL=(ALL) NOPASSWD" | wc -l`
if [ $RPSUDO == 0 ]; then
echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers	
#echo "www-data ALL=(ALL) NOPASSWD: /sbin/ifconfig, /usr/sbin/hddtemp,/usr/bin/tail,/usr/bin/crontab,/bin/mv,/bin/chmod,/sbin/route,/bin/rm,/usr/bin/curl,/bin/bash,/etc/raptor/fw.sh,/etc/raptor/cl0,/etc/raptor/ifstat,/etc/raptor/flush-ssl.sh,/etc/raptor/shut_rp.sh,/etc/raptor/up_check.sh,/etc/raptor/up_core_online.sh,/etc/raptor/up_manual.sh,/etc/raptor/up_panel_online.sh,/etc/raptor/up_services_online.sh" >> /etc/sudoers
if [ $? -ne 0 ]; then
   echo -e "$RError in sudoers$W"
   exit
fi
fi
#chmod 777 /etc/sudoers
clear

# == Init fw ==
mv /etc/rc.local /etc/rc.local_
touch /etc/rc.local
echo "#!/bin/sh -e" > /etc/rc.local
echo "bash /etc/raptor/default.sh" >> /etc/rc.local
echo "sh /etc/raptor/fw.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod 777 /etc/rc.local

echo ""
echo ""
echo -e "$G+==========================================================================+"
echo -e "|                         INSTALACION FINALIZADA                           |"
echo -e "|          SE REINICIARA SU SISTEMA PARA CONCLUIR LA INSTALACION           |"
echo -e "|==========================================================================|"
echo -e "|                         INSTALLATION COMPLETE                            |"
echo -e "|         IT WILL REBOOT YOUR SYSTEM TO COMPLETE THE INSTALLATION          |"
echo -e "+==========================================================================+$W"
echo ""
echo ""
echo "Para ingresar al RaptorWebPanel hacerlo desde la URL:"
echo ""
echo "To access the Web Panel do this from the URL:"
echo -e "$G"
echo -e "http://$IPSERV:82"
echo -e "$W"
echo "Usuario : admin"
echo "Password : admin "
echo ""
i=9
printf "\r*\r"
sleep 1
while ((i>=0)); do
printf $((i--))"\r"
sleep 1	
done
shutdown -r now
