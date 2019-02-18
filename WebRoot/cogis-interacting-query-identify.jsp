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

	#infoDiv {
		background-color: white;
		color: black;
		padding: 6px;
		width: 400px;
	}

	#results {
		font-weight: bolder;
	}

	#tocDiv {
		background-color: white;
		color: black;
		width: 350px;
		height: auto;
	}

	#coLayerCheckBox {
		position: relative;
		margin: 0px auto;
		text-align: center;
	}
	</style>

	<link rel="stylesheet" href="https://js.arcgis.com/4.3/esri/css/main.css">
	<script src="https://js.arcgis.com/4.3/"></script>

	<script>
	/* "https://js.arcgis.com/4.3/esri/css/main.css"
	"https://js.arcgis.com/4.3/" */

		/* http://localhost/arcgis_js_api/library/4.3/4.3/esri/css/main.css
		http://localhost/arcgis_js_api/library/4.3/4.3/init.js */

		require([
			"esri/Map",
			"esri/views/MapView",
			"esri/widgets/Home",
			"esri/widgets/Popup",
			"esri/PopupTemplate",
			"esri/core/watchUtils",
			"esri/layers/FeatureLayer",
			"esri/layers/GraphicsLayer",
			"esri/Graphic",
			"esri/geometry/Geometry",
			"esri/geometry/geometryEngine",
			"esri/geometry/Point",
			"esri/symbols/SimpleFillSymbol",
			"esri/symbols/SimpleMarkerSymbol",

			"esri/tasks/IdentifyTask",
			"esri/tasks/support/IdentifyParameters",
			"esri/core/arrayUtils",

			"dojo/on",
			"dojo/dom",
			"dojo/dom-construct",
			"dojox/socket",
			"dojo/json",
			"dojo/domReady!"
		], function(
			Map, MapView, Home, Popup, PopupTemplate,
			watchUtils,
			FeatureLayer, GraphicsLayer, Graphic, Geometry, geometryEngine, Point,
			SimpleFillSymbol, SimpleMarkerSymbol,

			IdentifyTask,IdentifyParameters,arrayUtils,

			on, dom, domConstruct,
			Socket, Json) {

			/*********************************************************/


			var quakesUrl = "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/ks_earthquakes_since_2000/FeatureServer/0";

			var wellBuffer,
				wellsGeometries,
				magnitude;

			var wellTypeSelect = dom.byId("well-type");
			var magSlider = dom.byId("mag");
			var distanceSlider = dom.byId("distance");
			var queryQuakes = dom.byId("query-quakes");


			// oil and gas wells
			var wellsLayer = new FeatureLayer({
				portalItem : {
					id : "8af8dc98e75049bda6811b0cdf9450ee"
				},
				outFields : [ "*" ],
				visible : false
			});
			var cowellsLayer = new FeatureLayer({
				portalItem : {
					id : "8af8dc98e75049bda6811b0cdf9450ee"
				},
				outFields : [ "*" ],
				visible : false
			});

			// historic earthquakes
			var quakesLayer = new FeatureLayer({
				url : quakesUrl,
				outFields : [ "*" ],
				visible : false
			});

			// GraphicsLayer for displaying results
			var resultsLayer = new GraphicsLayer();

			var wellsbufferLayer = new GraphicsLayer();


			var coWellBufferDistance,
				coEarthquakeMagnitude;
			var cowellsGeometries,
				cowellBuffer;
			var localLayerCheckBox = dom.byId("localLayerChB");
			var coLayerCheckBox = dom.byId("coLayerChB");

			var coresultsLayer = new GraphicsLayer();
			var cowellsbufferLayer = new GraphicsLayer();


			var map = new Map({
				/* basemap : "streets" */
				basemap : "dark-gray",
				layers : [ wellsLayer, quakesLayer, resultsLayer, wellsbufferLayer, cowellsLayer, cowellsbufferLayer, coresultsLayer ]
			});
			var view = new MapView({
				container : "viewDiv", // Reference to the scene div created in step 5
				map : map, // Reference to the map object created before the scene
				zoom : 10, // Sets the zoom level based on level of detail (LOD)
				center : [ -97.75188, 37.23308 ] // Sets the center point of view in lon/lat
			});

			var popupContent;

			var homeBtn = new Home({
				view : view
			}, "homeDiv");
			/* homeBtn.startup(); */
			view.ui.add(homeBtn, "top-left");

			view.ui.add("infoDiv", "top-right");

			view.ui.add("tocDiv", "top-left");

			/************************************************************/
			view.on("click", function(evt) {
				var screenPoint = {
					x : evt.x,
					y : evt.y
				};

				var identifyTask=new IdentifyTask("https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/ks_earthquakes_since_2000/FeatureServer");
				var params=new IdentifyParameters();
				params.tolerance=3;
				params.layerIds=[0];
				params.layerOption="all";
				params.width=view.width;
				params.height=view.height;

				params.geometry=evt.mapPoint;
				params.mapExtent=view.extent;

				// dom.byId("viewDiv").style.cursor="wait";

				identifyTask.execute(params)
					.then(function(response){
					 debugger;
					var results=response.results;
					var feature=results[0].feature;
					var layerName=results[0].layerName;

					feature.attributes.layerName=layerName;

					feature.popupTemplate={
						title:"test",
						content:"22"
					}

						view.popup.open({
							features:response,
							location:evt.mapPoint
						});
						/* dom.byId("viewDiv").style.cursor="auto"; */
					})




				/* view.hitTest(screenPoint)
					.then(function(response) {
						 debugger;
						var graphic = response.results[0].graphic;
						console.log(graphic.layer.title);
						view.popup.open({
							//features : graphic,
							location : evt.mapPoint,
							content : graphic.attributes
						})
						console.log(view.popup.content);

						//发送给服务器端
						//获取鼠标点击所在位置的经纬度坐标
						var colat = Math.round(evt.mapPoint.latitude * 1000) / 1000;
						var colon = Math.round(evt.mapPoint.longitude * 1000) / 1000;
						//将结果封装为json字符串
						var obj = new Object();
						obj.coType = "Popup";
						//obj.cogeometry=graphic.geometry;
						obj.attributes = graphic.attributes;
						obj.colat = colat;
						obj.colon = colon;
						//序列化为字符串
						var message = Json.stringify(obj);
						//console.log(message);
						send(message);
					}) */

			});

			/************************************************************/
			// query all features from the wells layer
			view.then(function() {
				return wellsLayer.then(function() {
					var query = wellsLayer.createQuery();
					return wellsLayer.queryFeatures(query);
				});
			})
				.then(getValues)
				.then(getUniqueValues)
				.then(addToSelect)
				.then(createBuffer);


			// return an array of all the values in the
			// STATUS2 field of the wells layer
			function getValues(response) {
				var features = response.features;
				var values = features.map(function(feature) {
					return feature.attributes.STATUS2;
				});
				return values;
			}

			// return an array of unique values in
			// the STATUS2 field of the wells layer
			function getUniqueValues(values) {
				var uniqueValues = [];

				values.forEach(function(item, i) {
					if ((uniqueValues.length < 1 || uniqueValues.indexOf(item) ===
						-1) &&
						(item !== "")) {
						uniqueValues.push(item);
					}
				});
				return uniqueValues;
			}

			// Add the unique values to the wells type
			// select element. This will allow the user
			// to filter wells by type.
			function addToSelect(values) {
				values.sort();
				values.forEach(function(value) {
					var option = domConstruct.create("option");
					option.text = value;
					wellTypeSelect.add(option);
				});
				return setWellsDefinitionExpression(wellTypeSelect.value);
			}

			// set the definition expression on the wells
			// layer to reflect the selection of the user
			function setWellsDefinitionExpression(newValue) {
				wellsLayer.definitionExpression = "STATUS2 = '" + newValue + "'";

				if (!wellsLayer.visible) {
					wellsLayer.visible = true;
				}
				return queryForWellGeometries();
			}

			// Get all the geometries of the wells layer
			// the createQuery() method creates a query
			// object that respects the definitionExpression
			// of the layer
			function queryForWellGeometries() {
				var wellsQuery = wellsLayer.createQuery();

				return wellsLayer.queryFeatures(wellsQuery)
					.then(function(results) {
						wellsGeometries = results.features.map(function(feature) {
							return feature.geometry;
						});

						return wellsGeometries;
					});
			}

			// creates a single buffer polygon around
			// the well geometries
			function createBuffer(wellPoints) {
				var bufferDistance = parseInt(distanceSlider.value);
				var wellBuffers = geometryEngine.geodesicBuffer(wellPoints, [
					bufferDistance
				], "meters",
					true);
				wellBuffer = wellBuffers[0];

				// add the buffer to the view as a graphic
				var bufferGraphic = new Graphic({
					geometry : wellBuffer,
					symbol : new SimpleFillSymbol({
						outline : {
							width : 1.5,
							color : [ 255, 128, 0, 0.5 ]
						},
						style : "none"
					})
				});
				wellsbufferLayer.removeAll();
				wellsbufferLayer.add(bufferGraphic);
			}

			// Get the magnitude value set by the user
			on(magSlider, "input", function() {
				magnitude = magSlider.value;
				dom.byId("mag-value").innerText = magnitude;
			});
			// display the distance value selected by the user
			on(distanceSlider, "input", function() {
				dom.byId("distance-value").innerText = distanceSlider.value;
			});
			// create a buffer around the queried geometries
			on(distanceSlider, "change", function() {
				createBuffer(wellsGeometries);
			});
			// set a new definitionExpression on the wells layer
			// and create a new buffer around the new wells
			on(wellTypeSelect, "change", function(evt) {
				var type = evt.target.value;

				setWellsDefinitionExpression(type)
					.then(createBuffer);
			});

			// query for earthquakes with the specified magnitude
			// within the buffer geometry when the query button
			// is clicked
			on(queryQuakes, "click", function() {
				queryEarthquakes()
					.then(displayResults);

				//将结果封装为json字符串
				var obj = new Object();
				obj.coType = "QueryFeatures";
				obj.coWellType = wellTypeSelect.value;
				obj.coWellBufferDistance = distanceSlider.value;
				obj.coEarthquakeMagnitude = magSlider.value;

				var message = Json.stringify(obj);
				/* console.log(message); */
				send(message);
			});

			//协同图层开关
			on(coLayerCheckBox, "change", function(evt) {
				var checked = evt.target.checked;

				coresultsLayer.visible = checked;
				cowellsbufferLayer.visible = checked;
			});
			//本地图层开关
			on(localLayerCheckBox, "change", function(evt) {
				var checked = evt.target.checked;

				resultsLayer.visible = checked;
				wellsbufferLayer.visible = checked;
			});


			function queryEarthquakes() {
				var query = quakesLayer.createQuery();
				query.where = "mag >= " + magSlider.value;
				query.geometry = wellBuffer;
				query.spatialRelationship = "intersects";

				return quakesLayer.queryFeatures(query);
			}

			// display the earthquake query results in the
			// view and print the number of results to the DOM
			function displayResults(results) {
				resultsLayer.removeAll();
				var features = results.features.map(function(graphic) {
					graphic.symbol = new SimpleMarkerSymbol({
						style : "diamond",
						size : 6.5,
						color : "darkorange"
					});
					return graphic;
				});
				var numQuakes = features.length;
				dom.byId("results").innerHTML = numQuakes + " earthquakes found";
				resultsLayer.addMany(features);

			}



			/************************************************************/

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
				var obj = Json.parse(data);
				/* console.log(obj.coType) */
				if (obj.coType == "View") {
					view.center = obj.coCenter;
					view.zoom = obj.coZoom;
					view.rotation = obj.coRotation;

					pausableWatchHandle.resume();
				} else if (obj.coType == "Popup") {
					debugger;
					var point = new Point();
					point.latitude = obj.colat;
					point.longitude = obj.colon;




					/* var title = obj.colayerTitle;
					var layer = map.allLayers.find(function(layer) {
						return layer.title = title;
					})

					var featureLayer = new FeatureLayer();
					featureLayer = layer;
					var query = featureLayer.createQuery();
					query.geometry = point;
					query.spatialRelationship = "intersects";
					debugger;
					featureLayer.queryFeatures(query)
						.then(function(results) {
							var graphic = results.graphics[0];
							console.log(Json.stringify(graphic.attributes));
							view.popup.open({
								location : point,
								content : graphic.attributes,
								features : results.graphics
							})
						}) */

					view.popup.clear();



					/*  view.popup.content = obj.coattributes; */

					view.popup.open({
						/* features : graphic, */
						location : point,
						content : obj.attributes
					})

					/* geometry=Geometry.fromJSON(Json.stringify(obj.cogeometry));

					var graphic=new Graphic();
					graphic.geometry=geometry;

					graphic.attributes= */





					console.log(view.popup.content);
					/* graphic.popupTemplate=obj.copopupTemplate;

					console.log(graphic.popupTemplate); */

					/* graphic.popupTemplate.content = graphic.attributes; */


					/* var popupTemplate = new PopupTemplate();
					popupTemplate.content = obj.coattributes; */

					/* popupContent = attributes; */


					/* view.popup.content =popupContent; */
					/* view.popup=new Popup(); */
					/* view.popup.open({
						location : point,
						content : popupTemplate.content,
						features:results.graphics
					}) */
					/* 	var graphic=new Graphic();
						graphic.attributes=obj.coattributes;
						view.popup.content = graphic.attributes; */


					/* console.log(obj.coattributes); */

				} else if (obj.coType == "QueryFeatures") {

					/* console.log(data); */

					/* obj.coSwellType
					obj.coWellBufferDistance
					obj.coEarthquakeMagnitude  */

					//显示协作功能的参数
					dom.byId("coWellType").innerText += obj.coWellType;
					dom.byId("coWellBufferDistance").innerText += obj.coWellBufferDistance;
					dom.byId("coEarthquakeMagnitude").innerText += obj.coEarthquakeMagnitude;

					coWellBufferDistance = parseFloat(obj.coWellBufferDistance);
					coEarthquakeMagnitude = parseFloat(obj.coEarthquakeMagnitude);

					coProcess(obj.coWellType)
				}


			}


			function coProcess(coWellType) {
				queryForCoWellGeometries(coWellType)
					.then(createCoBuffer)
					.then(queryCoEarthquakes)
					.then(displayCoResults);


			}

			function queryForCoWellGeometries(coWellType) {
				cowellsLayer.definitionExpression = "STATUS2 = '" + coWellType + "'";
				if (!cowellsLayer.visible) {
					cowellsLayer.visible = true;
				}

				// Get all the geometries of the wells layer
				// the createQuery() method creates a query
				// object that respects the definitionExpression
				// of the layer

				var cowellsQuery = cowellsLayer.createQuery();

				return cowellsLayer.queryFeatures(cowellsQuery)
					.then(function(response) {
						cowellsGeometries = response.features.map(function(feature) {
							return feature.geometry;
						});

						return cowellsGeometries;
					});
			}

			function createCoBuffer(wellPoints) {
				/*  debugger; */
				// creates a single buffer polygon around
				// the well geometries

				var cowellBuffers = geometryEngine.geodesicBuffer(cowellsGeometries, [
					coWellBufferDistance
				], "meters",
					true);
				cowellBuffer = cowellBuffers[0];

				// add the buffer to the view as a graphic
				var cobufferGraphic = new Graphic({
					geometry : cowellBuffer,
					symbol : new SimpleFillSymbol({
						outline : {
							width : 1.5,
							color : [ 54, 243, 13, 0.5 ]
						},
						style : "none"
					})
				});
				cowellsbufferLayer.removeAll();
				cowellsbufferLayer.add(cobufferGraphic);
			}

			function queryCoEarthquakes() {
				var query = quakesLayer.createQuery();
				query.where = "mag >= " + coEarthquakeMagnitude;
				query.geometry = cowellBuffer;
				query.spatialRelationship = "intersects";

				return quakesLayer.queryFeatures(query);
			}

			// display the earthquake query results in the
			// view and print the number of results to the DOM
			function displayCoResults(results) {
				coresultsLayer.removeAll();
				var features = results.features.map(function(graphic) {
					graphic.symbol = new SimpleMarkerSymbol({
						style : "diamond",
						size : 6.5,
						color : "green"
					});
					return graphic;
				});
				/* var numQuakes = features.length;
				dom.byId("results").innerHTML = numQuakes + " earthquakes found"; */
				coresultsLayer.addMany(features);

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
					//console.log(center_string);
					send(message);
				}

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
	<div id="infoDiv">
		Select well type: <select id="well-type"></select> <br> Well
		buffer distance: <input id="distance" type="range" min="10"
			max="10000" step="10" value="10000">&nbsp; <span
			id="distance-value">10000</span> meters <br> Earthquake
		magnitude: <input id="mag" type="range" min="0.0" max="5.0" step="0.1"
			value="2.0">&nbsp; <span id="mag-value">2.0</span>
		<button id="query-quakes">Query Earthquakes</button>
		<br>
		<div id="results"></div>
	</div>
	<div id="tocDiv">
		<ul>
			<li><input id="localLayerChB" type="checkbox" checked="checked">
				<span>本地图层</span>&nbsp;
			<li><input id="coLayerChB" type="checkbox" checked="checked">
				<span>协同图层</span>&nbsp;
				<div>
					<span id="coWellType">coSwellType: </span>
				</div>
				<div>
					<span id="coWellBufferDistance">coWellBufferDistance: </span>
				</div>
				<div>
					<span id="coEarthquakeMagnitude">coEarthquakeMagnitude: </span>
				</div>
		</ul>
	</div>
</body>
</html>
