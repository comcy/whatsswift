//
//  connection.swift
//  WhatsSWIFT_Connection
//
//  Created by comcy on 21/12/14.
//  Copyright (c) 2014 comcy. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

//
// Struct: Message
//  ( messaging protocol )
//  * ip: ip addres of destination
//  * port: port of destination
//  * message: message itself
//  * name: name of desination
//  * type: type of message
// https://github.com/xyyc/SwiftSocket/blob/master/SwiftSocket/main.swift
//
struct message {
    var ip:String = ""
    var port:Int = 0
    var message:String = ""
    var name:String = ""
    var type:Int = 2 // echo
}


// Class: Connection
//  ( represents a connection object for client and server )
//  * var serverPort: port for server connection [666]
//  * var clientPort: port for client connection [667]
//
//  * func sendMessage( ) -> message: function for receiving messages from [SRC]
//  * func receiveMessage( message ): function to send messages to destination [DEST]
//
//  * func receiveServerMsg( type:Int ) -> message: function for receiving messages from [SRC]
//  * func sendServerMsg( message ): function to send messages to destination [DEST]
//
//  * sendBuffer: array to buffer outgoing client messages - add in receiveMsg()
//  * receiveBuffer: array to buffer incoming client messages - add in sendMsg()
//
/* ---------------------------- */
/* Connection */
class Connection{
    
    // Message delimiter
    let del:String = ">|<"
    
    // FIFO Queue - for every instance its own
    let receiveBuffer = Queue<message>()
    let sendBuffer = Queue<message>()
    
    init() {
        
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Client/Server (communication) functions
    ///////////////////////////////////////////////////////////////////////////////////////
    
    /* ---------------------------- */
    /* send message */
    // This function is called by a client to send a message to the server.
    // A message object as paramter is needed.
    func sendMessage( msg:message ) {
        
        var firstMsg:message!
        
        // add incoming messages to buffer
        sendBuffer.enqueue( msg )
        
        //send all messages
        while( !sendBuffer.isEmpty() ){
            
            // remove first element (FIFO)
            firstMsg = sendBuffer.dequeue()
            
            // extract ip and port for server
            var ip:String = firstMsg.ip
            var port:Int = firstMsg.port
            
            // build message string
            var message:String = buildString(firstMsg)
            
            // send server over network
            sendMsg( destIp:ip, destPort:port, msg:message )
        }
        
    }
    
    
    /* ---------------------------- */
    /* receive message */
    func receiveMessage( ) -> (status: Bool,msg: message) {
        
        if( !receiveBuffer.isEmpty() ){
            
            let msg:message! = receiveBuffer.dequeue()
            
            return (true,msg)
        }
        else
        {
            var msg:message = message(ip: "xx", port: 00, message: "xx", name: "xx", type: 0)
            return (false,msg)
        }
        
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Connection functions
    ///////////////////////////////////////////////////////////////////////////////////////
    
    /* ---------------------------- */
    /* build string */
    // This function is a helper function to build a string
    // out of an message object.
    // It returns a string which contains the built message and 
    // awaits a message object.
    func buildString( msg:message ) -> String {
        
        var ip = msg.ip + del
        var port = String(msg.port) + del // convert to string
        var message = msg.message + del
        var name = msg.name + del
        var type = String(msg.type) // convert to string
        
        var rValue:String = ip + port + message + name + type
        
        return rValue
        
    }
    
    
    /* ---------------------------- */
    /* split string */
    // This function splits a complete string which contains message information
    // to build a message object.
    // It returns a message object.
    func splitString( msgStr:String ) -> message {
        
        // separation array
        var sepArr = msgStr.componentsSeparatedByString( del )
        
        var ipSplit:String = sepArr[0]
        var portSplit:Int! = sepArr[1].toInt()
        var textSplit:String = sepArr[2]
        var nameSplit:String = sepArr[3]
        var typeSplit:Int! = sepArr[4].toInt()
        
        // build a message object out of the splitted string
        var msg:message = message(ip: ipSplit , port: portSplit!, message: textSplit, name: nameSplit, type: typeSplit!)

        return msg
    }
    
    
    /* ---------------------------- */
    /* send message */
    // Function which sends a Message/String to a receiver instance.
    // The Function needs a destination IP address an a destination port.
    // The transmission of the String is realized as an TCP socket.
    func sendMsg( #destIp:String, destPort:Int, msg:String  ){
        
        // new tcp socket on client
        /*var sender:TCPClient = TCPClient( addr: destIp, port: destPort )
        
        // connection to server with 2 minutes timeout
        var ( success, errmsg )=sender.connect( timeout: 120 )
        if success{
            
            // send message to server
            var ( success, errmsg ) = sender.send( str: msg )
            if success{
                
                // read string/answer
                var data = sender.read( 1024*10 )
                if let d = data{ // print received string on console
                    if let rcvMsg = String( bytes: d, encoding: NSUTF8StringEncoding ) {
                        println( rcvMsg )
                    }
                }
            } else{
                println( errmsg )
            }
        } else{
            println( errmsg )
        }*/
        
    }
    
    /* ---------------------------- */
    /* receive message - thread */
    func receiveMsg() {
        
        //check for new message
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            var server:UDPServer=UDPServer(addr:"127.0.0.1",port:8080)
            var run:Bool=true
            while run{
                var (data,remoteip,remoteport)=server.recv(1024)
                println("recive")
                if let d=data{
                    if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                        println(str)
                    }
                }
                println(remoteip)
                server.close()
                break
            }
        })

        
        // parse message
        var msg:message = splitString( rcvMsg )
        
        // ad message to a buffer
        receiveBuffer.enqueue( msg )
    }
}


