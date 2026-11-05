set -euo pipefail

APP_IP="$1"
BASE="$2"
USUARIO="$3"
SENHA="$4"

systemctl stop mariadb

chown -R mysql:mysql /var/lib/mysql

sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
  /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl start mariadb

mariadb -e "CREATE DATABASE IF NOT EXISTS ${BASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

mariadb -e "CREATE USER IF NOT EXISTS '${USUARIO}'@'${APP_IP}' IDENTIFIED BY '${SENHA}';"

mariadb -e "GRANT ALL PRIVILEGES ON ${BASE}.* TO '${USUARIO}'@'${APP_IP}'; FLUSH PRIVILEGES;"
