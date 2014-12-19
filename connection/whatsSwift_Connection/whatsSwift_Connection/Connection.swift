//
//  main.swift
//  whatsSwift_Connection
//
//  Created by Silfang, Christian on 15.12.14.
//  Copyright (c) 2014 Silfang, Christian. All rights reserved.
//

import Foundation

/* Socket Definition */
let addr = "127.0.0.1"
let clientPort = 11511
let serverPort = 11411

var host :NSHost = NSHost(address: addr)
var inp :NSInputStream?
var out :NSOutputStream?

NSStream.getStreamsToHost(host, port: port, inputStream: &inp, outputStream: &out)

let inputStream = inp!
let outputStream = out!

inputStream.open()
outputStream.open()

var readByte :UInt8 = 0
while inputStream.hasBytesAvailable {
    inputStream.read(&readByte, maxLength: 1)
}

// buffer is a UInt8 array containing bytes of the string "Jonathan Yaniv.".
outputStream.write(&buffer, maxLength: buffer.count)


/* Message */
struct s_message {
    var ip:String = ""
    var port:int = 25252
    var message:String = ""
    var name:String = ""
    var type:Int = 0
}

/* Connection-Klasse */
class Connection{
    
    // messageBuffer-Array zum Buffern von Messages
    var messageBuffer: Array<s_message> = Array<s_message>()
    
    func receiveMessage() -> s_message {
        
        
        
        
        return nil
    }
    
    func sendMessage(s_message.ip, s_message.port, s_message.message, s_message.name, s_message.type) {
        
        var tmpBuffer = s_message(message)
        messageBuffer.append(tmpBuffer)
        
        
    }
    
    /* Hilfsfunktionen */
    
    /* COUNT messageBuffer*/
    func getMessageBufferCount() -> int{
        return messageBuffer.count
    }
}