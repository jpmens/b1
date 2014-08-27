#!/usr/bin/env python

import bottle
from bottle import response, template, static_file
from dbschema import Location, fn
import json

app = application = bottle.Bottle()
bottle.SimpleTemplate.defaults['get_url'] = app.get_url

@app.hook('after_request')
def enable_cors():
    response.headers['Access-Control-Allow-Origin'] = '*'

@app.route('/')
def index():
    return template('index', dict(name="JP M", age=69))

@app.route('/hello')
def hello():
    data = {
        'name' : "JP Mens",
        'number' : 69,
    }
    return data

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

@app.route('/api/getGeoJSON', method='POST')
def get_geoJSON():
    data = json.load(bottle.request.body)

    # needs error handling

    userdev = data.get('userdev')
    username, device = userdev.split('|')
    from_date = data.get('fromdate')
    to_date = data.get('todate')

    geo = {
            'properties' : {
                    # https://github.com/mapbox/simplestyle-spec/tree/master/1.1.0
                    'title' : 'OwnTracks',
                    'description' : "an OwnTracks track",
                  },
            'type' : 'Feature',
            'geometry' : {
                    'type' : 'LineString',
                    'coordinates' : []
                  },
    }
    coords = []

    query = Location.select().where(
                (Location.username == username) &
                (Location.device == device) &
                (Location.tst.between(from_date, to_date))
                )
    query = query.order_by(Location.tst.asc())
    for l in query:

        dbid    = l.id
        lat     = l.lat
        lon     = l.lon

        coords.append( [ lon, lat ] )

    geo['geometry']['coordinates'] = coords

    return geo
    # print json.dumps(geo)

@app.route('/tracks')
def tracks_index():
    return template('tracks', dict(name="JP M", age=69))

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
