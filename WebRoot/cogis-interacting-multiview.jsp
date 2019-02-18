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
    <title>实时协同GIS--多视图</title>


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
            width: 50%;
            height: 95%;
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
            width: 200px;
            height: 100px;
            margin-top: 50px;
            margin-left: 10px;
        }
    </style>

    <script>

        require([
            "esri/Map",
            "esri/views/MapView",
            "esri/widgets/Home",
            "esri/widgets/Popup",
            "esri/PopupTemplate",
            "esri/core/watchUtils",
            "esri/layers/FeatureLayer",
            "esri/layers/GraphicsLayer",
            "esri/views/layers/LayerView",
            "esri/Graphic",
            "esri/geometry/Geometry",
            "esri/geometry/geometryEngine",
            "esri/geometry/Point",
            "esri/symbols/SimpleFillSymbol",
            "esri/symbols/SimpleMarkerSymbol",

            "esri/tasks/support/Query",

            "dojo/on",
            "dojo/dom",
            "dojo/dom-construct",
            "dojox/socket",
            "dojo/json",
            "dojo/domReady!"
        ], function(
            Map, MapView, Home, Popup, PopupTemplate,
            watchUtils,
            FeatureLayer, GraphicsLayer, LayerView,
            Graphic, Geometry, geometryEngine, Point,
            SimpleFillSymbol, SimpleMarkerSymbol,

            Query,

            on, dom, domConstruct,
            Socket, Json) {

            var wellsLayer = new FeatureLayer({
                portalItem : {
                    id : "8af8dc98e75049bda6811b0cdf9450ee"
                },
                outFields : [ "*" ],
                visible : true
            });



            var cowellsLayer = new FeatureLayer({
                portalItem : {
                    id : "8af8dc98e75049bda6811b0cdf9450ee"
                },
                outFields : [ "*" ],
                visible : true
            });

            var coCheckBox = dom.byId("coChB");

            var map = new Map({
                basemap : "dark-gray",
                layers : [ wellsLayer ]
            });
            //私有视图
            var view = new MapView({
                container : "viewDiv", // Reference to the scene div created in step 5
                map : map, // Reference to the map object created before the scene
                zoom : 10, // Sets the zoom level based on level of detail (LOD)
                center : [ -97.75188, 37.23308 ] // Sets the center point of view in lon/lat
            });

            var homeBtn = new Home({
                view : view
            }, "homeDiv");

            view.ui.add(homeBtn, "top-left");

            view.ui.add("coSettingsDiv", "top-right");

            var comap = new Map({
                basemap : "dark-gray",
                layers : [ cowellsLayer ]
            });
            //公共视图
            var coview = new MapView({
                container : "coviewDiv",
                map : comap,
                zoom : 10,
                center : [ -97.75188, 37.23308 ]
            });


            view.on("click", function(evt) {
                var screenPoint = {
                    x : evt.x,
                    y : evt.y
                };

                view.hitTest(screenPoint)
                    .then(function(response) {
                        var graphic = response.results[0].graphic;
                        if (graphic) {

                            //显示属性表,构造一个table
                            var content = "<table>";

                            for (var key in graphic.attributes) {
                                //console.log(key);
                                content += "<tr><th>" + key + "</th><td>" + graphic.attributes[key] + "</td></tr>";
                            }
                            content += "</table>";

                            //发送协同信息
                            //发送给服务器端
                            //获取鼠标点击所在位置的经纬度坐标
                            var colat = Math.round(evt.mapPoint.latitude * 1000) / 1000;
                            var colon = Math.round(evt.mapPoint.longitude * 1000) / 1000;
                            //将结果封装为json字符串
                            var obj = new Object();
                            obj.coType = "Popup";
                            obj.colat = colat;
                            obj.colon = colon;
                            obj.colayerTitle = graphic.layer.title;

                            graphic.popupTemplate = {
                                title : "要素属性(key-values)",
                                content : content
                            };

                            graphic.popupTemplate.title = "石油燃气点图层";

                            obj.coPopupTemplateTitle = graphic.popupTemplate.title;
                            obj.coPopupTemplateContent = graphic.popupTemplate.content;

                            //序列化为字符串
                            var message = Json.stringify(obj);
                            //console.log(message);
                            send(message);
                        }
                    });
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

            var url = "ws://localhost:8080/websocket";
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
            }
            ;





            //将消息显示在网页上
            function setMessage(data) {
                var obj = Json.parse(data);
                /* console.log(obj.coType) */
                if (obj.coType == "View") {
                    coview.center = obj.coCenter;
                    coview.zoom = obj.coZoom;
                    coview.rotation = obj.coRotation;

                    pausableWatchHandle.resume();
                } else if (obj.coType == "Popup") {

                    var point = new Point();
                    point.latitude = obj.colat;
                    point.longitude = obj.colon;

                    coview.popup.open({
                        location : point,
                        title : obj.coPopupTemplateTitle,
                        content : obj.coPopupTemplateContent
                    })


                }
            }

            //发送消息
            function send(message) {
                websocket.send(message);
            }

            var pausableWatchHandle = watchUtils.pausable(view, [ "interacting" ], function(newValue) {
                if (!view.interacting) {

                    var obj = new Object();
                    obj.coType = "View";
                    obj.coCenter = view.center;
                    obj.coZoom = view.zoom;
                    obj.coRotation = view.rotation;



                    var message = Json.stringify(obj);
                    // console.log(obj);
                    send(message);
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
		<input id="coChB" type="checkbox" checked="checked"> <span>协同开关</span>&nbsp;
	</div>
</body>
</html>
