#!/bin/bash
set -e

echo "[MariaDB INIT] Initializing..."
ls /var/lib/mysql/

if [ ! -f "/var/lib/mysql/ibtmp1" ]; then
    echo "[MariaDB INIT] Installing system tables..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

    mysqld_safe --skip-networking --user=mysql &
    pid="$!"

    echo "[MariaDB INIT] Waiting for server to start..."
    while ! mysqladmin ping --silent; do
        sleep 1
    done

    echo "[MariaDB INIT] Creating DB and user..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
else
    echo "[MariaDB INIT] Existing DB found, skipping initialization"
fi

echo "[MariaDB INIT] Launching final mysqld"
exec $@
