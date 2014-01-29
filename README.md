API Toolbox 
=================
This library allows you to download detectors and evaluate it from the [DetectMe app](http://detectme.csail.mit.edu). 

Requirements
------------
- iOS device with >=iOS 7 and the DetectMe app on it. 
- User account on DetectMe.
- MATLAB

Installation
------------
In order to authenticate yourself, you will need to add your user and password to the MATLAB library. 

To do so:

1. Go to [Base64Encode](http://www.base64encode.org/), and encode the string "user:password" (without quotation marks) with the base 64 encoder.

2. Open a MATLAB sesion and store the concadenation of the string "Basic " and the encoded string to a variable called "passwordString". 

For instance, for a user called "jon" with password "jonspassword", Jon would need to encode "jon:jonspassword" (the encoded string is "am9uOmpvbnNwYXNzd29yZA==") and the variable passwordString would be: passwordString='Basic am9uOmpvbnNwYXNzd29yZA=='

3. Save this variable in a workspace file and name it "password.mat"

4. Store "password.mat" in /matlab_api/lib/urlread2/


Furthermore, for MATLAB R2013a users in MAC OS X, you would need to activate your parallel cluster by just clicking on Home--->Parallel--->Manage Parallel Profiles. You will need to repeat this process each time you open a MATLAB session.


Usage
-----
The main library functions are:

1. eval_submission: This function evaluate a detector downloaded to DetectMe with a test set of images. The test set could also be downloaded from DetectMe.

2. format_dataset: This function transform a dataset of images downloaded to DetectMe to the format used by the eval_submission function. 

3. format_detector: This function transform a detector downloaded from DetectMe to the format used by the eval_submission function.

4. getdetector: Dowloads the detector and the set of images (to work with it as a test set) of a DetectMe's detector. The identificator used is the detector's ID used in both the iPhone application and the server.

Finally, an example of use of this four functions could be found in "example.m". In this script, a test set and a detector are dowloaded from the server and then are evaluated with eval_submission. Finally, the result are presented, plotting the TOP detections and the TOP false positives. 


Streaming Toolbox
=================

This library allows you to receive the detections (images and bounding boxes) from the [DetectMe app](http://detectme.csail.mit.edu) to your Matlab interface.


Requirements
------------
iOS device with >=iOS 7 and the DetectMe app on it. The device and the matlab terminal have to be in the same network range (i.e. same wi-fi). 



Installation
------------
In order to handle the Java events with Matlab, the Matlab's Java static classpath needs to include the Java-WebSocket library, `java_websocket.jar` located in `/matlab_stream/Java-WebSocket/dist/`. To do so, inside Matlab use `edit('classpath.txt')` and add the absolute location of `java_websocket.jar`.  

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

