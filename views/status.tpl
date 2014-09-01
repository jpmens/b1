% include('tbstop.tpl', page='status', page_title='OwnTracks Console')


    <script src="js/mqttws31.js" type="text/javascript"></script>
    <script src="config.js" type="text/javascript"></script>

	<style>
	.boxgreen {
		color: white;
		background-color: green;
		width: 4%;
		text-align: center;
		margin: 4px;
	}
	.boxred {
		color: white;
		background-color: red;
		width: 4%;
		text-align: center;
		margin: 4px;
	}
	.boxyellow {
		color: black;
		background-color: yellow;
		width: 4%;
		text-align: center;
		margin: 4px;
	}

	input[type="text"]:disabled {
		color: white;
		background-color: yellow;
	}
	</style>

	<div id='matrix'>
	</div>

    <script type="text/javascript">
    var mqtt;
    var reconnectTimeout = 2000;

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    function MQTTconnect() {
        mqtt = new Messaging.Client(
                        config.host,
                        config.port,
                        "web_" + parseInt(Math.random() * 100,
                        10));
        var options = {
            timeout: 3,
            useSSL: config.usetls,
            cleanSession: config.cleansession,
            onSuccess: onConnect,
            onFailure: function (message) {
                console.log("Connection failed: " + message.errorMessage + "Retrying");
                setTimeout(MQTTconnect, reconnectTimeout);
            }
        };

        mqtt.onConnectionLost = onConnectionLost;
        mqtt.onMessageArrived = onMessageArrived;

        if (config.username != null) {
            options.userName = config.username;
            options.password = config.password;
        }
        console.log("Host="+ config.host + ", port=" + config.port + " TLS = " + config.usetls + " username=" + config.username + " password=" + config.password);
        mqtt.connect(options);
    }

    function onConnect() {
        $('#status').val('Connected to ' + config.host + ':' + config.port);
        // Connection succeeded; subscribe to our topic
        mqtt.subscribe(config.topic, {qos: 0});
        mqtt.subscribe(config.topic + "/status", {qos: 0});
    }

    function onConnectionLost(response) {
        setTimeout(MQTTconnect, reconnectTimeout);
        console.log("connection lost: " + response.errorMessage + ". Reconnecting");

    };

    function onMessageArrived(message) {

        var topic = message.destinationName;
        var payload = message.payloadString;

	var matrix = $("#matrix");

	console.log(topic + " " + payload);

	var d;
	try {
		d = JSON.parse(payload);
		if (d.tid) {
			var tid = d.tid;
			var id = topic.replace(/\//g, '-');
			var box = $('#' + id);

			if (box.length == 0) {
				var field = '<input type="text" class="boxgreen" id="' + id + '" value="' + tid + '" readonly />';
				$(matrix).append(field);
			}
			return;
		}
	} catch (err) {
		console.log("JSON parse: " + err);
		return;
	}

	if (endsWith(topic, "/status")) {
		var tarr = topic.split('/');
		var newtopic = "";
		for (var n = 0; n < tarr.length - 1; n++) {
			newtopic = newtopic + tarr[n] + ((n < (tarr.length - 2)) ? "/" : "");
		}
		console.log("Got status " + payload + " for " + newtopic);

		var id = newtopic.replace(/\//g, '-');
		var box = $('#' + id);
		var s = payload;

		if (s == 0) {
			classname = 'boxgreen';
		} else if (s == 1) {
			classname = 'boxred';
		} else {
			classname = 'boxyellow';
		}

		if (box.length == 1) {
			// $(box).addClass('boxred').removeClass('boxgreen');
			$(box).attr("class", classname);
		}
		return;
	}



	$('input:text').focus(function(){
		console.log( $(this).val() );
	});

    };


    $(document).ready(function() {
        MQTTconnect();
    });

    </script>


% include('tbsbot.tpl')
