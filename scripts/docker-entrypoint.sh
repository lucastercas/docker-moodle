#!/bin/bash

set -uo pipefail

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit -1
}

function check_db_connection() {
  # Check if database is open for connection
  echo "--> Checking if database connection on $DB_HOST:$DB_PORT is open"
  until nc -z -v -w30 "$DB_HOST" "$DB_PORT"; do
    echo "--> Waiting for database connection for 5 seconds..."
    sleep 5
  done
  echo "--> Database on $DB_HOST:$DB_PORT is open for connection"
}

function write_config() {
  echo "--> Writing configuration file"
cat > "$MOODLE_DIR"/config.php <<EOF
<?php

unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype = '${DB_DRIVER}';
\$CFG->dblibrary = 'native';
\$CFG->dbhost = '${DB_HOST}';
\$CFG->dbname = '${DB_NAME}';
\$CFG->dbuser = '${DB_USER}';
\$CFG->dbpass = '${DB_PASSWORD}';
\$CFG->prefix = 'mdl_';
\$CFG->dboptions = array(
  'dbpersist' => 0,
  'dbport' => ${DB_PORT},
  'dbsocket' => '',
);
if (empty(\$_SERVER['HTTP_HOST'])) {
  \$_SERVER['HTTP_HOST'] = '127.0.0.1:80';
}
if (isset(\$_SERVER['HTTPS']) && \$_SERVER['HTTPS'] == 'on') {
  \$CFG->wwwroot   = 'https://' . \$_SERVER['HTTP_HOST'];
} else {
  \$CFG->wwwroot   = 'http://' . \$_SERVER['HTTP_HOST'];
};
\$CFG->dataroot = '/var/www/moodledata';
\$CFG->admin = 'admin';
\$CFG->directorypermissions = 02777;
require_once(__DIR__ . '/lib/setup.php');
// No closing tag on this file
EOF
  chown www-data:www-data "$MOODLE_DIR"/config.php
}

function create_tables() {
  echo "--> Creating Moodle tables on database"
  php "$MOODLE_DIR"/admin/cli/install.php --non-interactive --agree-license  \
    --dataroot="$MOODLEDATA_DIR" \
    --dbtype="$DB_DRIVER" \
    --dbhost="$DB_HOST" \
    --dbname="$DB_NAME" \
    --dbport="$DB_PORT" \
    --dbuser="$DB_USER" \
    --dbpass=$DB_PASSWORD \
    --adminuser=$MOODLE_ADMIN_USER \
    --adminpass=$MOODLE_ADMIN_PASSWORD \
    --adminemail=$MOODLE_ADMIN_EMAIL \
    --lang=en --wwwroot=http://127.0.0.1:80 \
    --fullname=$MOODLE_NAME --shortname=$MOODLE_NAME
  result=$?
  if (( $result != 0 )); then
    err "--> Error creating database tables"
  fi
}

# Remove config.php if present, because installation can't continue
# if it's present
if [[ -f "$MOODLE_DIR/config.php" ]]; then
  echo "File config.php present. Removing it"
  rm  "$MOODLE_DIR/config.php"
fi

# Decide port for database if it is not set
if [[ -z "${DB_PORT:-}" ]]; then
  case "${DB_DRIVER}" in
    mysqli)
      export DB_PORT="3306"
      ;;
    pgsql)
      export DB_PORT="5432"
      ;;
    *)
      err "Invalid DB_DRIVER: ${DB_DRIVER}"
  esac
fi

# Check if db is open for connections
check_db_connection

# Check if DB_USER is set, if not, it should be root
if [[ -z "${DB_USER:-}"  ]]; then
  export DB_USER="root"
fi

# Check if tables on db are already created
php /scripts/check-db-tables.php
check_db_return=$?

if (( $check_db_return == 1 )) || (( $check_db_return == 2 )); then
  # If database is empty
  echo "--> Database is empty, creating tables."
  create_tables
  if [[ -f "$MOODLE_DIR"/config.php ]]; then
    rm "$MOODLE_DIR/config.php"
  fi
  write_config
elif (( $check_db_return == 0 )); then
  # If database has Moodle tables
  echo "--> Moodle already configured on database."
  write_config
elif (( $check_db_return == -1 )); then
  err "--> Error on check_db.php script"
else
  err "--> Error getting database status"
fi

echo "--> Configuration finished"

# In case a custom Moodle installation need to set extra plugins or parameters,
# it can create this file and use it
# TODO: Maybe call a bash script instead?
if [[ -f "/scripts/configure_moodle.php" ]]; then
  php /scripts/configure_moodle.php
fi

echo "==> Purging caches"
purge_cache=`php "$MOODLE_DIR"/admin/cli/purge_caches.php`
purge_result=$?
if (( purge_result != 0)); then
  err "--> Error purging caches"
fi

echo "==> Executing apache"
exec /usr/sbin/apache2ctl -DFOREGROUND
