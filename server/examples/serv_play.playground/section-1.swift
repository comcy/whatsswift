// Playground - noun: a place where people can play

import Cocoa
import Security
import AppKit


//optional streams
var input :NSInputStream?
var output :NSOutputStream?

var had = NSHost(address: "141.18.44.62")
//connect to host
NSStream.getStreamsToHost(had, port: 54330, inputStream: nil, outputStream: &output)

//open stream
let outputStream = output!
outputStream.open()

//define data to send
let str = "Apple Swift!\n"
var writeByte = [UInt8](str.utf8)

//send data
outputStream.write(&writeByte, maxLength: 15)

//connect to host
NSStream.getStreamsToHost(had, port: 54330, inputStream: &input, outputStream: nil)

//open stream
let inputStream = input!
inputStream.open()

var readByte :UInt8 = 0

inputStream.read(&readByte, maxLength: 1) //maxLength = number of bytes to read
println(String(UnicodeScalar(readByte)))