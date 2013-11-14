
classdef websocket_bridge < handle
            
    properties 
        client  % Java websocket client object
    end 
    
    
    properties (SetAccess = private)
        MASTER_URI % Java URI object of the websocket
        message % Latest message received from websocket
        status_level % The current level of ROS statuses being sent by rosbridge
    end 
    
    
    methods
        
        function obj = websocket_bridge(master_uri)
            % Constructor for MatlabBridge object
            %   object = websocket_bridge(master_uri)
            %   master_uri is a string for the server websocket location
            %   Example: 'ws://localhost:9000'
            %
            %   Function:
            %   Imports URI class and MatlabBridgeClient class
            %   Creates and opens websocket
            
                      
            % For callbacks to work, must use static classpath by editing
            % classpath.txt
            % Try using matlab handle callback on message property instead
            % of java callback...
            import java.net.URI
            import org.java_websocket.bridge.*
            
            
            % Drafts define the version protocol to be used for the
            % websocket connection
            % More about drafts here: http://github.com/TooTallNate/Java-WebSocket/wiki/Drafts
            draft = org.java_websocket.drafts.Draft_17();
            % Create java.net.URI object for the provided URI
            obj.MASTER_URI = URI(master_uri);
            % Create ROSBridgeClient object
            obj.client = MatlabBridgeClient(obj.MASTER_URI, draft);
            
            % Connect to websocket
            obj.client.connect()
            
            % Set callbacks 
            set(obj.client, 'OnOpenCallback', @(h,e) obj.open_callback(h,e));
            set(obj.client, 'OnMessageCallback', @(h,e) process_message(h,e)); %custom method to process the request
            set(obj.client, 'OnErrorCallback', @(h,e) obj.error_callback(h,e));
            set(obj.client, 'OnCloseCallback', @(h,e) obj.close_callback(h,e) );
        end 
         
        function delete(obj)
            % Destructor
            % Closes the websocket if it's open.
            
            if strcmp(obj.client.getReadyState(),'OPEN')
                obj.close();
            end
        end 
        
        
        function send(obj, message)
            % Send a message (string) through the websocket to the server
            
            % forced run synch in the main java thread
            javaMethodMT('send', obj.client, message);
            pause(0.005); % Pause for java function call to complete
        end 
        
        function close(obj)
            % Close the websocket connection
            
            obj.client.close()
        end 
    end 
    
    
    methods (Access = private)
        
        function open_callback(obj, ~, e)
            disp('connection open.')
        end
        
        function message_callback(obj, ~, e)
            disp('received message.')
        end 
        
        function error_callback(obj, ~, e)
            disp ('error received.')
        end
        
        function close_callback(obj, ~, e)
            disp ('connection closed.')
        end 
    end
    
end


