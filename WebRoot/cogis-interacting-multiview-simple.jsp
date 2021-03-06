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
    <title>实时协同GIS--多视图--无操作</title>
    <link rel="stylesheet" href="https://js.arcgis.com/4.3/esri/css/main.css">
    <script src="https://js.arcgis.com/4.3/"></script>
    <style>
        html, body, #content {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }

        .view {
            float: left;
            display: block;
            width: 48%;
            height: 95%;
            border: #0079c1 2px solid;

        }
        .coviewDiv{
            border: #0079c1 2px solid;

        }

        #top {
            height: 5%;
            display: block;
        }

        #top-left {
            margin-left: auto;
            margin-right: auto;
            width: 25%;
            display: inline;
            float: left;
            text-align: center;

        }

        #top-right {
            margin-left: auto;
            margin-right: auto;
            width: 25%;
            display: inline;
            float: right;
            /* text-align:center;	 */
        }

        #coSettingsDiv {
            background-color: white;
            color: black;
            width: 150px;
            height: 50px;
            margin-top: 50px;
            margin-left: 10px;
        }
    </style>

    <script>

        require([
            "esri/Map",
            "esri/views/MapView",
            "esri/widgets/Home",
            "esri/core/watchUtils",
            "dojo/on",
            "dojo/dom",
            "dojo/dom-construct",
            "dojox/socket",
            "dojo/json",
            "dojo/domReady!"
        ], function(Map, MapView, Home, watchUtils, on, dom, domConstruct, Socket, Json) {

            var coCheckBox = dom.byId("coChB");

            var map = new Map({
                basemap : "streets"
            });
            //私有视图
            var view = new MapView({
                container : "viewDiv", // Reference to the scene div created in step 5
                map : map, // Reference to the map object created before the scene
                zoom : 4, // Sets the zoom level based on level of detail (LOD)
                center : [ 118, 35 ] // Sets the center point of view in lon/lat
            });

            var homeBtn = new Home({
                view : view
            }, "homeDiv");

            view.ui.add(homeBtn, "top-left");

            view.ui.add("coSettingsDiv", "top-right");

            //公共视图
            var coview = new MapView({
                container : "coviewDiv",
                map : map,
                zoom : 4,
                center : [ 118, 35 ]
            });

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
//===============================================================================
            var url = "ws://localhost:8080/websocket";
            //console.log(url);
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
            };

            //连接关闭的回调方法
            websocket.onclose = function() {
                closeWebSocket();

            };

            //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。
            window.onbeforeunload = function() {
                closeWebSocket();
            };

            //关闭连接
            function closeWebSocket() {
                websocket.close();
                console.log("连接关闭！");
            };

//================================================================================


            //2. 将消息显示在网页上，解析封装好的消息，将消息内容应用到协同视图中
            function setMessage(data) {
                var obj = Json.parse(data);
                    console.log(obj);
                    document.getElementById('dismessage').innerHTML = obj.coType + obj.coCenter.x + obj.coCenter.y + obj.coZoom ;
                    console.log(document.getElementById('dismessage').value);

                if (obj.coType == "View") {
                    coview.center = obj.coCenter;
                    coview.zoom = obj.coZoom;
                    coview.rotation = obj.coRotation;
                }
            }

            //1. 生成消息对象并封装成JSON格式，客户端X向服务器发送消息（当前的位置信息）
            function send(message) {
                websocket.send(message);
            }

            var pausableWatchHandle = watchUtils.pausable(view, [ "interacting" ],
                function(newValue) {
                    if (!view.interacting) {
                        var obj = new Object();
                        obj.coType = "View";
                        obj.coCenter = view.center;
                        obj.coZoom = view.zoom;
                        obj.coRotation = view.rotation;

                        var message = Json.stringify(obj);

                        send(message);
                        //console.log(message);
                }

            });


            //接收到消息的回调方法
            websocket.onmessage = function(event) {
                setMessage(event.data);

            };


            //协同图层开关
            on(coCheckBox, "change", function(evt) {
                //debugger;
                var checked = evt.target.checked;
                if (checked)
                    pausableWatchHandle.resume();
                else
                    pausableWatchHandle.pause();

            });

        });
    </script>
</head>
<body>
	<div id="top">
		<div id="top-left">私有视图</div>
		<div id="top-right">公有视图</div>
	</div>

	<div id="viewDiv" class="view"></div>

	<div id="coviewDiv" class="view"></div>

	<div id="coSettingsDiv">
		<input id="coChB" type="checkbox" > <span>协同开关</span>&nbsp;
	</div>
    <div id="dismessage">
        来自客户端3的消息:
    </div>

</body>
</html>
