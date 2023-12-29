#!/bin/bash
#####################
# author: Ethan
# email: lipaysamart@gmail.com
# usage: 在虚拟机初始化时，固定你机器的IP地址脚本。
# example：bash Bound_IP.sh 192.168.1.99 192.168.1.1
#####################

Manu(){
cat <<-EOF 
----------------------------
|       1. CentOS 7        | 
|       2. Ubuntu 22       | 
----------------------------
EOF
}

CentOS7(){
ip a > /tmp/1.txt
IP=$1
GW=$2
i=`awk '{print $2}' /tmp/1.txt  | awk 'NR==7{print}' | awk -F ':' '{print $1}'`
ADRES=/etc/sysconfig/network-scripts/ifcfg-$i
sed -i "s#ONBOOT=no#ONBOOT=yes#g" $ADRES
sed -i "s#dhcp#static#g" $ADRES
cat <<-EOF  >>$ADRES
IPADDR=$IP
NETMASK=255.255.255.0
GATEWAY=$GW
DNS1=233.5.5.5
DNS2=8.8.8.8
EOF
systemctl restart network
ping -c 1 www.baidu.com
rm -f /tmp/1.txt
}


Ubuntu22(){
sed -i  's/dhcp/static/g' /etc/network/interface
read -p "请输入 IP 地址: "  $IP
read -p "请输入 Gateway 地址: "  $GW
read -p "请输入 DNS 地址: "  $DNS
cat <<-EOF >>/etc/network/interface
address $IP
netmask 255.255.255.0
gateway $GW
dns-nameservers $DNS
EOF
}

Manu
read -p "请输入你的操作系统:"  num
if [ $num = 1 ] 
then echo "-------- 开始设置静态IP --------"
CentOS7
elif [ $num = 2 ]
then echo "-------- 开始设置静态IP --------"
Ubuntu22
else 
exit
fi