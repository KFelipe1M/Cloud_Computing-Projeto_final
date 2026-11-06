set -euo pipefail

DB_HOST="$1"
DB_PASS="$2"
ADMIN_PASS="$3"
DOMINIO="$4"

cd /var/www

if [ ! -f nextcloud/occ ]; then
  curl -sLO https://download.nextcloud.com/server/releases/latest.tar.bz2
  tar xjf latest.tar.bz2
fi

chown -R www-data:www-data /var/www/nextcloud /srv/nextcloud-data

OCC="sudo -u www-data php /var/www/nextcloud/occ"

if [ ! -f /var/www/nextcloud/config/config.php ]; then
  $OCC maintenance:install --database mysql \
    --database-name nextcloud \
    --database-host "$DB_HOST" \
    --database-user ncuser \
    --database-pass "$DB_PASS" \
    --admin-user admin \
    --admin-pass "$ADMIN_PASS" \
    --data-dir /srv/nextcloud-data
fi

$OCC config:system:set trusted_domains 1 --value="$DOMINIO"

$OCC config:system:set trusted_proxies 0 --value=10.10.10.10

cat > /etc/apache2/sites-available/nextcloud.conf <<'EOF'
<VirtualHost *:80>
  DocumentRoot /var/www/nextcloud
  <Directory /var/www/nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
  </Directory>
</VirtualHost>
EOF

a2dissite 000-default || true
a2ensite nextcloud
a2enmod rewrite headers env dir mime

sed -i 's/^memory_limit = .*/memory_limit = 512M/' \
  /etc/php/*/apache2/php.ini

systemctl restart apache2
