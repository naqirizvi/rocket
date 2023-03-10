#!/bin/bash
if [[ $(/usr/bin/redis-cli -s REDISDIR/redis.sock ping 2>/dev/null) == "PONG" ]]
then
  echo 'Redis is already running'
else
  echo 'Starting Redis'
  screen -L -S redis -d -m /usr/bin/redis-server REDISDIR/redis.conf
fi
