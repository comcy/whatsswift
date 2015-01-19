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
class Connection{
    
    // receiver always listening on "localhost|127.0.0.1" an Port 666
   // var receiver:TCPServer = TCPServer( addr: "127.0.0.1", port: 666 )
    
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
    
    
    // func: sendMessage( msg:message )
    //
    // This function is called by a client to send a message to the server.
    // A message object as paramter is needed.
    //
    func sendMessage( msg:message ) {
        
        var firstMsg:message!
        
        // add incoming messages to buffer
        sendBuffer.enqueue( msg )
        
        while( !sendBuffer.isEmpty() ){
            // remove first element (FIFO)
            firstMsg = sendBuffer.dequeue()
            
            // DEBUGGING
            println( firstMsg.ip )
            println( firstMsg.port )
            println( firstMsg.message )
            println( firstMsg.name )
            println( firstMsg.type )
            
            
            // extract ip and port for server
            var ip:String = firstMsg.ip
            var port:Int = firstMsg.port
            
            // build message string
            var message:String = buildString(firstMsg)
            
            // send server over network
            sendMsg( destIp:ip, destPort:port, msg:message )
            
        }
        
    }
    
    
    // func: receiveMessage( ) -> message
    //
    // A function which is called by a instance to
    // receive all message sent by clients during a period
    // of time.
    // It returns a message object.
    //
    func receiveMessage( ) -> message {
        
        while( !receiveBuffer.isEmpty() ){
            
            let msg:message! = receiveBuffer.dequeue()
            
            return msg
        }
        
        // DEBUGGING ---> NIL o.ä. zurück geben
        var msg:message = message(ip: "localhostiii", port: 12, message: "asd asd", name: "asd asd", type: 1)
        return msg
        
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Connection functions
    ///////////////////////////////////////////////////////////////////////////////////////
    
    
    // func: buildString( msg: message )
    //
    // This function is a helper function to build a string
    // out of an message object.
    // It returns a string which contains the built message and 
    // awaits a message object.
    //
    func buildString( msg:message ) -> String {
        
        var ip = msg.ip + del
        var port = String(msg.port) + del // convert to string
        var message = msg.message + del
        var name = msg.name + del
        var type = String(msg.type) // convert to string
        
        var rValue:String = ip + port + message + name + type
        
        return rValue
        
    }
    
    
    // func: splitString( msg:String )
    //
    // This function splits a complete string which contains message information
    // to build a message object.
    // It returns a message object.
    //
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
    
    
    // func: sendMsg( destIp:addr, destPort:port, msg:str )
    //
    // Function which sends a Message/String to a receiver instance.
    // The Function needs a destination IP address an a destination port.
    // The transmission of the String is realized as an TCP socket.
    //
    func sendMsg( #destIp:String, destPort:Int, msg:String  ){
        
        // new tcp socket on client
        var sender:UDPClient = UDPClient( addr: destIp, port: destPort )
        sender.send(str: msg);
        sender.close()
                
    }
    
    // func: receiveMsg()
    //
    // TODO -> Threading für ständige Prüfung, ob etwas da is
    func receiveMsg(){
   
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            var server:UDPServer=UDPServer(addr:self.getIFAddresses()[2],port:5252)
            var run:Bool=true
            while run{
                var (data,remoteip,remoteport)=server.recv(1024)
                println("recive")
                if let d=data{
                    if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                        println(str)
                        var msg:message = self.splitString(str)
                        self.receiveBuffer.enqueue(msg)
                    }
                }
                println(remoteip)
                server.close()
                break
            }
        })
    }
    
    
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
}




