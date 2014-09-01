/* Generated from jjj.conf for JavaScript */

var config = {

   // These are the hostname or IP address and the port number of the
   // Websockets-enabled MQTT broker. Note: this is the *Websocket* port.


   host:        '{{ !host }}',
   port:        {{ !port }},

   // experiment

   username:    '{{ !username }}',
   password:    '{{ !password if password else "null" }}',

};
