/* Generated from jjj.conf for JavaScript */

var config = {

   // These are the hostname or IP address and the port number of the
   // Websockets-enabled MQTT broker. Note: this is the *Websocket* port.


   host:        {{ !host }},
   port:        {{ !port }},
   usetls:      {{ !usetls }},
   cleansession:      {{ !cleansession }},

   // experiment

   username:    {{ !username if username else "null" }},
   password:    {{ !password if password else "null" }},

   topic: 	{{ !topic }},
   apikey: 	{{ !apikey }},

   // should be obsoleted
   geoupdate : {{ !geoupdate }},
   geofences:    {{ !geofences if geofences else "null" }},

};
