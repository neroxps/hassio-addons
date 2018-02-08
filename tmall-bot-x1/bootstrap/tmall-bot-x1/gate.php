<?php
require_once __DIR__.'/aligenies_request.php';
$chars = md5(uniqid(mt_rand(), true));
$uuid  = substr($chars,0,8) . '-';
$uuid .= substr($chars,8,4) . '-';
$uuid .= substr($chars,12,4) . '-';
$uuid .= substr($chars,16,4) . '-';
$uuid .= substr($chars,20,12);

$poststr = file_get_contents("php://input");
$obj = json_decode($poststr);
$messageId = $uuid;

test($poststr);


$data=array();
$rs = $db->query("SELECT* FROM oauth_devices  WHERE del!='1'");
while($row = $rs->fetch()){
    array_push($data,json_decode($row['jsonData'], true));
}
$data = json_encode($data);



switch($obj->header->namespace)
{
	case 'AliGenie.Iot.Device.Discovery':

	$str='{
    header: 
    {
        namespace: "AliGenie.Iot.Device.Discovery",
        name: "DiscoveryDevicesResponse",
        messageId: "%s",
        payLoadVersion: 1
    },
    payload: {
        devices: '.$data.'
        }
    }';
  

	$resultStr = sprintf($str,$messageId);
	break;

case 'AliGenie.Iot.Device.Control':
	$result = Device_control($obj);
	if($result->result == "True" )
	{
		$str='{
  			"header":{
  			    "namespace":"AliGenie.Iot.Device.Control",
  			    "name":"%s",
  			    "messageId":"%s",
 			     "payLoadVersion":1
			   },
			   "payload":{
			      "deviceId":"%s"
			    }
			}';
		$resultStr = sprintf($str,$result->name,$messageId,$result->deviceId);
		//error_log($resultStr);

	}
	else
	{
		$str='{
			  "header":{
			      "namespace":"AliGenie.Iot.Device.Control",
			      "name":"%s",
			      "messageId":"%s",
			      "payLoadVersion":1
			   },
			   "payload":{
			        "deviceId":"%s",
			         "errorCode":"%s",
			         "message":"%s"
			    }
			}';
		$resultStr = sprintf($str,$result->name,$messageId,$result->deviceId,$result->errorCode,$result->message);
	}
	break;
        
 case 'AliGenie.Iot.Device.Query':
	$result = Device_status($obj);
        
     test($result->name);
     test($result->deviceId);
     test($result->powerstate);
     test($result->properties);
    
        
        
      if($result->powerstate=="on" or $result->powerstate=="off"){
      $properties='{
	   	              "name":"powerstate",
	   	              "value":"%s"
		           }';
      }else{
          $properties='{
	   	              "name":"powerstate",
	   	              "value":"on"
		           		},
                       {
	   	              "name":"temperature",
	   	              "value":"%s"
		           },
                   {"name":"humidity",
                   "value":"30",
                   }';
      }
        
        
    
        
	if($result->result == "True" )
	{
		$str='{
  			"header":{
  			    "namespace":"AliGenie.Iot.Device.Query",
  			    "name":"%s",
  			    "messageId":"%s",
 			     "payLoadVersion":1
			   },
			   "payload":{
			      "deviceId":"%s"
                           },
			   "properties":[
			       '.$properties.'
                   
                   ]

			}';
		$resultStr = sprintf($str,$result->name,$messageId,$result->deviceId,$result->powerstate);
        test($resultStr);

	}
	else
	{
		$str='{
			  "header":{
			      "namespace":"AliGenie.Iot.Device.Query",
			      "name":"%s",
			      "messageId":"%s",
			      "payLoadVersion":1
			   },
			   "payload":{
			        "deviceId":"%s",
			         "errorCode":"%s",
			         "message":"%s"
			    }
			}';
		$resultStr = sprintf($str,$result->name,$messageId,$result->deviceId,$result->errorCode,$result->message);
        
        
	}
	break;
default:
	$resultStr='Nothing return,there is an error~!!';
}
error_log('-------');
error_log('----get-request---');
error_log($poststr);
error_log('----reseponse---');
error_log($resultStr);
echo($resultStr);



function test($value){
	$db = new PDO(dsn, user, pwd);
	$db->exec("INSERT INTO oauth_test SET value = '$value'");

}






?>
