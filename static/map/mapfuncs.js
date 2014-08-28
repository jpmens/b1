// Global variables
var map;
var redIcon;
var latlngs = Array();

function load_geofences()
{
	$.ajax({
		type: 'GET',
		url: config.geofences,
		async: false,
		data: {},
		dataType: 'json',
		success: function(data) {

			for (var key in data) {
				console.log(key + " -> " + data[key].desc);
				lat = data[key].lat;
				lon = data[key].lon;
				radius = data[key].meters;

				L.circle([lat, lon], radius).addTo(map);
			}
		},
		error: function(xhr, status, error) {
			alert('get: ' + status + ", " + error);
		}
	});
}

function load_map(apiKey)
{
	map = L.mapbox.map('map', apiKey).setView([51.505, -0.09], 13);
	var linecolor = 'green';
	var latlngs = Array();

	map.scrollWheelZoom.disable();

	if (config.geofences !== null) {
		load_geofences();
	}
}

// topic is received topic
// d is parsed JSON payload
// date is Date() object
function mapit(topic, d, date)
{
	var user = getUser(topic);
	if (!user || !user.name) {
		// doesn't exist. Create something
		if (d.tid) {
			tid = d.tid;
		} else {
			tid = topic.slice(-2);
		}
		user = {
			name: tid,
			count: 0,
		};
		users[topic] = user;
	}
		
	var f = {}

		
	if (user.marker) {
		f = friend_move(user, d.lat, d.lon);
	} else {
		f = friend_add(user, d.lat, d.lon);
		latlngs.push(f.getLatLng());
		map.fitBounds(L.latLngBounds(latlngs));
	}
}

