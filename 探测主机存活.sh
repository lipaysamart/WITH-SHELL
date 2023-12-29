#!/bin/bash
#####################
# author: Ethan
# email: lipaysamart@gmail.com
# usage: 循环Ping IP地址脚本。
# example：bash ping.sh 172.16.10.
#####################

for i in {1..255}
    do
        #PING并保留丢包数
        p=`ping -c 1 -w 1 ${1}.${i}|grep loss|awk '{print $6}'|awk -F "%" '{print $1}'`
            #因为只PING一次，丢包数为0则表示成功，否则失败
            if [ $p -eq 0 ]
                then
                    echo "${i}|PING成功，网络通畅" >> ./ipcheckdown.txt
                else
                    echo "${i}|失败，网络不通畅" >> ./ipcheckdown.txt
            fi
    done
