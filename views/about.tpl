% include('tbstop.tpl', page='about', page_title='OwnTracks About')


	<h2>About</h2>

	<p>bla bla</p>


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
		$(document).ready(function() {
		    var max_fields      = 10; //maximum input boxes allowed
		    var matrix = $("#matrix");

		    
		    for (var x = 1; x < 10; x++ ){
			    var name = "x" + x;

			    field = '<input type="text" class="boxgreen" id="' + name + '" value="' + name + '" readonly />';
			    $(matrix).append(field);
			}

		    var box = $('#' + 'x1');
		    console.log(box.length);

		  $('input:text').focus(function(){
		  	console.log( $(this).val() );
		  });

		});
	</script>

% include('tbsbot.tpl')
