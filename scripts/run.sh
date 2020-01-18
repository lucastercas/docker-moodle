#!/usr/bin/env bash

wait_db_connection() {
  echo "=== Checking if database connection on $DB_HOST:$DB_PORT is open ==="
  until nc -z -v -w30 "${DB_HOST}" "${DB_PORT}"; do
    echo "--> Waiting for database connection for 5 seconds..."
    sleep 5
  done
  echo "--- Database on $DB_HOST:$DB_PORT is open for connection"
}

install_db() {
  echo "=== Setting up Moodle table on database ==="
  echo "--- Writing /var/www/html/moodle/config.php ---"
  php $MOODLE_ADMIN_INSTALL --dataroot=$MOODLEDATA_DIR/moodledata --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail="$MOODLE_ADMINMAIL" --non-interactive --agree-license --lang=en --wwwroot="$MOODLE_WWWROOT" --fullname="$MOODLE_NAME" --shortname="$MOODLE_NAME"
}

skip_install_db() {
  echo "=== Skipping database install ==="
  echo "--- Writing /var/www/html/moodle/config.php ---"
  php $MOODLE_ADMIN_INSTALL --skip-database --dataroot=$MOODLEDATA_DIR/moodledata --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail="$MOODLE_ADMINMAIL" --non-interactive --agree-license --lang=en --wwwroot="$MOODLE_WWWROOT" --fullname="$MOODLE_NAME" --shortname="$MOODLE_NAME"
}

MOODLE_ADMIN_INSTALL=/var/www/html/moodle/admin/cli/install.php

echo '__  __                 _ _        ____             _              '
echo '|  \/  | ___   ___   __| | | ___  |  _ \  ___   ___| | _____ _ __ '
echo '| |\/| |/ _ \ / _ \ / _` | |/ _ \ | | | |/ _ \ / __| |/ / _ \  __|'
echo '| |  | | (_) | (_) | (_| | |  __/ | |_| | (_) | (__|   <  __/ |   '
echo '|_|  |_|\___/ \___/ \__,_|_|\___| |____/ \___/ \___|_|\_\___|_|   '

wait_db_connection

if [ -z "${SKIP_DB_INSTALL}" ]; then
  install_db
else
  skip_install_db
fi
chown root:www-data /var/www/html/moodle/config.php


exec /usr/sbin/apache2ctl -DFOREGROUND
