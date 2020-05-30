#!/usr/bin/env bash

set -uo pipefail

wait_db_connection() {
  DB_PORT=$1
  echo "--> Checking if database connection on $DB_HOST:$DB_PORT is open"
  until nc -z -v -w30 "$DB_HOST" "$DB_PORT"; do
    echo "--> Waiting for database connection for 5 seconds..."
    sleep 5
  done
  echo "--> Database on $DB_HOST:$DB_PORT is open for connection"
}

skip_tables() {
  echo "--> Skipping table creation, writing config.php"
  cmd="php $MOODLE_DIR/admin/cli/install.php --skip-database --dataroot=$MOODLEDATA_DIR --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail=$MOODLE_ADMINMAIL --non-interactive --agree-license --lang=en --wwwroot=$MOODLE_WWWROOT --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME"
  eval "$cmd"
}

create_tables() {
  echo "--> Creating tables and writing config.php"
  cmd="php $MOODLE_DIR/admin/cli/install.php --dataroot=$MOODLEDATA_DIR --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail=$MOODLE_ADMINMAIL --non-interactive --agree-license --lang=en --wwwroot=$MOODLE_WWWROOT --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME"
  eval "$cmd"
}

if [ "$DB_DRIVER" == "mysqli" ]; then
  export DB_PORT="3306"
elif [ "$DB_DRIVER" == "pgsql" ]; then
  export DB_PORT="5432"
fi
wait_db_connection "$DB_PORT"

php /scripts/check_db.php
if [ $? == 0 ]; then
  skip_tables
elif [ $? == 1 ]; then
  create_tables
elif [ $? == -1 ]; then
  exit -1;
fi

echo "--> Configuration finished"
chown www-data:www-data "$MOODLE_DIR/config.php"

# TODO: Maybe call a bash script instead?
# In case a custom Moodle installation need to set extra plugins or parameters,
# it can create this file and use it
if [ -f "/scripts/configure_moodle.php" ]; then
  php /scripts/configure_moodle.php
fi

echo "==> Purging caches"
php "$MOODLE_DIR"/admin/cli/purge_caches.php

echo "==> Executing apache"
exec /usr/sbin/apache2ctl -DFOREGROUND
