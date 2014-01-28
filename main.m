clear

% Specify the IP address of the iOS device.
% The device must be in the same network.
% The port is always 9000.
master_uri = 'ws://128.31.34.250:9000';
figure;
ws = websocket_bridge(master_uri);


