<?php

/**
 * Script to check if the Database already has an instance of Moodle, using
 * the own Moodle files. This is needed for orchestration, if there is multiple
 * moodle containers, and one db container, or multiple replicated db
 * containers, so new Moodle containers dont mess the existing database.
 * Returns -1 if there is an error
 * Returns 0 if there is a Moodle table present
 * Returns 1 if there is no Moodle table present
 */

// Create the configuration options to write to the config.php file
function createConfigOptions()
{
  echo "--> Creating config options.\n";
  $config = new stdClass();
  $config->dirroot = getenv("MOODLE_DIR");
  $config->libdir = "$config->dirroot/lib";
  $config->dbtype = getenv("DB_DRIVER");
  $config->dbhost = getenv("DB_HOST");
  $config->dbuser = getenv("DB_USER");
  $config->dbpass = getenv("DB_PASS");
  $config->dbname = getenv("DB_NAME");
  $config->prefix = "mdl_";
  $config->dbsocket = "";
  $config->wwwroot = "http://localhost/moodle";
  $config->dataroot = getenv("MOODLEDATA_DIR");
  $config->admin = "admin";
  $config->directorypermissions = 0777;
  $config->dbport = getenv("DB_PORT");
  return $config;
}

// Use Moodle own libs to get the driver for the database
function getDriver(stdClass $config)
{
  echo "--> Getting driver for $config->dbtype.\n";
  if ($config->dbtype === "mysqli") {
    return @new mysqli(
      $config->dbhost,
      $config->dbuser,
      $config->dbpass,
      $config->dbname,
      $config->dbport,
      $config->dbsocket
    );
  } else if ($config->dbtype === "pgsql") {
    $connection = "user=$config->dbuser password=$config->dbpass dbname=$config->dbname host=$config->dbhost port=$config->dbport";
    return pg_connect($connection);
  }
}

function getTablesPostgresSQL(stdClass $config)
{
  echo "--> Getting tables from PosgreSQL db.\n";
  $db_conn = getDriver($config);
  $tables = [];
  $prefix = "mdl_";
  $sql = "SELECT c.relname
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace as ns ON ns.oid = c.relnamespace
    WHERE c.relname LIKE '$prefix%' ESCAPE '|'
    AND c.relkind = 'r'
    AND (ns.nspname = current_schema() OR ns.oid = pg_my_temp_schema())";
  $result = pg_query($db_conn, $sql);
  if ($result) {
    while ($row = pg_fetch_row($result)) {
      $tablename = reset($row);
      $tables[$tablename] = $tablename;
    }
    pg_free_result($result);
  }
  return $tables;
}

function getTablesMySQL(stdClass $config)
{
  echo "--> Getting tables from MySQL db.\n";
  $db_conn = getDriver($config);
  if ($db_conn->connect_errno !== 0) {
    echo "Error connecting to database.\n";
    exit(-1);
  }
  $result = $db_conn->query("SHOW TABLES");
  $tables = [];
  if ($result) {
    $len = strlen($config->prefix);
    while ($arr = $result->fetch_assoc()) {
      $tablename = reset($arr);
      $tablename = substr($tablename, $len);
      $tables[$tablename] = $tablename;
    }
  }
  return $tables;
}

echo "==> Initializing check_db script.\n";
$config = createConfigOptions();
$CFG = $config;
define('MOODLE_INTERNAL', true);
define('CLI_SCRIPT', true);
require_once($config->libdir . '/clilib.php');

$tables = null;
if ($config->dbtype === "mysqli") $tables = getTablesMySQL($config);
else if ($config->dbtype === "pgsql") $tables = getTablesPostgresSQL($config);

if ($tables) {
  if (array_key_exists("config", $tables) || array_key_exists("mdl_config", $tables)) {
    echo "--> Moodle table already on DB.\n";
    exit(0);
  } else {
    echo "--> Moodle table NOT on DB.\n";
    exit(1);
  }
}

exit(-1);
