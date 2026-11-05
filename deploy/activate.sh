#!/usr/bin/env bash
set -e

mkdir -p /var/www/framework-site/current
tar -xzf /tmp/site.tar.gz -C /var/www/framework-site/current
install -m 644 /tmp/nginx.conf /etc/nginx/sites-available/framework-site
ln -sfn /etc/nginx/sites-available/framework-site /etc/nginx/sites-enabled/framework-site
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx
