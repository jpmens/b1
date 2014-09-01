#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__    = 'Jan-Piet Mens <jpmens()gmail.com>'
__copyright__ = 'Copyright 2014 Jan-Piet Mens'

import sys
sys.path.insert(0, './lib')
import bottle
from bottle import response, template, static_file, request
import json
from haversine import haversine
try:
    from cStringIO import StringIO
except:
    from StringIO import StringIO
import os
import codecs
from datetime import datetime
from dateutil import tz
from xml.etree.ElementTree import Element, SubElement, Comment, tostring
from xml.etree import ElementTree as ET
from ElementTree_pretty import prettify
from cf import conf
from dbschema import Location, fn

cf = conf(os.getenv('WAPPCONFIG', 'wapp.conf'))

POINT_KM = 2

app = application = bottle.Bottle()
bottle.SimpleTemplate.defaults['get_url'] = app.get_url

# FIXME: load from dict     app.config.load_config('jjj.conf')

def getDBdata(username, device, from_date, to_date, spacing):

    track = []

    to_date = "%s 23:59:59" % to_date
    print "FROM=%s, TO=%s" % (from_date, to_date)

    query = Location.select().where(
                (Location.username == username) &
                (Location.device == device) &
                (Location.tst.between(from_date, to_date))
                )
    query = query.order_by(Location.tst.asc())
    for l in query:

        dbid    = l.id
        lat     = float(l.lat)
        lon     = float(l.lon)
        dt      = l.tst
        weather = l.weather
        revgeo  = l.revgeo

        # FIXME: add vel, cog from json
        # FIXME: add distance haversine to previous point

        tp = {
            'lat' : float(l.lat),
            'lon' : float(l.lon),
            'tst' : l.tst,
            'weather' : l.weather,
            'revgeo'  : l.revgeo,
        }

        track.append(tp)

    return track

@app.hook('config')
def on_config_change(key, new_val):
    print "****** warning: config changes: ", key, " == ", new_val

@app.hook('after_request')
def enable_cors():
    response.headers['Access-Control-Allow-Origin'] = '*'

@app.route('/')
def index():
    return template('index', dict(name="JP M", age=69))

@app.route('/about')
def page_about():

    # FIXME: example:
    app.config.update('m2s', dbname="FOOFOFO")

    return template('about')

@app.route('/console')
def page_console():
    return template('console')

@app.route('/map')
def page_map():
    return template('map')

@app.route('/table')
def page_table():
    return template('table')

@app.route('/tracks')
def page_tracks():
    return template('tracks')

@app.route('/hello')
def hello():
    data = {
        'name' : "JP Mens",
        'number' : 69,
    }
    return data

@app.route('/config.js')
def config_js():
    ''' Produce a `config.js' from the [websocket] section of our config
        file. '''

    newconf = cf.config('websocket')
    for key in newconf:
        if type(newconf[key]) == bool:
            newconf[key] = 'true' if newconf[key] else 'false';
        #if type(newconf[key]) == 'NoneType':
        #    newconf[key] = 'null'
        print key, " = ", type(newconf[key]), " : ",  newconf[key]

    response.content_type = 'text/javascript; charset: UTF-8'
    return template('config-js', newconf)

@app.route('/db')
def f1():

    username = 'jpm'
    device = '5s'
    from_date = '2014-08-25'
    to_date = '2014-08-27'

    list = []

    query = Location.select().where(
                (Location.username == username) &
                (Location.device == device) &
                (Location.tst.between(from_date, to_date))
                )
    query = query.order_by(Location.tst.asc())
    for l in query:

        topic   = l.topic

        list.append( [ l.lat, l.lon] )
        print topic

    print list
    return dict(names=list)

@app.route('/api/userlist')
def users():
    ''' Get list of username - device pairs to populate a select box
        the id in that select will be set to username|device '''

    userlist = []

    distinct_list = Location.select(Location.username, Location.device).distinct()
    for u in distinct_list:

        user = {
            'id'    : "%s|%s" % (u.username, u.device),
            'name'  : "%s - %s" % (u.username, u.device),
        }
        userlist.append(user)

    return dict(userlist=userlist)

# ?userdev=alx%7Cy300&fromdate=2014-08-19&todate=2014-08-20&format=tx
@app.route('/api/download', method='GET')
def get_download():
    mimetype = {
        'csv':  'text/csv',
        'txt':  'text/plain',
        'gpx':  'application/gpx+xml',
    }

    userdev = request.params.get('userdev')
    from_date = request.params.get('fromdate')
    to_date = request.params.get('todate')
    fmt = request.params.get('format')

    if fmt not in mimetype:
        return { 'error' : "Unsupported download-type requested" }

    username, device = userdev.split('|')
    trackname = 'owntracks-%s-%s-%s-%s' % (username, device, from_date, to_date)
    
    track = getDBdata(username, device, from_date, to_date, None)

    # Let's run through this data to get a total trip distance in km.

    kilometers = 0.0
    n = 1
    for tp in track[0:-1]:
        distance = haversine(tp['lon'], tp['lat'], track[n]['lon'], track[n]['lat'])
        kilometers += distance
        n += 1

    sio = StringIO()
    s = codecs.getwriter('utf8')(sio)

    if fmt == 'txt':

        s.write("%-10s %-10s %s\n" % ("Latitude", "Longitude", "Timestamp (UTC)"))

        for tp in track:

            revgeo = tp.get('revgeo', "")

            s.write(u'%-10s %-10s %s %-14s %s\n' % \
                (tp.get('lat'),
                tp.get('lon'),
                tp.get('tst'),
                tp.get('weather', ""),
                revgeo))
        s.write("\nTrip: %.2f kilometers" % (kilometers))

    if fmt == 'csv':

        tp = track[0]
        title = ""
        for key in tp.keys():
            title = title + u'"%s";' % key

        s.write("%s\n" % title[0:-1])  # chomp last separator

        for tp in track:
            line = ""
            for key in tp:
                line = line + u'"%s";' % tp[key]

            s.write(u'%s\n' % line)

    if fmt == 'gpx':
        root = ET.Element('gpx')
        root.set('version', '1.0')
        root.set('creator', 'OwnTracks GPX Exporter')
        root.set('xmlns', "http://www.topografix.com/GPX/1/0")
        root.append(Comment('JP'))

        gpxtrack = Element('trk')
        track_name = SubElement(gpxtrack, 'name')
        track_name.text = trackname
        track_desc = SubElement(gpxtrack, 'desc')
        track_desc.text = "Trip: %.2f kilometers" % (kilometers)

        segment = Element('trkseg')
        gpxtrack.append(segment)

        trackpoints = []

        for tp in track:
            t = Element('trkpt')
            t.set('lat', str(tp['lat']))
            t.set('lon', str(tp['lon']))
            t_time = SubElement(t, 'time')
            t_time.text = tp['tst'].isoformat()[:19]+'Z'
            # t.append(Comment(u'#%s %s' % (dbid, topic)))
            trackpoints.append(t)

        root.append(gpxtrack)
        for trackpoint in trackpoints:
            segment.append(trackpoint)

        s.write(prettify(root))



    content_type = 'application/binary'
    if fmt in mimetype:
        content_type = mimetype[fmt]

    s.seek(0, os.SEEK_END)
    octets = s.tell()

    response.content_type = content_type
    response.headers['Content-Disposition'] = 'attachment; filename="%s.%s"' % (trackname, fmt)
    response.headers['Content-Length'] = str(octets)

    return s.getvalue()


@app.route('/api/getGeoJSON', method='POST')
def get_geoJSON():
    data = json.load(bottle.request.body)

    # needs LOTS of error handling

    userdev = data.get('userdev')
    username, device = userdev.split('|')
    from_date = data.get('fromdate')
    to_date = data.get('todate')
    spacing = int(data.get('spacing', POINT_KM))

    track = getDBdata(username, device, from_date, to_date, spacing)

    last_point = [None, None]

    collection = {
            'type' : 'FeatureCollection',
            'features' : [],        # [ geo, <list of points> ]
    }


    geo = {
            'type' : 'Feature',
            'geometry' : {
                    'type' : 'LineString',
                    'coordinates' : []
                  },
            'properties' : {
                    'description' : "an OwnTracks track",
                  },
    }

    pointlist = []
    track_coords = []

    for tp in track:

        lat = tp['lat']
        lon = tp['lon']
        tst = tp['tst']

        description = str(tst)
        
        if tp.get('weather') is not None:
            description = description + " %s" % tp.get('weather')
        if tp.get('revgeo') is not None:
            description = description + " %s" % tp.get('revgeo')

        track_coords.append( [ lon, lat ] )


        distance = None
        if last_point[0] is not None:
            distance = haversine(lon, lat, last_point[0], last_point[1])

        if last_point[0] is None or distance > spacing:
            last_point = [lon, lat]
            point = {
                    'type'  : 'Feature',
                    'geometry' : {
                        'type'  : "Point",
                        'coordinates' : [lon, lat],
                    },
                    'properties' : {
                        'description' : description,
                    }
            }
            pointlist.append(point)


    geo['geometry']['coordinates'] = track_coords

    collection['features'] = [ geo ]
    for p in pointlist:
        collection['features'].append(p)

    return collection

@app.route('/<filename:re:.*\.js>')
def javascripts(filename):
    return static_file(filename, root='static')

#    return static_file(filename, root='files', mimetype='image/png')

# <link type='text/css' href='yyy.css' rel='stylesheet' >
@app.route('/<filename:re:.*\.css>', name='css')
def stylesheets(filename):
    return static_file(filename, root='static')

@app.get('/<filename:re:.*\.(jpg|gif|png|ico)>')
def images(filename):
    return static_file(filename, root='static')

# from: http://michael.lustfield.net/nginx/bottle-uwsgi-nginx-quickstart
class StripPathMiddleware(object):
    '''
    Get that slash out of the request
    '''
    def __init__(self, a):
        self.a = a
    def __call__(self, e, h):
        e['PATH_INFO'] = e['PATH_INFO'].rstrip('/')
        return self.a(e, h)

if __name__ == '__main__':
    bottle.debug(True)
    bottle.run(app=StripPathMiddleware(app),
        # server='python_server',
        # host='0.0.0.0',
        port=8080,
        reloader=True)
