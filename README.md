
Streaming Toolbox
=================

This library allows you to receive the detections (images and bounding boxes) from the [DetectMe app](http://detectme.csail.mit.edu) to your Matlab interface.


Requirements
------------
iOS device with >=iOS 7 and the DetectMe app on it. The device and the matlab terminal have to be in the same network range (i.e. same wi-fi). 



Installation
------------
In order to handle the Java events with Matlab, the Matlab's Java static classpath needs to include the Java-WebSocket library, `java_websocket.jar` located in `/Java-WebSocket/dist/`. To do so, inside Matlab use `edit('classpath.txt')` and add the absolute location of `java_websocket.jar`.  

Note: using the dynamic classpath causes some problems that using the static classpath solves.  


Usage
-----
1.  Set the iOS device to the same Wi-Fi network as your desktop computer.
2.  Obtain the IP Address of the iOS device. Use that address to set the `master_uri` variable in `main.m`.
3.  Run the DetectMe app on the iOS device and hit the `stream` button (top right corner) to turn the device into a streaming server.
4.  Finally, run `main.m` to see the pictures and detections inside matlab.

The DetectMe app is able to turn the iOS device into a WebSocket server that streams the images captured as well as the detection. The images and the detections are
send as JSON objects. The file `process_message.m` is the responsible to translate this JSON objects into Matlab structures and draw the image and the detections.

See the [official documentation](detectme.csail.mit.edu/api_documentation/) for further details.


Credits
-------

This work is based in the [specific implementation](https://github.com/BrendanAndrade/web-matlab-bridge) for ROS system by Brendan Andrade.
At the same time, both of them rely on the websocket library for Java, [Java-WebSockets](https://github.com/TooTallNate/Java-WebSocket).

