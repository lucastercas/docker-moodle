#!/usr/bin/env bash

usage() {
  echo "Docker Image"
}

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
  echo "--- Writing $MOODLE_DIR/config.php ---"
  cmd="php $MOODLE_INSTALL_FILE --dataroot=$MOODLEDATA_DIR --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail=$MOODLE_ADMINMAIL --non-interactive --agree-license --lang=en --wwwroot=$MOODLE_WWWROOT --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME"
  echo "$cmd"; eval "$cmd"
}

skip_install_db() {
  echo "=== Skipping database install ==="
  echo "--- Writing $MOODLE_DIR/config.php ---"
  cmd="php $MOODLE_INSTALL_FILE --skip-database --dataroot=$MOODLEDATA_DIR --dbtype=$DB_DRIVER --dbhost=$DB_HOST --dbname=$DB_NAME --dbport=$DB_PORT --dbuser=$DB_USER --dbpass=$DB_PASS --adminuser=$MOODLE_ADMINUSER --adminpass=$MOODLE_ADMINPASS --adminemail=$MOODLE_ADMINMAIL --non-interactive --agree-license --lang=en --wwwroot=$MOODLE_WWWROOT --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME"
  echo "$cmd"; eval "$cmd"
}

MOODLE_INSTALL_FILE="$MOODLE_DIR/admin/cli/install.php"

while [ "$1" != "" ]; do
    case $1 in
        --skip-db )       skip_db=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo '__  __                 _ _        ____             _              '
echo '|  \/  | ___   ___   __| | | ___  |  _ \  ___   ___| | _____ _ __ '
echo '| |\/| |/ _ \ / _ \ / _` | |/ _ \ | | | |/ _ \ / __| |/ / _ \  __|'
echo '| |  | | (_) | (_) | (_| | |  __/ | |_| | (_) | (__|   <  __/ |   '
echo '|_|  |_|\___/ \___/ \__,_|_|\___| |____/ \___/ \___|_|\_\___|_|   '

wait_db_connection

if [ -z "$skip_db" ]; then
  install_db
else
  skip_install_db
fi
echo "--- Database Installation Finished ---"
chown root:www-data "$MOODLE_DIR/config.php"

php /var/www/html/moodle/admin/cli/purge_caches.php
exec /usr/sbin/apache2ctl -DFOREGROUND
