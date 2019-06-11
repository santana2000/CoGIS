<%--
  Created by IntelliJ IDEA.
  User: Mr.Yin
  Date: 2019/4/8
  Time: 21:00
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>三维协同GIS</title>

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

    <link rel="stylesheet" href="https://js.arcgis.com/4.3/esri/css/main.css">
    <script src="https://js.arcgis.com/4.3/"></script>
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

<script>
    require([
        "esri/WebScene",
        "esri/config",
        "esri/views/SceneView",
        "esri/widgets/Home",
        "esri/core/watchUtils",
        "dojo/on",
        "dojo/dom",
        "dojo/dom-construct",
        "dojox/socket",
        "dojo/json",
        "dojo/domReady!"
    ], function(WebScene, esriConfig, SceneView, Home, watchUtils, on, dom, domConstruct, Socket, Json) {

        var coCheckBox = dom.byId("coChB");

        esriConfig.portalUrl = "http://happiness.esrichina.com/arcgis"

        var scene = new WebScene({
            portalItem: {
                // autocasts as new PortalItem()
                id: "cc75766db7c04c91ba023897b2b9881c"
            }
        });
        //私有视图
        var view = new SceneView({
            container : "viewDiv",
            map : scene,
        });

        var homeBtn = new Home({
            view : view
        }, "homeDiv");

        view.ui.add(homeBtn, "top-left");

        view.ui.add("coSettingsDiv", "top-right");

        //公共视图
        var coview = new SceneView({
            container : "coviewDiv",
            map : scene,
        });

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
            console.log(obj);
            if (obj.coType == "View") {
                coview.camera = obj.camera;
            }
        }

        //发送消息
        function send(message) {
            websocket.send(message);
        }

        var pausableWatchHandle = watchUtils.pausable(view, [ "interacting" ,"animation"], function(newValue) {
            if (!view.interacting) {

                var obj = new Object();
                obj.coType = "View";
                obj.camera = view.camera;

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

</html>
