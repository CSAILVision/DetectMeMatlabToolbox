
Matlab-Websockets
=================

Simple implementation of websockets in matlab. It uses [Java-WebSockets](https://github.com/TooTallNate/Java-WebSocket) to establish the connection with the server and Java Callbacks inside Matlab to handle the connection. 



Installation
------------
In order to handle the Java events with Matlab, the Matlab's Java static classpath needs to include the Java-WebSocket library, `java_websocket.jar` located in `/Java-WebSocket/dist/`. To do so, inside Matlab use `edit('classpath.txt')` and add the absolute location of `java_websocket.jar`.  

Note: using the dynamic classpath causes many problems that using the static classpath solves.  


Example
------
The example provided reads from a server a stream of images coded in JPEG and base64. 

Credits
-------

This work is based in the [specific implementation](https://github.com/BrendanAndrade/web-matlab-bridge) for ROS system by Brendan Andrade.
At the same time, both of them rely on the websocket library for Java, [Java-WebSockets](https://github.com/TooTallNate/Java-WebSocket).

