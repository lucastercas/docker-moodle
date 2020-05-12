<?php

function createConfigOptions()
{
  $config = new stdClass();
  $config->dirroot = "/var/www/html/moodle";
  $config->libdir = "$config->dirroot/lib";
  $config->dbtype = $_GET["dbtype"];
  $config->dbhost = $_GET["dbhost"];
  $config->dbuser = $_GET["dbuser"];
  $config->dbpass = $_GET["dbpass"];
  $config->dbname = $_GET["dbname"];
  $config->prefix = "mdl_";
  $config->dbsocket = "";
  $config->wwwroot = "http://localhost/moodle";
  $config->dataroot = "/var/www/html/moodledata";
  $config->admin = "admin";
  $config->directorypermissions = 0777;
  switch ($config->dbtype) {
    case "mysql":
      $config->dbport = "3306";
      break;
    case "pgsql":
      $config->dbport = "5432";
      break;
  }
  return $config;
}

function getDriver(stdClass $config)
{
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
    echo "$connection.\n";
    return pg_connect($connection);
  }
}

function getTablesPostgresSQL(stdClass $config)
{
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
  $db_conn = getDriver($config);
  echo "==> Getting database tables.\n";
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

function createConfigFile(stdClass $config)
{
  echo "==> Creating config file.\n";
  require_once($config->libdir . '/dml/moodle_database.php');
  require_once($config->libdir . '/installlib.php');
  $database = moodle_database::get_driver_instance($config->dbtype, "native");
  $database->connect(
    $config->dbhost,
    $config->dbuser,
    $config->dbpass,
    $config->dbname,
    $config->prefix,
    [
      "dbpersist" => 0,
      "dbport" => $config->dbport,
      "dbsocket" => "",
    ]
  );
  $content = install_generate_configphp($database, $config);
  $file = fopen(__DIR__ . "/config.php", "w");
  fwrite($file, $content);
  fclose($file);
  echo "==> Configuration file create and written to " . __DIR__ . "/config.php.\n";
}


$config = createConfigOptions();
$CFG = $config;
define('MOODLE_INTERNAL', true);
define('CLI_SCRIPT', true);
require_once($config->libdir . '/clilib.php');

$tables = null;
if ($config->dbtype === "mysqli")
  $tables = getTablesMySQL($config);
else if ($config->dbtype === "pgsql")
  $tables = getTablesPostgresSQL($config);

if ($tables["config"] || $tables["mdl_config"]) {
  echo "==> Database tables already created.\n";
  if (file_exists(__DIR__ . "/config.php")) {
    echo "==> Config file already created.\n";
  } else {
    echo "==> Config file NOT created.\n";
    createConfigFile($config);
  }
  echo "==> Exiting.\n";
  exit(0);
} else {
  echo "==> Database tables NOT created.\n";
  if (file_exists(__DIR__ . "/config.php")) {
    echo "==> Config file already created.\n";
    unlink(__DIR__ . "/config.php");
    exit(1);
  } else {
    echo "==> Config file NOT created.\n";
    exit(1);
  }
}

exit(0);
