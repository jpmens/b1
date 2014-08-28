% include('tbstop.tpl', page='map', page_title='OwnTracks LiveMap')



    <!-- Custom styles for this template -->
    <link href="map/map-style.css" rel="stylesheet">

    <!-- FIXME: copy local 
    <script src='map/mapbox.js'></script>
    <link href='map/mapbox.css' rel='stylesheet' />
    -->

        <script src='https://api.tiles.mapbox.com/mapbox.js/v1.6.2/mapbox.js'></script>
	    <link href='https://api.tiles.mapbox.com/mapbox.js/v1.6.2/mapbox.css' rel='stylesheet' />

    <!-- http://code.google.com/p/jqueryrotate/ -->
    <script src="js/jQueryRotateCompressed.js"></script>


    <script src="js/mqttws31.js"></script>
    <script src="map/config.js"></script>
    <script src="map/userdata.js"></script>
    <script src="map/mapfuncs.js"></script>
    <script src="map/mqttfuncs.js"></script>

FIXME
<a href="#" id="mqttstatus-details">No connection made yet.</a>

    
	    <div id="map" style=""></div>
	    <div id='msg'>
	    	<span id='msg-date'></span>
		<span id='msg-user'></span>
		<span id='msg-cog'><img id='img-cog' src='images/arrow.gif' /></span>
		<span id='msg-revgeo'><a href='#' id='link-revgeo'>xxx</a></span>
		<span id='msg-vel'></span>
		<span id='msg-alt'></span>
		<span id='msg-lat'></span>
		<span id='msg-lon'></span>
	    </div>

    <script>
    	$(document).ready(function() {
    		load_map(config.apiKey);
    		// getuserlist();
    		MQTTconnect();
    		$('#msg').val('starting');
    	});
    </script>

% include('tbsbot.tpl')