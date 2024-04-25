#!/bin/bash

echo 'Mayday! Ryan is pushing updates for FPM as well so revisit next time.'
exit 1
# PHPTOP 2.0.2
# 2022-2024 Ryan Flowers for Rocket.net 
# 
# 2.0.2 2/29/24 Solved for blank $domain. If $domain is empty, use CDN url. 
#               Added "t" option to tail nginx direclty from phptop
#				Solved for wildcard domains by stripping *. from them.

#IDEA: Add lvelimit options.  
#IDEA: Option to kill all procs for user

delay=5
iteration=0

genlist(){
wpplist=$(grep "WP Rocket/Preload" -i /var/log/nginx/access.log |tail -1000 | awk '{ print $7 }' | sort | uniq | tail)
iteration=0
}

phptop(){

    if ((iteration % 10 == 0)); then
      genlist
    fi
((iteration++))
mysqllist=$(mysqladmin pro | grep Query | cut -d\| -f3,6,9 |sed '/root/d')


uptime
echo "## Username  Domain Name      PID  TIME Process"
echo "   -------- -----------      ----- ---- -------"
for user in $(ls -l /proc/*/exe 2>&1| sed '/root/d'| grep [p]hp |awk '{ print $3 }' | sort | uniq -c | sort -nr | head -04 |awk '{ print $1","$2 }')
do
luser=$(echo $user | cut -d, -f2)
puser=$(echo $user | cut -d, -f1)
domain=$(grep $luser /etc/userdomains | cut -d: -f1| sed -e '/onrocket/d' -e '/wpdns/d'| head -01)
if [[ $domain == *\.* ]];
        then domain=$(echo $domain | sed 's/\*\.//')
fi
if [ -z $domain ]
        then domain=$(grep $luser /etc/userdomains | cut -d: -f1)
fi
wppreload=$(echo $wpplist | grep  $domain -l >/dev/null 2>&1  && echo -e "\e[41mWP-Rocket Preload\e[0m" )
echo   $(printf "%02d\\n" $puser)" "$luser" " $domain $wppreload
ps a -u $luser   |grep [p]hp| grep [h]ome |awk '{ print $5 }' |sort | uniq -c | sort -n | sed 's/^/            \|--------------- /'
echo "            - TOP 5 IPs -       - TOP 5 URLs -"
paste <(grep $domain /var/log/nginx/access.log | sed "/$(hostname -i|awk '{ print $NF }' )/d" | tail -0500 |awk '{ print $1 }'  | sort | uniq -c | sort -nr | head -05) <(grep $domain /var/log/nginx/access.log| sed "/$(hostname -i)/d"| tail -0500  |awk '{ print $9 }'| cut -c 1-80  | sort | uniq -c | sort -nr | head -05) |column -t| sed 's/^/            /'
echo "MySQL Queries:"
echo "$mysqllist" | grep $luser | sort | uniq -c | sort -nr
echo "-----------------------------------------------------------"
done
#echo " "
#echo "MySQL Users:"
#mysqladmin pro | grep Query |awk '{ print $4 " " $10 }' |sed '/root/d'
#mysqladmin pro | grep Query | cut -d\| -f3,6,9 |sed '/root/d'
}
clear
while true; do  phptop; read -s -n 1 -t $delay input > /dev/null;
if [ "$input" = 'q' ]; then exit 0 ;fi
if [ "$input" = 's' ]; then echo "Enter new time delay in seconds:"; read -s -n 1 delay >/dev/null  ;fi
if [ "$input" = 't' ]; then (
ctrl_c() {
	echo "Returning to phptop"
	sleep 1
     }
trap ctrl_c INT
read -p "Enter IP or Domain to tail NGINX log:" tailgrep ;tail -f /var/log/nginx/access.log | grep $tailgrep )
fi
clear;done
