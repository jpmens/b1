% include('tbstop.tpl', page='status', page_title='OwnTracks Status')


    <script src="js/mqttws31.js" type="text/javascript"></script>
    <script src="config.js" type="text/javascript"></script>
    <script src="all/mqtt.js" type="text/javascript"></script>

    <style>
	.fixed-size-square {
	    float: left;
	    margin: 4px;
	    display: table;
	    width: 36px;
	    height: 36px;
	    background: #4679BD;
	    border: 1px solid #696969;
	}
	.fixed-size-square span {
	    display: table-cell;
	    text-align: center;
	    vertical-align: middle;
	    // color: white
	}
	.blue {
		background: blue;
		color: white;
	}
	.green {
		background: green;
		color: white;
	}
	.red {
		background: red;
		color: white;
	}
	.yellow {
		background: yellow;
		color: black;
	}
	.hcard {
	    color: #FFF;
	    clear: both;
	    float: none;
	    width: 400px;
	    background: #000;
	    padding: 10px;
	    font: 11px Arial, Helvetica, sans-serif;
	    -moz-border-radius: 5px;
	    border-radius: 5px;
	    -webkit-border-radius: 5px;
	    position: absolute;
	    top: 110px;
	    border: 2px solid #999;
	    display: none;
	}
	.hcard pre {
	    color: #FFF;
	    background: #000;
	    text-align: left;
	    -moz-border-radius: 0;
	    border-radius: 0;
	    -webkit-border-radius: 0;
	    border: 0;
	    font: 11px Courier, Arial, Helvetica, sans-serif;
	    

	}

    </style>


    <div id="hiddenDiv" class="hcard">
      <pre id='servertext'></pre>
	    </div>

    <div id='matrix'></div>

    <script type="text/javascript">

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    function errorfunc(status, reason) {
    	console.log("STATUS: " + status + "; " + reason);
    }


    function handlerfunc(topic, payload) {
	var matrix = $("#matrix");

	var d;
	try {
		d = JSON.parse(payload);
		if (d.tid) {
			var tid = d.tid;
			var id = topic.replace(/\//g, '-');
			var box = $('#' + id);

			if (box.length == 0) {
				// TODO: I can put small text in the inside div (within span)
				var field = '<div id="' + id + '" tid="' + tid + '" class="fixed-size-square blue" data-tid="' + tid + '">\
						    <span>' + tid + '<div></div></span>\
						</div>';
				console.log(field);
				$(matrix).append(field);

				box = $('#' + id);
				$(box).on('click mouseenter', function(){
					var tid = $(this).attr('tid');
					console.log( $(this).attr('id') + " (" + $(this).attr('tid') + ")" );

					var text = "not there";

					$.ajax({
						url: 'api/onevehicle/' + tid,
						type: 'GET',
						async: false,
						dataType: 'text',
						success: function(data) {
							text = data;
						},
					});

				        $('div:hidden #servertext').text(text);
					$('#hiddenDiv').show();
				});
				$(box).on('mouseleave', function(){
					$('#hiddenDiv').hide();
				});
			}
			return;
		}
	} catch (err) {
		console.log("JSON parse: " + err);
		return;
	}

	if (endsWith(topic, "/status")) {
		var tarr = topic.split('/');
		var classname;
		var realtopic = ""; // i.e. topic corresponding to the /status we got
		for (var n = 0; n < tarr.length - 1; n++) {
			realtopic = realtopic + tarr[n] + ((n < (tarr.length - 2)) ? "/" : "");
		}
		console.log("Got status " + payload + " for " + realtopic);

		var id = realtopic.replace(/\//g, '-');
		var box = $('#' + id);
		var s = payload;

		if (s == 1) {
			classname = 'fixed-size-square green hovr';
		} else if (s == 0) {
			classname = 'fixed-size-square red hovr';
		} else {
			classname = 'fixed-size-square yellow hovr';
		}

		if (box.length == 1) {
			// $(box).addClass('boxred').removeClass('boxgreen');
			$(box).attr("class", classname);
		}
		return;
	}

    };


    $(document).ready(function() {

    	var tlist = config.topics;
	var sub = [];

	for (var n = 0; n < tlist.length; n++) {
		sub.push(tlist[n]);
		sub.push(tlist[n] + '/status');
	}
	mqtt_setup(sub, handlerfunc, errorfunc);
        mqtt_connect();

    });

    </script>


% include('tbsbot.tpl')
