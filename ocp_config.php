<?php
define( 'WP_REDIS_CONFIG', [
    'token' => "$ocp_key",
    'host' => "/home/$user/redis/redis.sock",
    'database' => $redis_db,
    'maxttl' => 3600 * 24 * 7,
    'timeout' => 1.0,
    'read_timeout' => 1.0,
    'split_alloptions' => false,
    'debug' => false,
]);
