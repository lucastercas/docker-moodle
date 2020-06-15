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
function createConfigOptions()
{
  echo "--> Creating config options.\n";
  $config = new stdClass();
  $config->dirroot = getenv("MOODLE_DIR");
  $config->libdir = "$config->dirroot/lib";
  $config->dbtype = getenv("DB_DRIVER");
  $config->dbhost = getenv("DB_HOST");
  $config->dbuser = getenv("DB_USER");
  $config->dbpass = getenv("DB_PASSWORD");
  $config->dbname = getenv("DB_NAME");
  $config->prefix = "mdl_";
  $config->dbsocket = "";
  $config->wwwroot = "http://localhost";
  $config->dataroot = getenv("MOODLEDATA_DIR");
  $config->admin = getenv("MOODLE_ADMIN_USER");
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

function getTablesPostgresSQL()
{
  global $CFG;
  echo "--> Getting tables from PosgreSQL db.\n";
  try {
    $db_conn = getDriver($CFG);
  } catch( Exception $e ) {
    echo "Error connecting to MySQL database: $e";
    return null;
  }
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
  echo "--> Returning tables.\n";
  return $tables;
}

function getTablesMySQL()
{
  global $CFG;
  echo "--> Getting tables from MySQL db.\n";
  try {
    $db_conn = getDriver($CFG);
  } catch( Exception $e ) {
    echo "Error connecting to MySQL database: $e";
    return null;
  }
  $result = $db_conn->query("SHOW TABLES");
  $tables = [];
  if ($result) {
    $len = strlen('mdl_');
    while ($arr = $result->fetch_assoc()) {
      $tablename = reset($arr);
      $tablename = substr($tablename, $len);
      $tables[$tablename] = $tablename;
    }
  }
  echo "--> Returning tables.\n";
  return $tables;
}

echo "==> Initializing check_db script.\n";
$CFG = createConfigOptions();
define('MOODLE_INTERNAL', true);
define('CLI_SCRIPT', true);
require_once(getenv("MOODLE_DIR") . '/lib/clilib.php');

$tables = null;
if ($CFG->dbtype === "mysqli") $tables = getTablesMySQL();
else if ($CFG->dbtype === "pgsql") $tables = getTablesPostgresSQL();

if ($tables) {
  if (array_key_exists("config", $tables) || array_key_exists("mdl_config", $tables)) {
    # If database alreay has moodle tables
    exit(0);
  } else {
    # Database has tables, but not Moodle ones
    exit(1);
  }
} else {
  # No tables on database.
  exit (2);
}
exit(-1); 

