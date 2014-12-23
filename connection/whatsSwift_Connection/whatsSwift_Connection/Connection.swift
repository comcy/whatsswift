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
//

struct message {
    var ip:String
    var port:String
    var message:String
    var name:String
    var type:String
}

//
// Class: Connection
//  ( represents a connection object for client and server )
//  * var serverPort: port for server connection [55155]
//  * var clientPort: port for client connection [55255]
//
//  * NSSocket: connection socket for client/server
//  * ...
//
//  * func receiveClientMsg( type:Int ) -> message: function for receiving messages from [SRC]
//  * func sendClientMsg( message ): function to send messages to destination [DEST]
//
//  * func receiveServerMsg( type:Int ) -> message: function for receiving messages from [SRC]
//  * func sendServerMsg( message ): function to send messages to destination [DEST]
//
//  * clientReceiveMessageBuffer: array to buffer incoming client messages - add in sendMsg()
//  * clientSendMessageBuffer: array to buffer outgoing client messages - add in receiveMsg()
//  * clientConnectMessageBuffer: array to buffer connection messages from clients - add in sendMsg()
//  * clientDisconnectMessageBuffer: array to buffer disconnection messages from clients - add in sendMsg()
//  * clientEchoMessageBuffer: array to buffer echoes from clients - add in sendMsg()
//
//  * serverReceiveMessageBuffer: array to buffer incoming server messages - add in sendMsg()
//  * serverSendMessageBuffer: array to buffer outgoing server messages - add in receiveMsg()
//
//  * getClientMessageCount( type:Int ): returns the count of messageBuffers from clients for a given type
//  * getServerMessageCount( type:Int ): returns the count of messageBuffers from server for a given type
//

class Connection{
    
    // public server/client ports
    let serverPort = 55155
    let clientPort = 55255
    
    
    // message delimiter
    let del:String = ">|<"
    
    init() {
        
    }
    
    
    // buffer arrays
    var clientSendMessageBuffer: Array<message> = Array<message>()
    var clientReceiveMessageBuffer: Array<message> = Array<message>()
    var clientEchoMessageBuffer: Array<message> = Array<message>()
    var clientConnectMessageBuffer: Array<message> = Array<message>()
    var clientDisconnectMessageBuffer: Array<message> = Array<message>()
    
    var serverSendMessageBuffer: Array<message> = Array<message>()
    var serverReceiveMessageBuffer: Array<message> = Array<message>()
    var serverDisconnectMessageBuffer: Array<message> = Array<message>()
    var serverEchoMessageBuffer: Array<message> = Array<message>()
    
    var dumpMessageBuffer: Array<message> = Array<message>()
    
    
    // socket implementation
    var input: NSInputStream?
    var output: NSOutputStream?
    
    // func: receiveClientMsg( type:Int )
    // call: client | param: type:Int | return: clientMessageBuffers
    func receiveClientMsg( type:Int ) -> Array<message> {
        
        return dumpMessageBuffer
    }
    
    // func: sendClientMsg( msg:message )
    // call: client | param: msg:message | return: void
    func sendClientMsg( msg: message ) {
        
        var address:String = msg.ip
        var port = msg.port.toInt()
        
        NSStream.getStreamsToHostWithName(address, port: port!, inputStream: &input, outputStream: &output)
        
        let inputStream = input!
        let outputStream = output!
        
        inputStream.open()
        
        var readByte:UInt8 = 255
        while inputStream.hasBytesAvailable {
            inputStream.read(&readByte, maxLength: 10)
        }
        
        
        var message:String = buildString(msg)
        println(message)
        // TODO -> in receiveServerBuffer schieben
        
    }
    
    // func: receiveServerMsg( type:Int )
    // call: server | param: type:Int | return: serverMessageBuffers
    func receiveServerMsg( type:Int ) -> Array<message> {
        
        return dumpMessageBuffer
    }
    
    // func: sendClientMsg( msg:message )
    // call: server | param: mag:message |return: void
    func sendServerMsg( msg:message ) {
        
        var message:String = buildString(msg)
        println(message)
        // TODO -> in receiveServerBuffer schieben
        
    }
    
    // func: getClientMessageCount( type:Int )
    // call: server | param: type:Int | return: Int
    func getClientMessageCount( type:Int ) -> Int{
        return clientReceiveMessageBuffer.count
    }
    
    // func: getServerMessageCount( type:Int )
    // call: client | param: type:Int | return: Int
    func getServerMessageCount( type:Int ) -> Int{
        return clientReceiveMessageBuffer.count
    }
    
    // func: buildString( msg: message )
    // call: conection | param: msg:message | return: String
    func buildString( msg:message ) -> String {
        
        var ip = msg.ip
        var port = msg.port
        var message = msg.message
        var name = msg.name
        var type = msg.type
        
        return ip + del + port + del + message + del + name + del + type
        
    }
    
    // TODO
    func splitString( msg:String ){
        
        // separation array
        var sepArr = msg.componentsSeparatedByString( del )
        
        var ip:String = sepArr[0]
        var port:String = sepArr[1]
        var message:String = sepArr[2]
        var name:String = sepArr[3]
        var type:String = sepArr[4]
        
        for i in sepArr {
            println(i);
        }
    }
}