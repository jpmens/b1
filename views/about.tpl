% include('tbstop.tpl', page='about', page_title='OwnTracks About')


	<h2>About</h2>

	<p>bla bla</p>


    <link href="css/datepicker.css" rel="stylesheet">
    <link href="css/datepicker3.css" rel="stylesheet">
    <script src="js/bootstrap-datepicker.js" type="text/javascript"></script>


<div class="input-daterange input-group" id="datepicker">
    <input type="text" class="input-sm form-control" name="start" />
    <span class="input-group-addon">to</span>
    <input type="text" class="input-sm form-control" name="end" />
</div>

<div id='jpd'></div>

<script type="text/javascript">

// $('.input-daterange').datepicker({
$('#jpd').datepicker({
    format: "yyyy-mm-dd",
    autoclose: true,
    multidate: 2,
    multidateSeparator: ',',
    todayHighlight: true
}).on('changeDate', function(e){
	console.log("dates = " + e.dates)
	console.log("date = " + e.date)
	console.log("----------");
	console.log( $('#jpd').datepicker('getUTCDates' )  );
	console.log( $('#jpd').datepicker('getDates' )  );
});

</script>



% include('tbsbot.tpl')
