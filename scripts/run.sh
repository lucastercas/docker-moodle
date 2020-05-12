#!/usr/bin/env bash

wait_db_connection() {
    DB_PORT=$1
    echo "==> Checking if database connection on $DB_HOST:$DB_PORT is open"
    until nc -z -v -w30 "$DB_HOST" "$DB_PORT"; do
        echo "==> Waiting for database connection for 5 seconds..."
        sleep 5
    done
    echo "==> Database on $DB_HOST:$DB_PORT is open for connection"
}

install_db() {
    DB_PORT=$1
    echo "==> Creating database and writing config.php"
    cmd="php $MOODLE_DIR/admin/cli/install.php --dataroot=$MOODLEDATA_DIR --dbtype=$DB_TYPE --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail=$MOODLE_ADMINMAIL --non-interactive --agree-license --lang=en --wwwroot=$MOODLE_WWWROOT --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME"
    echo "==> $cmd"; eval "$cmd"
}

if [ "$DB_TYPE" == "mysqli" ]; then
    DB_PORT="3306"
elif [ "$DB_TYPE" == "pgsql" ]; then
    DB_PORT="5432"
fi

wait_db_connection "$DB_PORT"

php-cgi -f configure_db.php dbtype="$DB_TYPE" dbhost="$DB_HOST" dbuser="$DB_USER" dbpass="$DB_PASS" dbname="$DB_NAME" dbport="$DB_PORT"

if [ $? == 1 ]; then
    install_db $DB_PORT
    elif [ $? == -1 ]; then
    exit -1;
fi

echo "==> Configuration finished"
chown root:www-data "$MOODLE_DIR/config.php"
chmod -R 02777 /var/www/html/moodledata

echo "==> Purging caches"
php /var/www/html/moodle/admin/cli/purge_caches.php

echo "==> Executing apache"
exec /usr/sbin/apache2ctl -DFOREGROUND
