//
//  connection.swift
//  WhatsSWIFT_Connection
//
//  Created by compilerlabor on 21/12/14.
//  Copyright (c) 2014 comcy. All rights reserved.
//

import Foundation

//
// Struct: Message
//  ( messaging protocol )
//  * ip: ip addres of destination
//  * port: port of destination
//  * message: message itself
//  * name: name of desination
//  * type: type of message
//

/*struct message {
    var ip:String = ""
    var port:Int = 0
    var message:String = ""
    var name:String = ""
    var type:Int = 2 // echo
}*/

//
// Class: Connection
//  ( represents a connection object for client and server )
//  * var serverPort: port for server connection [55155]
//  * var clientPort: port for client connection [55255]
//
//  * NSSocket: connection socket for client and server
//  * ...
//
//  * func receiveMsg() -> message: function for receiving messages from [SRC]
//  * func sendMsg(): function to send messages to destination [DEST]
//
//  * clientReceiveMessageBuffer: array to buffer incoming client messages - added in sendMsg()
//  * serverReceiveMessageBuffer: array to buffer incoming server messages - added in sendMsg()
//  * clientSendMessageBuffer: array to buffer outgoing client messages - added in receiveMsg()
//  * serverSendMessageBuffer: array to buffer outgoing server messages - added in receiveMsg()
//  * clientConnectMessageBuffer: aray
//  * clientDisconnectMessageBuffer: array
//  * serverDisconnectMessageBuffer: array
//  * clientEchoMessageBuffer: array
//  * serverEchoMessageBuffer: array
//

class Connection{
    
    let serverPort = 55155
    let clientPort = 55255
    
    var clientSendMessageBuffer: Array<message> = Array<message>()
    var clientReceiveMessageBuffer: Array<message> = Array<message>()
    var clientEchoMessageBuffer: Array<message> = Array<message>()
    var clientConnectMessageBuffer: Array<message> = Array<message>()
    var clientDisconnectMessageBuffer: Array<message> = Array<message>()
    
    var serverSendMessageBuffer: Array<message> = Array<message>()
    var serverReceiveMessageBuffer: Array<message> = Array<message>()
    var serverDisconnectMessageBuffer: Array<message> = Array<message>()
    var serverEchoMessageBuffer: Array<message> = Array<message>()
    
    //DUMP
    var dumpMessageBuffer: Array<message> = Array<message>()
    
    // receiveMsg()
    func receiveClientMsg(type:Int) -> Array<message> {
        
        //  * fill array with requested type and return it
        
        return dumpMessageBuffer
    }
    
    func sendClientMsg(message) {
        
        //  * parsing on message-type
        //  * parsing on client/server
        //  * fill buffer-arrays
        
    }
    
    // receiveMsg()
    func receiveServerMsg(type:Int) -> Array<message> {
        
        //  * fill array with requested type and return it
        
        return dumpMessageBuffer
    }
    
    func sendServerMsg(message) {
        
        //  * parsing on message-type
        //  * parsing on client/server
        //  * fill buffer-arrays
        
    }
    
    
    
    func getClientReceiveMessageBufferCount() -> Int{
        return clientReceiveMessageBuffer.count
    }
    
    func getServerReceiveMessageBufferCount() -> Int{
        return serverReceiveMessageBuffer.count
    }
}