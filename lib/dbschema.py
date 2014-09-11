#!/usr/bin/env python

from peewee import *
from cf import conf
import datetime
import os
import sys

cf = conf(os.getenv('WAPPCONFIG', 'wapp.conf'))

sql_db = None
if (cf.g('database', 'dbengine', 'mysql') == 'postgresql'):
    # Use PostreSQL configuration
    sql_db = PostgresqlDatabase(cf.g('database', 'dbname', 'owntracks'),
        user=cf.g('database', 'dbuser'),
        port=cf.g('database', 'dbport', 5432),
        threadlocals=True)
else:
    sql_db = MySQLDatabase(cf.g('database', 'dbname', 'owntracks'),
        user=cf.g('database', 'dbuser'),
        passwd=cf.g('database', 'dbpasswd'),
        host=cf.g('database', 'dbhost', 'localhost'),
        port=cf.g('database', 'dbport', 3306),
        threadlocals=True)


class OwntracksModel(Model):

    class Meta:
        database = sql_db

class Location(OwntracksModel):
    topic           = BlobField(null=False)
    username        = CharField(null=False)
    device          = CharField(null=False)
    tid             = CharField(null=False, max_length=2)
    lat             = DecimalField(null=False, max_digits=10, decimal_places=7)
    lon             = DecimalField(null=False, max_digits=10, decimal_places=7)
    tst             = DateTimeField(default=datetime.datetime.now, index=True)
    acc             = DecimalField(null=False, max_digits=6, decimal_places=1)
    batt            = DecimalField(null=False, max_digits=3, decimal_places=1)
    waypoint        = TextField(null=True)  # desc in JSON, but desc is reserved SQL word
    event           = CharField(null=True)
    vel             = DecimalField(max_digits=4, decimal_places=1)
    cog             = DecimalField(max_digits=3, decimal_places=0)
    trip            = IntegerField(null=True)
    dist            = IntegerField(null=True)
    t               = CharField(null=False, max_length=1)
    # optional: full JSON of item including all data from plugins
    json            = TextField(null=True)

    class Meta:
        indexes = (
            # Create non-unique on username, device
            (('username', 'device'), False),

            # Create non-unique on tid
            (('tid'), False),
        )

class Waypoint(OwntracksModel):
    topic           = BlobField(null=False)
    username        = CharField(null=False)
    device          = CharField(null=False)
    lat             = DecimalField(null=False, max_digits=10, decimal_places=7)
    lon             = DecimalField(null=False, max_digits=10, decimal_places=7)
    tst             = DateTimeField(default=datetime.datetime.now)
    rad             = IntegerField(null=True)
    waypoint        = CharField(null=True)

    class Meta:
        indexes = (
            # Create a unique index on tst
            (('tst', ), True),
        )

class Geo(OwntracksModel):
    # warning: shorter fields for lat, lon
    lat             = DecimalField(null=False, max_digits=6, decimal_places=3)
    lon             = DecimalField(null=False, max_digits=6, decimal_places=3)
    rev             = CharField(null=False)

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
