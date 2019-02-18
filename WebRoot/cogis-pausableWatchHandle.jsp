<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport"
	content="initial-scale=1, maximum-scale=1, user-scalable=no">
<base href="<%=basePath%>">
<title>实时协同GIS原型系统</title>
<style>
html, body, #viewDiv {
	padding: 0;
	margin: 0;
	height: 100%;
	width: 100%;
}
</style>

	<link rel="stylesheet" href="https://js.arcgis.com/4.3/esri/css/main.css">
	<script src="https://js.arcgis.com/4.3/"></script>

<script>
 
	require([
		"esri/Map",
		"esri/views/MapView",
		"esri/widgets/Home",
		"esri/core/watchUtils",
		"esri/geometry/point",
		"dojox/socket",
		"dojo/domReady!"
	], function(Map, MapView, Home, watchUtils, Point, Socket) {
		var map = new Map({
			basemap : "streets"
		});
		var view = new MapView({
			container : "viewDiv", // Reference to the scene div created in step 5
			map : map, // Reference to the map object created before the scene
			zoom : 4, // Sets the zoom level based on level of detail (LOD)
			center : [ 118, 35 ] // Sets the center point of view in lon/lat
		});
		var homeBtn = new Home({
			view : view
		}, "homeDiv");
		homeBtn.startup();
		view.ui.add(homeBtn, "top-left");

		//view.on( "layerview-create", function ( event )
		//{
		//    alert( "视图开始创建！" );
		//} );
		//view.then( function ()
		//{
		//    alert( "promise开始执行！" );
		//}, function ( error )
		//{
		//    alert( "promise执行出错！" );
		//} );

		//view.on( "click", function ( evt )
		//{
		//    alert( "鼠标单击！" );
		//} );

		var url = "ws://localhost:8080/CoGIS/websocket";
		console.log(url);
		var websocket = null;

		//判断当前浏览器是否支持WebSocket
		if (window.WebSocket) {
			websocket = new WebSocket(url);
		} else {
			alert('Not support websocket');
		}

		//连接发生错误的回调方法
		websocket.onerror = function() {
			console.log("连接出错！");
		};

		//连接成功建立的回调方法
		websocket.onopen = function(event) {
			console.log("连接打开！");
		}

		

		//连接关闭的回调方法
		websocket.onclose = function() {
			closeWebSocket();

		}

		//监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。
		window.onbeforeunload = function() {
			closeWebSocket();
		}
		//关闭连接
				function closeWebSocket() {
					websocket.close();
					console.log("连接关闭！");
				}

		
		
		

		//将消息显示在网页上
		function setMessage(data) {
			/* console.log(data); */
			  	/* var center = Point.fromJSON(data);  


			  view.center = center;   */

			/* console.log("中心纬度：" + center.X.toString()); */
			 
			 var point = view.center.clone();
			point.x = parseFloat(data);
			/*  console.log(data);  */
			view.center = point; 

			pausableWatchHandle.resume();
		}		

		//发送消息
		function send(message) {			
			websocket.send(message);
		}

		//记录上次发送的数据
		//var center = view.center;
		/* var flag = true; */

		var pausableWatchHandle=watchUtils.pausable(view, [ "extent", "center" ], function(newValue) {
			/* console.log("中心纬度：" + view.center.latitude + "\r\n"
				+ "中心经度：" + view.center.longitude + "\r\n"
				+ "xmin：" + view.extent.xmin + "\r\n"
				+ "ymin：" + view.extent.ymin + "\r\n"
				+ "xmax：" + view.extent.xmax + "\r\n"
				+ "ymax：" + view.extent.ymax + "\r\n"
				+ "坐标参考：" + view.extent.spatialReference.wkid + "\r\n"
			); */

			//if (view.center != center) {

				var center = view.center.clone();
				var x = center.x;
				send(x);  		 

		 /*  var text=center.toJSON(); */
		/* console.log(text); */
		  
		 /* send(center);   */
		//}
		});
		
		//接收到消息的回调方法
		websocket.onmessage = function(event) {
			pausableWatchHandle.pause();
			setMessage(event.data);
			
		}

	});
</script>
</head>
<body>
	<div id="viewDiv"></div>
</body>
</html>
