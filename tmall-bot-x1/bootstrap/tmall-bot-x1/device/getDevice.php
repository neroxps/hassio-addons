<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>天猫精灵设备添加</title>
 <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
  <link rel="stylesheet" href="weui/style/weuix.min.css"/>
  
  <!--
    <link rel="icon" href="weui/favicon.ico">


      
-->
      <script src="weui/zepto.min.js"></script>
      <script src="weui/vue.js"></script>
      <script src="weui/vue-resource.js"></script>
      <script src="weui/select.js"></script>
      <script src="weui/picker.js"></script>
      <style>
         .weui_label {
    		display: block;
    		width: 260px;
    		word-wrap: break-word;
    		word-break: break-all;
		} 
                 .page-hd-title {
    font-size: 20px;
    font-weight: 400;
    text-align: center;
    margin-bottom: 15px;
}
          
    </style>

</head>

<body ontouchstart  class="page-bg">
<div id="app">
<div class="tcenter" style="overflow:hidden; ">
 
    
    <template v-for="(item, index) in notice.logo">
    	<a v-bind:href="item.link" target="_blank">
      		<img class=" img-radius"  style="margin:10px auto 0;height:50px;margin-left: 30px;" v-bind:src="item.img">
    	</a>
    </template>
    
    
    
    </div>
<div class="page-hd" >
    <h1 class="page-hd-title">
        {{ notice.title }}
    </h1>
    
    <p class="page-hd-desc" style="margin-bottom: 30px;">
        <a v-bind:href="notice.link" target="_blank">
    		{{ notice.notice }}
        </a>
    </p>
    <p class="page-hd-desc">
    	填写下面的信息，生成配置文件。
    
    </p>
</div>
<div class="page-bd">
    
<div class="weui_panel_bd">
    

    
    <template v-for="(item, index) in deviceList">
       <div class="weui_cells_title">设备类型：{{ item.deviceType }}</div>
       <div class="weui_cells weui_cells_access">
		<template v-for="(itemm, indexx) in item.deviveList">  
            <a class="weui_cell" :href="'add.php?deviceId='+itemm.entity_id+'&deviceName='+itemm.attributes.friendly_name">
                <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                <div class="weui_cell_bd weui_cell_primary">
                    <p>{{ itemm.attributes.friendly_name }}</p>
                </div>
                <div class="weui_cell_ft">{{ itemm.entity_id }}</div>
            </a>
         </template>
        </div>
    </template>
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
               
            </div>   

    

            
<!--
         
    <span>deviceId: {{ deviceId }}</span><br/>
    <span>deviceName: {{ deviceName }}</span><br/>
    <span>deviceType: {{ deviceType }}</span><br/>
    <span>zone: {{ zone }}</span><br/>
    <span>brand: {{ brand }}</span><br/>
    <span>model: {{ model }}</span><br/>
    <span>icon: {{ icon }}</span><br/>
    <span>ac: {{ actions }}</span><br/>
    <span>ac: {{ properties }}</span><br/>
    
    
    -->


    
    
    
    
    
    
    
    
    
    
    
    
    
    </div>
<div class="weui-footer" style="margin-top: 70px;">
<p class="weui-footer-text">Copyright &copy; qebabe</p>

</div>
</div>   
    
   <script>

         
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
var vm = new Vue({
  el: '#app',
  data: {
      notice:{
      	title:'天猫精灵设备管理_1.0   By qebabe',
        nocice:"",
        
      },
      deviceList:[],
      
      
      canDevicelist:["switch","light"],
      

  },
    created:function(){
        const that=this;
        that.getNotice();
        that.getDevice();
        

  },
    methods: {
        getDevice:function(){
        
        const that=this;   
        var timestamp =Date.parse(new Date());
        var url ='service.php?v=getDevice1';
        console.log(url);
        this.$http.post(
            url,
            {},
            {emulateJSON:true}

            ).then(
          function (res) {
            console.log(res.data);
              
              for (var i=0;i<res.data.length;i++){
                  
              //res.data.length);
              var deviceType=res.data[i].deviceType;
                  
               console.log(deviceType);
                  
                  if($.inArray(deviceType ,that.canDevicelist)!=-1){
                      
                      console.log(res.data[i]);
                      
                      that.deviceList = that.deviceList.concat(res.data[i]);

                      
                      
                  }
                  
               
              
              //that.deviceList=res.data;
              
               //console.log(res.data);
     
              }
          },function (res) {
            console.log(res);
              $.toast("网络错误", "cancel");

          }
        );
        
        
        
        
        
        },
        getNotice:function(){
        //$.toast("ret");
        const that=this;   
        var timestamp =Date.parse(new Date());
        var url ='service.php?v=getNotice';
        console.log(url);
        this.$http.post(
            url,
            {},
            {emulateJSON:true}

            ).then(
          function (res) {
            console.log(res.data);
              if(res.data.code=="ok"){
              	//$.toast(res.data.Msg);
                 that.notice=res.data.data;
                  
              }else{
              	$.toast(res.data.Msg, "forbidden");
              }
          },function (res) {
            console.log(res);
              $.toast("网络错误", "cancel");

          }
        );

    }
    }
})

       
    </script>
    
    
    
    
    
    
    
    
    
    
</body>
</html>











