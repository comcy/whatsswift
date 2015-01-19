//
//  WSConnector.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 12.01.15.
//  Copyright (c) 2015 Bauer, Daniel. All rights reserved.
//
/*
Diese Klasse stellt einen Websocket Client zur Verfügung. Dieser basiert auf dem Startsream Framework
Links:
 https://github.com/daltoniam/starscream
 https://www.websocket.org/echo.html
 https://github.com/Flynsarmy/PHPWebSocket-Chat
 https://github.com/james2doyle/php-socket-chat

Der Chatserver stellt eine Verbindung zum Websocket Server her und verwaltet die Nachrichten. Eine Sessionverwaltung wurde nicht in PHP implementiert. Somit wird der Chatserver nur als ein Client im Server angezeigt. Benutzernamen werden angezeigt. Eine Benutzerverwaltung muss in PHP mit dem Message Typ implementiert werden. Error Messages werden ausgelesen und im Log angezeigt.

Dazu wird noch ein Websocket Server benötigt. Dieser wurde angepasst und ist ebenfalls Teil des Repos. Anleitung zum Server in der Readme.md. Es wird ein Webserver mit PHP benötigt....

*/

/* import */
import Foundation
import StarscreamOSX

/* ---------------------------- */
/* websocket connection */
class ws_connect: WebSocketDelegate {
    
    /* ---------------------------- */
    /* socket */
    var socket = WebSocket(url: NSURL(scheme: "ws", host: "\(ws_sock_server_ip):\(ws_sock_server_port)", path: "/")!)
    
    /* ---------------------------- */
    /* vars */
    var connected:Bool = false
    var error_text:String = ""
    var server_name:String = ""
    var buffer:Connection = Connection()
    var state:String = ""
    var lastState:String = ""
    
    /* ---------------------------- */
    /* async gcd */
    private let queue_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let queue_concur = dispatch_queue_create ("concur" , DISPATCH_QUEUE_CONCURRENT)
    private let queue_serial = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL)
    
    /* ---------------------------- */
    /* init */
    init() {
        
        
    }
    
    /* ---------------------------- */
    /* connect client to server */
    func connect(server:String, buff:Connection) -> (status: Bool, message: String) {
        
        //set values
        buffer = buff
        server_name = server
        
        //connect async
        dispatch_async(dispatch_get_main_queue()) {
            
            //connect
            self.socket.delegate = self
            //self.socket.selfSignedSSL = true
            self.socket.connect()
            
            // send echo U+0022
            var text:String = "{\u{22}username\u{22}:\u{22}\(self.server_name)\u{22},\u{22}message\u{22}:\u{22}Welcome @all from \(self.server_name)\u{22}}"
            self.socket.writeString(text)
        }
        
        //set state
        state = "connect to websocket: '\(ws_sock_server_ip):\(ws_sock_server_port)'"
        connected = true
        return (connected,state)
    }
    
    /* ---------------------------- */
    /* get current ws state */
    func getState() -> (newMessage:Bool, state:Bool, text:String) {
        
        //check for new message / state
        var tmp:Bool = false
        if state != lastState {
            tmp = true
            lastState = state
        }
        
        return (tmp,connected,state)
    }
    
    /* ---------------------------- */
    /* send message */
    func sendMessage(msg:message) -> (status: Bool, message: String) {
       
        //build string
        var text:String = "{\u{22}username\u{22}:\u{22}\(msg.name)\u{22},\u{22}message\u{22}:\u{22}\(msg.message)\u{22}}"
        
        //send async
        dispatch_async(dispatch_get_main_queue()) {
            self.socket.writeString(text)
        }
        
        return(connected,state)
    }
    
    /* ---------------------------- */
    /* disconnect from server */
    func disconnect() -> (status: Bool, message: String) {
        
        //disconnect async
        dispatch_async(dispatch_get_main_queue()) {

            // send echo U+0022
            var text:String = "{\u{22}username\u{22}:\u{22}\(self.server_name)\u{22},\u{22}message\u{22}:\u{22}welcome from \(self.server_name)\u{22}}"
            
            self.socket.writeString(text)
        
            //disconnect
            self.socket.disconnect()
        
        }
        
        //set state
        state = "websocket is disconnected"
        connected = false
        return(true,state)
    }

    /* ---------------------------- */
    /* delegate methods */
    /* if connected */
    func websocketDidConnect() {
        state = "websocket did connect"
        connected = true
    }
    
    /* ---------------------------- */
    /* if disconnected */
    func websocketDidDisconnect(error: NSError?) {
        if let e = error {
            state = "websocket did disconnect -> \(e.localizedDescription)"
            connected = false
        }
    }
    
    /* ---------------------------- */
    /* ws has errors */
    func websocketDidWriteError(error: NSError?) {
        
        //if error
        if let e = error {
            state = "websocket get error from server \(e.localizedDescription)"
            connected = false
        }
    }
    
    /* ---------------------------- */
    /* receive message */
    func websocketDidReceiveMessage(text: String) {
        //split text
        var Array = text.componentsSeparatedByString("\u{22}")
        
        // ad message to buffer
        buffer.receiveBuffer.enqueue(message(ip: ws_sock_server_ip, port: ws_sock_server_port, message: "\(Array[3]): \(Array[7])",  name: "webchat", type: msg_type.MESSAGE.rawValue))
        //println("Received text: \(text)")
    }
    
    /* ---------------------------- */
    /* receive data */
    func websocketDidReceiveData(data: NSData) {
        //println("Received data: \(data.length)")
    }


    
    
}