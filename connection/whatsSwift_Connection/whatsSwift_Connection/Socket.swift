//
//  Socket.swift
//  whatsSwift_Connection
//
//  Created by Silfang, Christian on 19.12.14.
//  Copyright (c) 2014 comcy. All rights reserved.
//

import Foundation

class Socket{
    
// STACKOVERFLOW example
    
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
    
}