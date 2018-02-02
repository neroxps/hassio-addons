<?php

$dsn = 'mysql:dbname=%%{MYSQL_DB_NAME}%%;host=%%{MYSQL_HOST}%%';
$user = '%%{MYSQL_USER}%%';
$pwd = '%%{MYSQL_PASSWD}%%';
// error reporting (this is a demo, after all!)
ini_set('display_errors',1);error_reporting(E_ALL);

// Autoloading (composer is preferred, but for this example let's just do this)
//require_once('oauth2-server-php/src/OAuth2/Autoloader.php');
//OAuth2_Autoloader::register();

require_once('oauth2-server-php/src/OAuth2/Autoloader.php');
OAuth2\Autoloader::register();

// $dsn is the Data Source Name for your database, for exmaple "mysql:dbname=my_oauth2_db;host=localhost"
//$storage = new OAuth2_Storage_Pdo(array('dsn' => $dsn, 'username' => $user, 'password' => $pwd));


$storage = new OAuth2\Storage\Pdo(array('dsn' => $dsn, 'username' => $user, 'password' => $pwd));






// Pass a storage object or array of storage objects to the OAuth2 server class
$server = new OAuth2\Server($storage);

// Add the "Client Credentials" grant type (it is the simplest of the grant types)
$server->addGrantType(new OAuth2\GrantType\ClientCredentials($storage));
?>
