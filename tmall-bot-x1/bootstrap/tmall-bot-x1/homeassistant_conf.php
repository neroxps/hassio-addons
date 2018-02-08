<?php
const URL="%%{HOMEASSISTANT_URL}%%";
const PASS="%%{YOURHOMEASSITANTPASSWORD}%%";


//数据库参数脚本会自动修改，用户无需理会
const dsn ='mysql:dbname=%%{MYSQL_DB_NAME}%%;host=%%{MYSQL_HOST}%%';
const user='%%{MYSQL_USER}%%';
const pwd ='%%{MYSQL_PASSWD}%%';
$db = new PDO(dsn, user, pwd);



// 新浪SAE数据库
// $dsn = 'mysql:dbname='.SAE_MYSQL_DB.';host='.SAE_MYSQL_HOST_M;
// $user = SAE_MYSQL_USER;
// $pwd = SAE_MYSQL_PASS;
// $db = new PDO(dsn, user, pwd);

?>
