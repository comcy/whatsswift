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
    
    /* ---------------------------- */
    // Message delimiter
    let del:String = ">|<"
    
    /* ---------------------------- */
    // FIFO Queue
    let receiveBuffer = Queue<message>()
    let sendBuffer = Queue<message>()
    var allow_udp:Bool = false
    
    init() {
        
        
    }
    
    func connect() -> (status: Bool, message: String) {
        
        allow_udp = true
        return (true,"connect to udp socket: '\(getIFAddresses()[2]):\(udp_sock_port_s)'")
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
    /* get server ip */
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
    func splitString( msgStr:String, ip:String, port:Int ) -> message {
        
        // separation array
        var sepArr = msgStr.componentsSeparatedByString( del )
        
        var ipSplit:String = ip
        var portSplit:Int! = udp_sock_port_c
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
        
        var client:UDPClient=UDPClient(addr: destIp, port: destPort)
        //println("send \(msg)")
        client.send(str: msg)
        client.close()
    }

    /* ---------------------------- */
    /* receive message - thread */
    func receiveMsg() {
        
        if allow_udp {
        //check for new message
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            var server:UDPServer=UDPServer(addr:self.getIFAddresses()[2],port:udp_sock_port_s)
            var run:Bool=true
            while run{
                var (data,remoteip,remoteport)=server.recv(1024)
                //println("recive")
                if let d=data{
                    if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                        //println(str)
                        
                        // parse message
                        var msg:message = self.splitString( str, ip: remoteip, port: remoteport )
                        
                        // ad message to a buffer
                        self.receiveBuffer.enqueue( msg )
                        
                    }
                }
                //println(remoteip)
                server.close()
                break
            }
        })
        }

    }
}


