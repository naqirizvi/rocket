[ -d "wp-content/plugins/cache-enabler" ] && $phpbin $wpbin cache-enabler clear
[ -d "wp-content/plugins/autoptimize" ] && $phpbin $wpbin autoptimize clear
[ -d "wp-content/plugins/elementor" ] && $phpbin $wpbin elementor flush-css
[ -d "wp-content/themes/Avada" ] && $phpbin $wpbin fusion clear_caches
$phpbin $wpbin cache flush $wpcliopt && $phpbin $wpbin rewrite flush $wpcliopt && rm -rf wp-content/cache
