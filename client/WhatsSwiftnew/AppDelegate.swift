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
    var myConnection: Connection = Connection(rcv_port: 5252, send_port: 8585);

    
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
                self.myConnection.connect()
                self.myConnection.receiveMsg();
            }
            sendMessageOverConnection(0, msg: "");
            gui_progress.hidden = false;
            gui_progress.startAnimation(self);
            gui_label_verbindungsstatus.stringValue = "Verbinde";
            gui_tf_name.editable = false;
            gui_tf_ip.editable = false;
            refresh_timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateGui_taskStarter"), userInfo: nil, repeats: true)
        }
    }

/***********************************************************************************
**** "gui_btn_trennen"                                                          ****
**** - Aufruf von Button Trennen                                                ****
**** - Meldet Client vom Server ab und schließt den Socket                      ****
**** - refresh_timer wird gestoppt damit keine Nachrichten abgefragt werden     ****
**** - Verbindungsstatus wird auf "Getrennt" gesetzt                            ****
**** - Animation bei Verbingungsstatus wird ausgeschaltet und unsichtbar gesetzt****
***********************************************************************************/
    @IBAction func gui_btn_trennen(sender: NSButton) {
        sendMessageOverConnection(1, msg: "");
        myConnection.disconnect()
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
    
/***********************************************************************************
**** "writeRedMessageToTextView"                                                ****
**** - Wird genutzt um z.B. Fehlernachrichten in den Chatverlauf zu schreiben   ****
**** - Eingabeparameter wird in roter Farbe in den Chatverlauf geschrieben      ****
***********************************************************************************/
    func writeRedMessageToTextView(str: String) {
    
        var anfang = gui_ScrollableTextView.string?.utf16Count
        self.gui_ScrollableTextView.insertText(str +  "\n");
        var laenge = str.utf16Count;
        gui_ScrollableTextView.setTextColor(NSColor.redColor(), range: NSMakeRange(anfang!, laenge))
    }
    
/***********************************************************************************
**** "gui_btn_senden"                                                           ****
**** - Aufruf wenn der Senden Button gedrückt wird                              ****
***********************************************************************************/
    @IBAction func gui_btn_senden(sender: NSButton) {
        performActionToSendMessage();
    }
    
/***********************************************************************************
**** "gui_tf_onEnter"                                                           ****
**** - Aufruf wenn im Nachrichtenfeld "gui_tf_nachricht" Enter gedrückt wird    ****
***********************************************************************************/
    @IBAction func gui_tf_onEnter(sender: NSTextField) {
        performActionToSendMessage();
    }

/***********************************************************************************
**** "performActionToSendMessage"                                               ****
**** - Wird von gui_btn_senden und gui_tf_onEnter aufgerufen                    ****
**** - Prüft ob Nachrichtenfeld leer ist, zu viele Zeichen oder eine ungültige  ****
****   Eingabe gemacht wurde, falls nicht wird eine Nachricht an                ****
****   "sendMessageOverConnection" mit ensprechendem Typ weiter gegeben         ****
**** - Anschließend wird das Nachrichtenfeld geleert                            ****
***********************************************************************************/
    func performActionToSendMessage() {
        if (!(gui_tf_nachricht.stringValue.isEmpty) && !(gui_label_verbindungsstatus.stringValue == "Getrennt")) {
            
            // separation array
            if (gui_tf_nachricht.stringValue.utf16Count > 600) {
                writeRedMessageToTextView("Zu viele Zeichen");
            } else if (gui_tf_nachricht.stringValue.componentsSeparatedByString( ">|<" ).count > 1) {
                writeRedMessageToTextView("Ungültige Eingabe");
            } else {
                sendMessageOverConnection(3, msg: gui_tf_nachricht.stringValue);
                gui_tf_nachricht.stringValue = "";
            }
        }
    }

/***********************************************************************************
**** "applicationDidFinishLaunching"                                            ****
**** - Hier können Initialisierungen vorgenommen werden                         ****
***********************************************************************************/
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        gui_label_verbindungsstatus.stringValue = "Getrennt";
        gui_ScrollableTextView.font = NSFont(name:"HelveticaNeue-Bold", size: 12)
    }

/***********************************************************************************
**** "applicationWillTerminate"                                                 ****
***********************************************************************************/
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
/***********************************************************************************
**** "applicationWillTerminate"                                                 ****
**** - Hier werden die letzten Aktionen vor dem Programmende ausgeführt         ****
**** - Meldet sich vom Server ab                                                ****
**** - Schließt den Socket                                                      ****
***********************************************************************************/
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        
        sendMessageOverConnection(1, msg: ""); // trennen
        myConnection.disconnect()
        return true;
    }
    
/***********************************************************************************
**** "sendMessageOverConnection"                                                ****
**** - Bereitet Nachricht(myMessage) vor, die über myConnection versendet wird  ****
**** - Sendet die Nachricht über eine asynchrone Task damit bei längerer        ****
****   Ausführungszeit nicht das GUI eingefroren wird                           ****
***********************************************************************************/
    func sendMessageOverConnection(type: Int, msg: String) {

        myMessage.ip = serverIP;
        myMessage.name = name;
        myMessage.type = type;
        myMessage.port = 8585;
        myMessage.message = msg;
        dispatch_async(dispatch_get_main_queue()) {
            self.myConnection.sendMessage(self.myMessage);
        }
    }
    
/***********************************************************************************
**** "updateGui_taskStarter"                                                    ****
**** - Startet zu jedem Tick von "refresh_timer" einen asynchronen Task         ****
**** - Der Task führt "updateGUI" in jedem zyklus einmal aus                    ****
***********************************************************************************/
    func updateGui_taskStarter () {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateGUI ();
        }
    }

/***********************************************************************************
**** "updateGUI"                                                                ****
**** - Fordert "myConnection" auf nach neuen Nachrichten zu schauen und         ****
****   fragt dessen Empfangspuffer ab                                           ****
**** - Unterscheidet den Nachrichtentyp und ändert entsprechend das GUI         ****
**** - Bei einer Nachrichte wird der Nutzername mit seiner entsprechenden       ****
****   Farbe eingefärbt                                                         ****
**** - Bei einem Echo ist eine Alive-Nachricht, welche beantwortet wird         ****
***********************************************************************************/
    func updateGUI () {

        self.myConnection.receiveMsg();
        self.myMessage = self.myConnection.receiveMessage().msg;
        
        switch myMessage.type {
            
        case 3: // Message
            if (!myMessage.message.isEmpty && !myMessage.name.isEmpty) {
               // println("Message erhalten!!!")
                myMessageSound?.play();
                addInList(myMessage.name);

                var anfang = gui_ScrollableTextView.string?.utf16Count
                self.gui_ScrollableTextView.insertText(myMessage.name +  ":" + "\n");
                var laenge = myMessage.name.utf16Count;
                self.gui_ScrollableTextView.insertText(myMessage.message + "\n" + "\n");
                gui_ScrollableTextView.setTextColor(clientNamens[myMessage.name], range: NSMakeRange(anfang!, laenge))
                
                // Merke: Range will nicht anfang und ende sondern anfang und anzahl zeichen! NSMakeRange(5,10) würde also bis 15 gehen.
            }
            return;
            
        case 2: // Echo
            gui_progress.stopAnimation(self);
            gui_progress.hidden = true;
            gui_label_verbindungsstatus.stringValue = "Verbunden";
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
    
/***********************************************************************************
 **** "addInList"                                                               ****
 **** - Verwaltet das Dictionary <String, NSColor> clientNamens                 ****
 **** - Das Dictionary ermöglich das Einfärben der Nutzernamen im Chat          ****
 **** - Legt für jeden Member (Nutzername) "einen" Eintrag in clientNamens an   ****
 **** - Jeder Eintrag bekommt eine Farbe von getRandomColor() zugewiesen        ****
 **********************************************************************************/
    func addInList(member: String) ->Bool {

        if(clientNamens[member] != nil) {
            return true;
        } else {
            clientNamens[member] = getRandomColor();
            return false;
        }
    }
}

