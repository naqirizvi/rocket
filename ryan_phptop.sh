#!/bin/bash

echo 'Mayday! Ryan is pushing updates for FPM as well so revisit next time.'
exit 1

# PHPTOP 2.5.0
# 2022-2024 Ryan Flowers for Rocket.net
# 
# 2.5.0 4/26/24 Rewrote significant portions. Detects php-fpm or lsphp and displays it.
#               Simplified MySQL to "number of processes" which includes sleeping
#               Greatly imroved formatting of output for clarity, added hostname and PHP Top version
#                               Added various comments for Future Ryan
#
# 2.0.2 2/28/24 Solved for blank $domain. If $domain is empty, use CDN url.
#               Added "t" option to tail nginx direclty from phptop


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

mysqllist=$(mysqladmin pro |  cut -d\| -f3,6,9 |sed '/root/d')

divider="======================================================================================================================="
echo $(hostname)" - PHPTop 2.5 - " $(uptime)
echo $divider

#generate a CSV list of number of processes, username, php handler for all users but root
for user in $(ps aux | grep [p]hp|sed '/root/d'| sort| awk '{ print $1" "$11}' | cut -d: -f1| uniq -c | sort -n|sed 's/   //g'| sed 's/ /,/g'|sed 's/^,,//g'| sort -nr| head -04)

do
luser=$(echo $user | cut -d, -f2) #luser = username
puser=$(echo $user | cut -d, -f1) #puser = number of processes
huser=$(echo $user | cut -d, -f3) #huser = php handler for user
domain=$(grep $luser /etc/userdomains | cut -d: -f1| sed -e '/onrocket/d' -e '/wpdns/d'| head -01)

#treat edge cases where domain isn't in the variable
if [ -z $domain ]
        then domain=$(grep $luser /etc/userdomains | cut -d: -f1)
fi

#detect wp-rocket preload and set the variable if it's detected. Otherwise it is empty
wppreload=$(echo $wpplist | grep  $domain -l >/dev/null 2>&1  && echo -e "\e[41mWP-Rocket-Preload\e[0m" )

#Format output with printf, and print a header
echo "## Username  Domain Name                        PHP Handler  Flags"
echo "   -------- ----------------------------------  -----------  -----------------"
printf "%-2s %-8s %-35s %-12s %-20s\n"  $puser $luser  $domain $huser $wppreload

#gather stats from NGINX access log and format/display with printf
printf "\n"
echo  "Top 5 IPs                                        | Top 5 URLs                                             |"
echo  "-------------------------------------------------|--------------------------------------------------------|"
topips=$(grep $domain /var/log/nginx/access.log | sed "/$(hostname -i|awk '{ print $NF }' )/d" |  tail -0500 |awk '{ print $1 }'  | sort | uniq -c | sort -nr | head -05)
topurl=$(grep $domain /var/log/nginx/access.log|  sed "/$(hostname -i)/d"| tail -0500  |awk '{ print $9 }'| cut -c 1-80  | sort | uniq -c | sort -nr | head -05)
paste <(echo "$topips") <(echo "$topurl") | while IFS= read -r line; do
    printf "%-3s %-45s"\|" %-3s %-51s"\|"\n" $line
done

#Display number of mysql processes for this user including Sleeping
mysqlprocs=$(echo "$mysqllist" | grep $luser| wc -l )
mysqlprocs=${mysqlprocs:-0} #clever trick to assign 0 to variable if there were no results. Thanks, ChatGPT.
printf "\n"
echo "MySQL Queries for $luser: "$mysqlprocs

echo $divider
done
}

clear
#Scan for input 
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
