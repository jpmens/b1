% include('tbstop.tpl', page='console', page_title='OwnTracks Console')


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
                $('#status').val("Connection failed: " + message.errorMessage + "Retrying");
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
    }

    function onConnectionLost(response) {
        setTimeout(MQTTconnect, reconnectTimeout);
        $('#status').val("connection lost: " + response.errorMessage + ". Reconnecting");

    };

    function onMessageArrived(message) {

        var topic = message.destinationName;
        var payload = message.payloadString;

	var matrix = $("#matrix");

	try {
		var d = $.parseJSON(payload);
	} catch (err) {
		return;
	}

	/*
	 * FIXME: id should be topic, content is TID.
	 * also: subscribe to /status, split that off and set class of input
	 */

	if (d.tid) {
		var tid = d.tid;
		var box = $('#' + tid);

		if (box.length == 0) {
			var field = '<input type="text" class="boxgreen" id="' + tid + '" value="' + tid + '" readonly />';
			$(matrix).append(field);
		}
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
