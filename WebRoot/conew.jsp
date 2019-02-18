<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
            + path + "/";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <base href="<%=basePath%>">

    <title>Prototype System</title>

    <link href="https://cdn.bootcss.com/normalize/8.0.1/normalize.css" rel="stylesheet">

    <link rel="stylesheet" href="https://js.arcgis.com/4.3/esri/css/main.css">
    <script src="https://js.arcgis.com/4.3/"></script>
    <!--<link rel="stylesheet" href="main.css">-->

    <%--<script src="main.js"></script>--%>

    <style>
        html,body{
            border: rgba(231, 234, 237, 0.56) 2px solid;
        }

        div{
            box-sizing: border-box;
        }

        .clearx:after{
            display:block;
            clear:both;
            content:"";
            visibility:hidden;
            height:0
        }
        p{
            font-size: 30px;
            margin-bottom: 10px;
            margin-top: 10px;
        }
        .header{
            background-color: #ffffff;
        }
        .name{
            /*text-align: center;*/
            margin: 0 0 0 0;
            padding: 0 10px;
            border: #000000 1px solid;
            color: rgba(41, 41, 41, 0.85);
            font-family: "Eras Medium ITC";
            font-style:italic;
            background-color: rgba(83, 53, 22, 0.42)

        }
        h1{
            margin: 10px 0;
            font-weight: 500;
        }

        .func{
            padding: 2px 3px;
            margin-right: 10px;
            background-color: rgba(230, 240, 213, 0.78);

            border-radius: 2px;
        }
        .first{
            margin-left: 10px;
        }
        .type,
        .menu{
            /*border: #000000 1px solid;*/

        }
        .lview,
        .rview{
            text-align: center;
            border: #000000 1px solid;
            /*box-sizing: border-box;*/
            padding: 3px 0;


        }
        .lview{
            float: left;
            width: 43%;

        }
        .rview{
            float: right;
            width: 57%;
            padding-right: 230px;

        }

        .lmenu,
        .rmenu{
            width: 43%;
            border: #000000 1px solid;
            padding: 3px 0;

            /*box-sizing: border-box;*/
        }


        .lmenu{
            float: left;
        }
        .menu{
            font-size: 16px;

        }
        .next{
            list-style: none;
            display: none;
            z-index: 2;

        }
        .func{
            display: inline-block;
            position: relative;
        }
        .func:hover .next{
            display: block;
            background-color: rgba(180, 174, 175, 0.27);
            box-shadow: white;
            border-radius: 4px;
            position: absolute;
            top: 10px;
            padding: 10px 10px;

        }
        li{
            padding: 3px;
            text-align: center;
        }
        .rmenu{
            float: right;
            width: 57%;


        }
        .maps{
            background-color: #ffffff;
            /*border: #000000 1px solid;*/
        }

        #lmap,
        #rmap,
        .side{
            border: #000000 1px solid;
        }
        #lmap{
            width: 43%;
            height: 500px;
            /*background-color: cadetblue;*/
            float: left;
        }
        #rmap{
            width: 43%;
            /*background-color: #f6cf98;*/
            float: left;
            height: 500px;


        }
        .side{
            width: 14%;
            float: right;
            height: 500px;
            font-size: 15px;
        }
        .message{
            /*border: #000000 1px solid;*/
        }
        .user{
            border: #000000 1px solid;
            float: left;
            width: 20%;
            height: 100px;
            font-size: 15px;

        }
        .send{
            border: #000000 1px solid;
            float: left;
            width: 50%;
            height: 100px;


        }
        .mes{
            border: #000000 1px solid;
            float: left;
            width: 50%;
            height: 100px;
            font-size: 15px;
            overflow: scroll;

        }
        textarea{
            width: 99%;
            display: block;
            height: 65px;
        }
        input{
            display: inline-block;
            width: 90%;
            box-sizing: border-box;

        }
        button{
            display: inline-block;
            width: 10%;
            /*border: 1px black solid;*/
            box-sizing: border-box;
            padding: 1px 0;

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

            // var coCheckBox = dom.byId("coChB");

            var map = new Map({
                basemap : "streets"
            });
            //私有视图
            var view = new MapView({
                container : "rmap", // Reference to the scene div created in step 5
                map : map, // Reference to the map object created before the scene
                zoom : 4, // Sets the zoom level based on level of detail (LOD)
                center : [ 118, 35 ] // Sets the center point of view in lon/lat
            });

            var homeBtn = new Home({
                view : view
            }, "homeDiv");

            view.ui.add(homeBtn, "top-left");

            // view.ui.add("coSettingsDiv", "top-right");

            //公共视图
            var coview = new MapView({
                container : "lmap",
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

//============================================================================================


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

            //2. 接收到消息的回调方法
            websocket.onmessage = function(event) {
                setMessage(event.data);

            };
            //3. 将消息显示在网页上，解析封装好的消息，将消息内容应用到协同视图中
            function setMessage(data) {
                var obj = Json.parse(data);
                //console.log(obj);

                var p2 = document.createTextNode(data);
                var br = document.createElement('br');



                document.getElementById('mes').appendChild(p2);
                document.getElementById('mes').appendChild(br);
                console.log(document.getElementById('mes').value);

                if (obj.coType == "View") {
                    coview.center = obj.coCenter;
                    coview.zoom = obj.coZoom;
                    coview.rotation = obj.coRotation;
                }
            }

            //协同图层开关

        /*    on(coCheckBox, "change", function(evt) {
                //debugger;
                var checked = evt.target.checked;
                if (checked)
                    pausableWatchHandle.resume();
                else
                    pausableWatchHandle.pause();
            });*/

        });
    </script>
</head>
<body>
<div class="container">
    <div class="header">
        <div class="name">
            <p>Muti-view Real-time Collaborative GIS</p>
        </div>
        <div class="type clearx">
            <div class="lview">Public View</div>
            <div class="rview">Private View</div>
        </div>
    </div>
    <div class="menu clearx">
        <div class="lmenu">
            <span class="func first" >Public View to Private View</span>
            <span class="func">Basic Operation
                <ul class="next">
                    <li>Zoom In</li>
                    <li>Zoom Out</li>
                    <li>Pan</li>
                    <li>ViewEntire</li>
                </ul>
            </span>
            <span class="func">Spatial Query</span>
        </div>
        <div class="rmenu">
            <span class="func first">Private View to Public View</span>
            <span class="func">Map Annotation</span>

            <span class="func">Spatial Query</span>
            <span class="func">Spatial Analysis</span>
            <span class="func">Map Edit</span>
        </div>
    </div>
    <div class="maps clearx">
        <div id="lmap"> </div>
        <div id="rmap"> </div>
        <div class="side">Users Online:
            <br>
            <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  —— Client:A
            <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  —— Client:B
            <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  —— Client:C
        </div>
    </div>
    <div class="message clearx">
        <!--<div class="user">-->
        <!--Users Online：<br>客户端0<br>客户端1<br>-->
        <!--</div>-->
        <div class="send">
            <textarea style="font-size: 15px">Real-time session:</textarea>
            <input><button>send </button>
        </div>
        <div id="mes" class="mes">Instant Message:<br></div>
    </div>

   <%-- <div id="coSettingsDiv">
        <input id="coChB" type="checkbox" checked="checked"> <span>协同开关</span>&nbsp;
    </div>--%>
  <%--  <div id="aaaa">
        fffff
    </div>--%>

</div>
</body>
</html>