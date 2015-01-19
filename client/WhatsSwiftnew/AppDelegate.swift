//
//  AppDelegate.swift
//  WhatsSwiftnew
//
//  Created by Janssen, Lukas on 15.12.14.
//  Copyright (c) 2014 Janssen, Lukas. All rights reserved.
// http://141.18.49.242/ws2/

// TODO: Verbindungsstatus richtig angeben wenn verbunden

import Cocoa
import Foundation


private let queue_serial = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

infix operator ~> {}
func ~> (
    backgroundClosure: () -> (),
    mainClosure:       () -> ())
{
    dispatch_async(queue_serial) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var gui_tf_name: NSTextField!
    @IBOutlet weak var gui_tf_ip: NSTextField!
    @IBOutlet weak var gui_tf_nachricht: NSTextField!
    @IBOutlet weak var gui_label_verbindungsstatus: NSTextField!
    @IBOutlet weak var gui_progress: NSProgressIndicator!
    @IBOutlet weak var gui_test_scrollview: NSScrollView!
    @IBOutlet var gui_ScrollableTextView: NSTextView!
    
    var refresh_timer = NSTimer()
    var name = "default";
    var serverIP = "127.0.0.1"
    var clientNamens: Dictionary <String, NSColor> = Dictionary()
    var myMessage: message = message()
    var myMessageSound = NSSound(named: "Pop.aiff")
    var myErrorSound = NSSound(named: "Funk.aiff")
    var myConnection: Connection = Connection();

    
    @IBAction func gui_btn_verbinden(sender: NSButton) {
        
        if (gui_tf_name.stringValue.isEmpty || gui_tf_ip.stringValue.isEmpty || gui_label_verbindungsstatus.stringValue != "Getrennt") {
            myErrorSound?.play()
            writeRedMessageToTextView("Bitte Name und Server-IP eingeben.")
            return;
        }

        name = gui_tf_name.stringValue;
        serverIP = gui_tf_ip.stringValue;
        
        if (!isValidIp(serverIP)){
            myErrorSound?.play()
            writeRedMessageToTextView("Bitte gültige Server-IP eingeben.")
            return;
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.myConnection.receiveMsg();
            }
            sendMessageOverConnection(0, msg: "");
            gui_progress.hidden = false;
            gui_progress.startAnimation(self);
            gui_label_verbindungsstatus.stringValue = "Verbinde";
            gui_tf_name.editable = false;
            gui_tf_ip.editable = false;
            refresh_timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateGui_task"), userInfo: nil, repeats: true)
        }
    }

    @IBAction func gui_btn_trennen(sender: NSButton) {
        sendMessageOverConnection(1, msg: "");
        refresh_timer.invalidate();
        gui_tf_name.editable = true;
        gui_tf_ip.editable = true;
        if (gui_label_verbindungsstatus.stringValue != "Getrennt") {
            gui_label_verbindungsstatus.stringValue = "Getrennt";
            gui_progress.hidden = true;
            gui_progress.stopAnimation(self)
            writeRedMessageToTextView("Verbindung wurde getrennt.");
        }
    }

    func writeRedMessageToTextView(str: String) {
    
        var anfang = gui_ScrollableTextView.string?.utf16Count
        self.gui_ScrollableTextView.insertText(str +  "\n");
        var laenge = str.utf16Count;
        gui_ScrollableTextView.setTextColor(NSColor.redColor(), range: NSMakeRange(anfang!, laenge))
    
    }
    
    @IBAction func gui_btn_senden(sender: NSButton) {
        performActionToSendMessage();

    }
    
    @IBAction func gui_tf_onEnter(sender: NSTextField) {
        performActionToSendMessage();
    }
    
    func performActionToSendMessage() {
        if (!gui_tf_nachricht.stringValue.isEmpty) {
            sendMessageOverConnection(3, msg: gui_tf_nachricht.stringValue);
            gui_tf_nachricht.stringValue = "";
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        gui_label_verbindungsstatus.stringValue = "Getrennt";
        dispatch_async(dispatch_get_main_queue()) {
            self.myConnection.receiveMsg();
        }
       // sendMessageOverConnection(1, msg: ""); // TODO soll das drinn bleiben?
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        sendMessageOverConnection(1, msg: ""); // trennen
    }

    func sendMessageOverConnection(type: Int, msg: String) {

        myMessage.ip = serverIP;
        myMessage.name = name;
        myMessage.type = type;
        myMessage.port = 8585; //TODO welcher Port?
        myMessage.message = msg;
        dispatch_async(dispatch_get_main_queue()) {
            self.myConnection.sendMessage(self.myMessage);
        }
    }
    
    func updateGui_task () {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateGUI ();
        }
    }
    

    func updateGUI () {

        
        // Kann ev. mit MyMessage ausgetauscht werden.
        var msg:message = message();
        self.myConnection.receiveMsg();
        msg = self.myConnection.receiveMessage();
        
        switch msg.type {
            
        case 3: // Message
            if (!msg.message.isEmpty && !msg.name.isEmpty) {
               // println("Message erhalten!!!")
                myMessageSound?.play();
                addInList(msg.name);
                
                var anfang = gui_ScrollableTextView.string?.utf16Count
                self.gui_ScrollableTextView.insertText(msg.name +  "\n");
                var laenge = msg.name.utf16Count;
                self.gui_ScrollableTextView.insertText(msg.message + "\n");
                gui_ScrollableTextView.setTextColor(clientNamens[msg.name], range: NSMakeRange(anfang!, laenge)) // Merke: Range will nicht anfang und ende sondern anfang und anzahl zeichen! NSMakeRange(5,10) würde also bis 15 gehen.
            }
            return;
            
        case 2: // Echo
            gui_progress.stopAnimation(self);
            gui_progress.hidden = true;
            gui_label_verbindungsstatus.stringValue = "Verbunden";
          //  writeRedMessageToTextView(msg.message)
            sendMessageOverConnection(2, msg: "echo")
            return;
        case 1: // Disconnect
            return;
        case 0: // Connect
            return;
        default:
            return;
        }
    }

    func addInList(member: String) ->Bool {

        if(clientNamens[member] != nil) {
            return true;
        } else {
            clientNamens[member] = getRandomColor();
            return false;
        }
    }
}

