<!DOCTYPE html>
<html>
<head>
    <title>Simple Leaflet Map</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="css/leaflet.css" />
    <link rel="stylesheet" media="screen" type="text/css" href="css/datepicker.css" />
    <link rel="stylesheet" href="css/tinycolorpicker.css" type="text/css" media="screen"/>
</head>
<body>

    <select id='userdev'></select>
    <input type='text' id='fromdate' value='2014-08-19' />
    <input type='text' id='todate' value='2014-08-20' />

    <div id='datep'></div>

	<div id="colorPicker1">
                    <a class="color"><div class="colorInner"></div></a>
                    <div class="track"></div>
                    <ul class="dropdown"><li></li></ul>
                    <input type="hidden" class="colorInput"/>
        </div>


    <a href='#' id='getmap'>click</a>

    <!-- <a href='#' id='nextdate'>Next</a> -->

    <div id="map" style="width: 600px; height: 400px"></div>

    <script src="js/leaflet.js"></script>
    <script type="text/javascript" charset="utf8" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/datepicker.js"></script>
    <script type="text/javascript" src="js/jquery.tinycolorpicker.min.js"></script>

    <script type="text/javascript">

    	var map;
	var geojson;
	var line_color = 'red';

    	var lat = 50.109544;
	var lon = 8.694585;

        map = L.map('map').setView([lat, lon], 5);
        mapLink = 
            '<a href="http://openstreetmap.org">OpenStreetMap</a>';
	L.tileLayer(
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: 'Map data &copy; ' + mapLink,
            maxZoom: 18,
	}).addTo(map);


	var $select = $('#userdev');
                $.ajax({
                        type: 'GET',
                        url: 'api/userlist',
                        async: false,
			success: function(data) {

				// clear current content of select
				$select.html('');

				// iterate and append
				$.each(data.userlist, function(key, val) {
					$select.append('<option id="' + val.id + '">' +
						val.name + '</option>');
				})
			    },
			error: function() {
				$select.html("none available");
				}
		});

	$('#datep').DatePicker({
		flat: true,
		date: ['2014-08-19', '2014-08-20'],
		current: '2014-08-26',
		calendars: 2,
		mode: 'range',
		starts: 1,
		onChange: function(formatted, dates) {
			// console.log(formatted);
			// console.log(dates);

			$('#fromdate').val(formatted[0]);
			$('#todate').val(formatted[1]);
		},
	});

	function onEachFeature(feature, layer) {
		if (feature.properties) {
			layer.bindPopup(feature.properties.name);
		}
	}

	function getGeoJSON() {
		var params = {
			userdev: $('#userdev').children(':selected').attr('id'),
			fromdate: $('#fromdate').val(),
			todate: $('#todate').val(),
		};

		// console.log(JSON.stringify(params));

		$.ajax({
			type: 'POST',
                        url: 'api/getGeoJSON',
			async: false,
			data: JSON.stringify(params),
			dataType: 'json',
			success: function(data) {
				console.log(JSON.stringify(data));
				route = data;

				var myStyle = {
				    "color": line_color,
				    "weight": 5,
				    "opacity": 0.65
			        };


				if (geojson) {
					map.removeLayer(geojson);
				}
				geojson = L.geoJson(route, {
					style: myStyle,
					// onEachFeature: onEachFeature
				}).addTo(map);

				try {
					map.fitBounds(geojson.getBounds());
				} catch (err) {
					// console.log(err);
				}


			},
			error: function(xhr, status, error) {
				alert('get: ' + status + ", " + error);
			}
		   });
	}

	$(document).ready(function() {


		$("#colorPicker1").tinycolorpicker();
		$("#colorPicker1").bind("change", function() {
			line_color = $(".colorInput").val();
		});

		$('#getmap').on('click', function (e) {
			e.preventDefault();
			getGeoJSON();
		});
		$('#nextdate').on('click', function (e) {
			e.preventDefault();

			var d_from;
			var d_to;


			var d = $('#datep').DatePickerGetDate(false);
			// console.log(d);
			d_from = new Date(d[0]);
			d_to   = new Date(d[1]);

			d_from = d_from.setDate(d_from.getDate() + 1);
			d_to   = d_to.setDate(d_to.getDate() + 1);

			$('#datep').DatePickerSetDate(d_to, true);

			$('#todate').val( $('#datep').DatePickerGetDate(true)[1] );

		});


        });
	
    </script>
</body>
</html>
