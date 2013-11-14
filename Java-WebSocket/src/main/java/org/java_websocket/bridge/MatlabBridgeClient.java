package org.java_websocket.bridge;

import java.net.URI;
import java.net.URISyntaxException;

import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JFrame;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_10;
import org.java_websocket.drafts.Draft_17;
import org.java_websocket.handshake.ServerHandshake;


public class MatlabBridgeClient extends WebSocketClient {

    private List _listeners = new ArrayList();
    private ShutdownButton button = new ShutdownButton();


    // Constructors
    public MatlabBridgeClient( URI serverUri, Draft draft ) {
		super( serverUri, draft );
		this.button.setVisible(true);
    }

    public MatlabBridgeClient( URI serverURI ) {
		super( serverURI );
		this.button.setVisible(true);
    }

    // Shut down button
    private class ShutdownButton extends JFrame {
		public ShutdownButton() {
		    int x = 300;
		    int y = 100;
		    JPanel panel = new JPanel();
		    getContentPane().add(panel);
		    
		    panel.setLayout(null);
		    
		    JButton quitButton = new JButton("Manually Close Java Websocket");
		    quitButton.setBounds(5,5,x-10,y-35);
		    quitButton.addActionListener(new ActionListener() {
			    public void actionPerformed(ActionEvent event) {
				onPress();
			    }
			});
		    panel.add(quitButton);
		    setTitle("Java Websocket Open");
		    setSize(x,y);
		    setLocationRelativeTo(null);
		    setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		}

		private void onPress() {
		    close();
		    dispose();		
		}
    }
	
	// For testing purposes
    public static void main( String[] args ) throws URISyntaxException {
    	// more about drafts here: http://github.com/TooTallNate/Java-WebSocket/wiki/Drafts
		MatlabBridgeClient c = new MatlabBridgeClient( new URI( "ws://127.0.0.1:9000" ), new Draft_17() ); 
		c.connect();
    }

    /*********** JAVA Callbacks ***********/
    // Override from WebSocketClient

    @Override
    public void onOpen( ServerHandshake handshakedata ) {
		String openMessage = "[JAVA] Opened connection."; 
		System.out.println( openMessage );

		MatlabEvent matlab_event = new MatlabEvent( this, openMessage);
		Iterator listeners = _listeners.iterator();
		while (listeners.hasNext() ) {
		    ( (MatlabListener) listeners.next() ).onOpen( matlab_event );
		}
    }

    @Override
    public void onMessage( String message ) {
		_fireMatlab( message );
    }

    @Override
    public void onClose( int code, String reason, boolean remote ) {
		// The codecodes are documented in class org.java_websocket.framing.CloseFrame
		String outMessage = "[JAVA] Connection closed by " + ( remote ? "remote peer." : "us." );
		System.out.println( outMessage );
		this.button.dispose();

		MatlabEvent matlab_event = new MatlabEvent( this, outMessage);
		Iterator listeners = _listeners.iterator();
		while (listeners.hasNext() ) {
		    ( (MatlabListener) listeners.next() ).onClose( matlab_event );
		}
    }
    
    @Override
	public void onError( Exception ex ) {
		System.out.println("[JAVA]: error received.");
		ex.printStackTrace();
		// if the error is fatal then onClose will be called additionally
    }
 

    /*********** MATLAB CALLBACKS ***********/

    // Methods for handling matlab as a listener. Automatically managed by matlab.
    public synchronized void addMatlabListener( MatlabListener l ) {
		_listeners.add( l );
    }

    public synchronized void removeMatlabListener( MatlabListener l) {
		_listeners.remove( l );
    }

    private synchronized void _fireMatlab(String message) {
		MatlabEvent matlab_event = new MatlabEvent( this, message);
		Iterator listeners = _listeners.iterator();
		while (listeners.hasNext() ) {
		    ( (MatlabListener) listeners.next() ).onMessage( matlab_event );
		}
    }

    // Methods that define callbacks in Matlab.
    // Inside Matlab, they need to be referenced for example as 'OnOpenCallback'
    public interface MatlabListener extends java.util.EventListener {
    	void onOpen( MatlabEvent event );
		void onMessage( MatlabEvent event );
		void onError( MatlabEvent event );
		void onClose( MatlabEvent event );
    }

    // Object given to Matlab when an event occur 
    public class MatlabEvent extends java.util.EventObject {
		public String message;
		public MatlabEvent( Object obj, String message) {
		    super( obj );
		    this.message = message;
		}
	}
    
}

