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


*/

/* import */
import Foundation
import StarscreamOSX

class ws_connect: WebSocketDelegate {
    
    //socket
    //var socket = WebSocket(url: NSURL(scheme: "ws", host: ws_sock_server_1, path: "/")!, protocols: ["chat", "superchat"])
    var socket = WebSocket(url: NSURL(scheme: "ws", host: ws_sock_server_1, path: "/")!)
    
    //state
    var connected:Bool = false
    
    //error
    var error_text:String = ""
    
    //init
    init() {
        
        
    }
    
    //connect client to server
    func connect() -> (status: Bool, message: String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            //connect
            self.socket.delegate = self
            self.socket.connect()
            
            // send echo
            self.socket.writeString("hello there!")
        }
        
        //state
        if connected {
            return (true,"websocket is connected")
        }
        else {
            return (false,"websocket is disconnected \(error_text)")
        }

        
    }
    
    //disconnect from server
    func disconnect() -> (status: Bool, message: String) {
        
        //disconnect
        if connected {
            socket.disconnect()
        }
        
        return(true,"websocket is disconnected")
    }

    //websocket delegate methods.
    //if connected
    func websocketDidConnect() {
        connected = true
    }
    
    //if disconnected
    func websocketDidDisconnect(error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
            error_text = "-> \(e.localizedDescription)"
            connected = false
        }
    }
    
    //if has error
    func websocketDidWriteError(error: NSError?) {
        if let e = error {
            println("wez got an error from the websocket: \(e.localizedDescription)")
        }
    }
    
    //get message
    func websocketDidReceiveMessage(text: String) {
        println("Received text: \(text)")
    }
    
    //get data
    func websocketDidReceiveData(data: NSData) {
        println("Received data: \(data.length)")
    }

    // MARK: Write Text Action
    
    /* @IBAction func writeText(sender: UIBarButtonItem) {
    socket.writeString("hello there!")
    }
    
    // MARK: Disconnect Action
    
    @IBAction func disconnect(sender: UIBarButtonItem) {
    if socket.isConnected {
    sender.title = "Connect"
    socket.disconnect()
    } else {
    sender.title = "Disconnect"
    socket.connect()
    }
    }*/

    
    
}