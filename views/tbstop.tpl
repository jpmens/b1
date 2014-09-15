<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="images/favicon.ico">

    <title>{{ page_title}}</title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/navbar-fixed-top.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->


    <link rel="stylesheet" href="css/track.css" />
    <link rel="stylesheet" href="css/leaflet.css" />
    <link rel="stylesheet" href="css/leaflet.label.css" />
    <link rel="stylesheet" href="css/tinycolorpicker.css" type="text/css" media="screen"/>

    <script src="js/leaflet.js"></script>
    <!-- https://github.com/Leaflet/Leaflet.label -->
    <script src="js/leaflet.label.js"></script>

    <script type="text/javascript" charset="utf8" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery.tinycolorpicker.min.js"></script>

    <!-- http://johnculviner.com/jquery-file-download-plugin-for-ajax-like-feature-rich-file-downloads/ -->
    <script type="text/javascript" src="js/jquery.fileDownload.js"></script>

  </head>

  <body>

    <!-- Fixed navbar -->
    <div class="navbar navbar-default navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">OwnTracks</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li class="{{ "active" if page == "index" else "xxxx" }}" ><a href="/">Home</a></li>
            <li class="{{ "active" if page == "about" else "xxxx" }}" ><a href="about">About</a></li>
            <li class="{{ "active" if page == "map" else "xxxx" }}" ><a href="map">Map</a></li>
            <li class="{{ "active" if page == "table" else "xxxx" }}" ><a href="table">Table</a></li>
            <li class="{{ "active" if page == "tracks" else "xxxx" }}" ><a href="tracks">Tracks</a></li>
            <li class="{{ "active" if page == "console" else "xxxx" }}" ><a href="console">Console</a></li>
            <li class="{{ "active" if page == "status" else "xxxx" }}" ><a href="status">Status</a></li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li class="{{ "active" if page == "YYYYY" else "xxxx" }}" ><a href="#">Default</a></li>
            <li class="{{ "active" if page == "hw" else "xxxx" }}" ><a href="hw">Hardware</a></li>
            <li ><a href="#">Fixed top</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>

    <div class="container">
    <!-- end of tbstop.tpl -->

