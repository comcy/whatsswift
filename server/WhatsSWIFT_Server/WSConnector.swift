//
//  WSConnector.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 12.01.15.
//  Copyright (c) 2015 Bauer, Daniel. All rights reserved.
//
/*
https://github.com/daltoniam/starscream
https://www.websocket.org/echo.html
https://github.com/Flynsarmy/PHPWebSocket-Chat
https://github.com/james2doyle/php-socket-chat


*/

/* import */
import Foundation
import StarscreamOSX

class ws_connect: WebSocketDelegate {
    
    /* ---------------------------- */
    /* socket */
    //var socket = WebSocket(url: NSURL(scheme: "ws", host: ws_sock_server_1, path: "/")!, protocols: ["chat", "superchat"])
    var socket = WebSocket(url: NSURL(scheme: "ws", host: ws_sock_server_3, path: "/")!)
    
    /* ---------------------------- */
    /* vars */
    var connected:Bool = false
    var error_text:String = ""
    var server_name:String = ""
    var buffer:Connection = Connection()
    
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
        
        //set val
        buffer = buff
        server_name = server
        
        //connect
        dispatch_async(dispatch_get_main_queue()) {
            //connect
            self.socket.delegate = self
            //self.socket.selfSignedSSL = true
            self.socket.connect()
            
            // send echo U+0022
            var text:String = "{\u{22}username\u{22}:\u{22}\(self.server_name)\u{22},\u{22}message\u{22}:\u{22}welcome from \(self.server_name)\u{22}}"
            //println(text)
            self.socket.writeString(text)
        }
            
        return (connected,"connect to websocket: '\(ws_sock_server_3)'")
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
        
        return(true,"")
    }
    
    /* ---------------------------- */
    /* disconnect from server */
    func disconnect() -> (status: Bool, message: String) {
        
        // send echo U+0022
        var text:String = "{\u{22}username\u{22}:\u{22}\(server_name)\u{22},\u{22}message\u{22}:\u{22}welcome from \(server_name)\u{22}}"
        //println(text)
        self.socket.writeString(text)
        
        //disconnect
        socket.disconnect()
        
        return(true,"websocket is disconnected")
    }

    /* ---------------------------- */
    /* delegate methods */
    /* if connected */
    func websocketDidConnect() {
        connected = true
        println("websocket")
    }
    
    /* ---------------------------- */
    /* if disconnected */
    func websocketDidDisconnect(error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
            error_text = "-> \(e.localizedDescription)"
            connected = false
        }
    }
    
    /* ---------------------------- */
    /* has errors */
    func websocketDidWriteError(error: NSError?) {
        if let e = error {
            println("ws got an error from the websocket: \(e.localizedDescription)")
        }
    }
    
    /* ---------------------------- */
    /* receive message */
    func websocketDidReceiveMessage(text: String) {
        //split text
        var Array = text.componentsSeparatedByString("\u{22}")
        
        // ad message to a buffer
        buffer.receiveBuffer.enqueue(message(ip: ws_sock_server_3, port: 0, message: "\(Array[3]): \(Array[7])",  name: "websocket", type: msg_type.MESSAGE.rawValue))
        //println("Received text: \(text)")
    }
    
    /* ---------------------------- */
    /* receive data */
    func websocketDidReceiveData(data: NSData) {
        println("Received data: \(data.length)")
    }


    
    
}