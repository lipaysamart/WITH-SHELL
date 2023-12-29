#!/bin/bash
######################
# author: Ethan
# email: lipaysamart@gmail.com
# usage: 监控网路丢包率和延迟并上传至 PushGateway -s 是一个ping包的大小 -W 是延迟timeout -c 是发生多少数据包。
# example：
######################
# 设置 ping 命令执行的次数（c_times）和需要 ping 的 IP 地址列表（ip_arr）。
# 遍历 IP 列表，对每个 IP 地址执行 ping 命令，将 ping 响应存储在 result 变量中。
# 检查 result 是否为空。如果是，则表示 ping 失败。在这种情况下，将 drop_packge 的值设置为 101，表示丢失所有数据包，将 current_time 的值设置为 1000，表示无响应。然后，使用 curl 命令将这些值作为二进制数据发送到 Prometheus metrics API。
# 如果 result 不为空，则提取丢包率（lostpk）和往返时延（rtt）并计算出它们的平均值。然后，将 drop_packge 和 current_time 的值分别设置为丢包率和平均往返时间，并使用 curl 命令将这些值作为二进制数据发送到 Prometheus metrics API。
# 在每次循环中，打印出 IP 地址、丢包率和平均往返时间的值。

#ping发包数
c_times=100
#IP列表数组，多IP定义（ 10.20.30.4  40.30.20.10 ） 
ip_arr=( 172.20.3.226 )
for (( i = 0; i < ${#ip_arr[@]}; ++i ))
 do
         result=`timeout 16 ping -q -A -s 200 -W 250 -c $c_times   ${ip_arr[i]}|grep transmitted|awk '{print $6,$10}'`
         if [ -z "$result" ]
         then
               value_lostpk=101
               value_rrt=1000
               echo "drop_packge ${value_lostpk}" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/ping/instance/${ip_arr[i]}
               echo "current_time  ${value_rrt}" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/ping/instance/${ip_arr[i]}
         else
               lostpk=$(echo $result|awk '{print $1}')
               rrt=$(echo $result|awk '{print $2}')
               value_lostpk=$(echo $lostpk | sed 's/%//g')
               value_rrt=$(echo $rrt |sed 's/ms//g')
               #value_rrt=$(($value_rrt/$c_times))
               value_rrt=$(printf "%.5f" `echo "scale=5;$value_rrt/$c_times"|bc`)
               echo "drop_packge ${value_lostpk}" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/ping/instance/${ip_arr[i]}
               echo "current_time ${value_rrt}" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/ping/instance/${ip_arr[i]}
         fi
         echo  ${ip_arr[i]}"==="$value_lostpk"==="$value_rrt
 done
