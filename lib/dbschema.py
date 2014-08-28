#!/usr/bin/env python

from peewee import *
from config import Config
import datetime
import sys

try:
    cf = Config()
except Exception, e:
    print "Can't load configuration: %s" % (str(e))
    sys.exit(1)

sql_db = None
if(cf.get('dbengine', 'mysql') == 'postgresql'):
    # Use PostreSQL configuration
    sql_db = PostgresqlDatabase(cf.get('dbname', 'owntracks'),
        user=cf.get('dbuser'),
        port=cf.get('dbport', 5432),
        threadlocals=True)
else:
    sql_db = MySQLDatabase(cf.get('dbname', 'owntracks'),
        user=cf.get('dbuser'),
        passwd=cf.get('dbpasswd'),
        host=cf.get('dbhost', 'localhost'),
        port=cf.get('dbport', 3306),
        threadlocals=True)


class OwntracksModel(Model):

    class Meta:
        database = sql_db

class Location(OwntracksModel):
    topic           = BlobField(null=False)
    username        = CharField(null=False)
    device          = CharField(null=False)
    lat             = CharField(null=False)
    lon             = CharField(null=False)
    tst             = DateTimeField(default=datetime.datetime.now, index=True)
    acc             = CharField(null=True)
    batt            = CharField(null=True)
    waypoint        = TextField(null=True)  # desc in JSON, but desc is reserved SQL word
    event           = CharField(null=True)
    # optional: full JSON of item including all data from plugins
    json            = TextField(null=True)
    # the following fields must be correlated to settings.py (plugin columns)
    weather         = CharField(null=True)
    revgeo          = CharField(null=True)

    class Meta:
        indexes = (
            # Create non-unique on username, device
            (('username', 'device'), False),
        )

class Waypoint(OwntracksModel):
    topic           = BlobField(null=False)
    username        = CharField(null=False)
    device          = CharField(null=False)
    lat             = CharField(null=False)
    lon             = CharField(null=False)
    tst             = DateTimeField(default=datetime.datetime.now)
    rad             = CharField(null=True)
    waypoint        = CharField(null=True)

    class Meta:
        indexes = (
            # Create a unique index on tst
            (('tst', ), True),
        )

class Geo(OwntracksModel):
    lat             = CharField(null=False)
    lon             = CharField(null=False)
    rev             = CharField(null=True)

    class Meta:
        indexes = (
            # Create a unique index on tst
            (('lat', 'lon', ), True),
        )

if __name__ == '__main__':
    sql_db.connect()

    try:
        Location.create_table(fail_silently=True)
    except Exception, e:
        print str(e)

    try:
        Waypoint.create_table(fail_silently=True)
    except Exception, e:
        print str(e)

    try:
        Geo.create_table(fail_silently=True)
    except Exception, e:
        print str(e)
