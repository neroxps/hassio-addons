<?php
require_once '../homeassistant_conf.php';

$dsn = 'mysql:dbname=%%{MYSQL_DB_NAME}%%;host=%%{MYSQL_HOST}%%';
$user = '%%{MYSQL_USER}%%';
$pwd = '%%{MYSQL_PASSWD}%%';
$db = new PDO($dsn, $user, $pwd);




$v = isset($_GET['v']) ? $_GET['v'] : "v";
if ($v=="v"){
	echo "{\"code\" : \"v\",\"Msg\":\"v\"}";
}elseif ($v=="add"){
    //echo "{\"zrs\" : \"1545\",\"xzwplqd\":\"561\",\"lqzb\":\"321\"}";
    //$list = getComments();
    //echo json_encode ($list);
    $deviceName=$_REQUEST['deviceName'];
    $deviceId=$_REQUEST['deviceId'];
    $jsonData=$_REQUEST['jsonData'];
    
    
    $rs = $db->query("SELECT* FROM oauth_devices WHERE deviceId='$deviceId'");
	$row = $rs->fetch();

	//echo count($row);
    
    if(count($row)==1){
    
    	$count = $db->exec("INSERT INTO oauth_devices SET deviceName = '$deviceName',deviceId='$deviceId',jsonData='$jsonData'");
    
    	if($count=="1"){
        	echo "{\"code\" : \"ok\",\"Msg\":\"增加成功！\"}";
    
    	}
    	else{
    		echo "{\"code\" : \"err\",\"Msg\":\"增加失败！\"}";
    	}
    }
    else{
    	echo "{\"code\" : \"err\",\"Msg\":\"该设备已存在！\"}";
    }
    //echo "{\"deviceName\" : \"$deviceName\",\"deviceId\":\"$deviceId\",\"jsonData\":\"$count\"}";
}elseif ($v=="getList"){

    
    $rs = $db->query("SELECT* FROM oauth_devices WHERE del!='1'");
	$data=array();
	while($row = $rs->fetch()){
      array_push($data,json_decode($row['jsonData'], true));
    }
	$a=array(
		"code"=>"ok",
    	"Msg"=>"获取成功！",
    	"data"=>$data
	);

	echo json_encode($a);
    //echo "{\"deviceName\" : \"$deviceName\",\"deviceId\":\"$deviceId\",\"jsonData\":\"$count\"}";
}
elseif ($v=="del"){
    
    $deviceId=$_REQUEST['deviceId'];
    
    $rs = $db->exec("DELETE FROM oauth_devices WHERE deviceId='$deviceId'");
    
    
    if($rs==1){

        $rs = $db->query("SELECT* FROM oauth_devices WHERE del!='1'");
		$data=array();
		while($row = $rs->fetch()){
      		$jsonData=$row['jsonData'];
      		$jsonData=json_decode($jsonData, true);
      		array_push($data,$jsonData);
    	}
		$a=array(
			"code"=>"ok",
    		"Msg"=>"删除成功！",
    		"data"=>$data
		);

	    
    
    }else{
        $a=array(
		"code"=>"err",
    	"Msg"=>"删除失败！"
	);
    
    }
    
	

	echo json_encode($a);
    //echo "{\"deviceName\" : \"$deviceName\",\"deviceId\":\"$deviceId\",\"jsonData\":\"$count\"}";
}


elseif ($v=="getNotice"){//到我的服务器获取版本更新完善的消息，不会收集信息请放心使用！


    $url = "http://qebapp.applinzi.com/device/notice.php?version=3";
	getdata($url);

}
elseif ($v=="getDevice1"){
    $url = URL."/api/states?api_password=".PASS;
	$data = getdata1($url);
    $arr = json_decode($data);
    $num = count($arr);
	$deviveList=array();
    $deviceTypeList=array();
	for($i=0;$i<$num;++$i){ 
        $deviceType = explode('.',$arr[$i]->entity_id)[0];
        if(isset($deviveList[$deviceType])){
        	array_push($deviveList[$deviceType],$arr[$i]);
        }
        else{
            $deviveList[$deviceType] = array();
            array_push($deviceTypeList,$deviceType);
            array_push($deviveList[$deviceType],$arr[$i]);    
        }   
    }
$ret=array();

for($i=0;$i<count($deviceTypeList);++$i){
    array_push($ret,array(
        			"deviceType"=>$deviceTypeList[$i],
        			"deviveList"=>$deviveList[$deviceTypeList[$i]]
    ));
   
}

	echo json_encode($ret);
    

}
elseif ($v=="getDevice"){
    $url = URL."/api/states?api_password=".PASS;
	$data = getdata1($url);
    $arr = json_decode($data);
    $num = count($arr);
	$deviveList=array();

	for($i=0;$i<$num;++$i){ 

        $deviceType = explode('.',$arr[$i]->entity_id)[0];

        	$title=$arr[$i]->attributes->friendly_name;
            $value=$arr[$i]->entity_id;

        	array_push($deviveList,array(
            						"title"=>$title,
                					"value"=>$value
            ));
 
    }

	echo json_encode($deviveList);
    

}






function getdata($url){
    $curl = curl_init();
    //设置抓取的url
    curl_setopt($curl, CURLOPT_URL, $url);
    //设置头文件的信息作为数据流输出
    //curl_setopt($curl, CURLOPT_HEADER, 1);
    //设置获取的信息以文件流的形式返回，而不是直接输出。
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    //执行命令
    $data = curl_exec($curl);
    //关闭URL请求
    curl_close($curl);
    //显示获得的数据
    echo $data;
}

function getdata1($url){
    $curl = curl_init();
    //设置抓取的url
    curl_setopt($curl, CURLOPT_URL, $url);
    //设置头文件的信息作为数据流输出
    //curl_setopt($curl, CURLOPT_HEADER, 1);
    //设置获取的信息以文件流的形式返回，而不是直接输出。
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    //执行命令
    $data = curl_exec($curl);
    //关闭URL请求
    curl_close($curl);
    //显示获得的数据
    return $data;
}


























