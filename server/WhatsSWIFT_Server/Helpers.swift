//
//  Helpers.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 15.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*
Diese Datei beinhaltet Methoden die für Debug und Testzwecke verwendet wurden oder den Programmablauf nicht direkt betreffen. 
Also Hilfsmethoden.....

Um alle offenen Ports im Terminal anzuzeigen: lsof -i
*/

/* import */
import Foundation
import Cocoa
import Darwin.C

/* ---------------------------- */
/* get server ip - Objective-C Bridge needed*/
func getAddresses() -> [String] {
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
/* udp test server */
func testudpserver(){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        var server:UDPServer=UDPServer(addr:"141.18.44.66",port:8586)
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
}

/* ---------------------------- */
/* udp test client */
func testudpclient(){
    var client:UDPClient=UDPClient(addr: "141.18.44.66", port: 8586)
    //println("send hello world")
    client.send(str: "hello world")
    client.close()
}

/* ---------------------------- */
/* log to file */
func writeToFile(text: String) {
    
    //location
    let location = logfile_location.stringByExpandingTildeInPath
    
    //stream
    if var outputs = NSOutputStream(toFileAtPath: location, append:true){
        
        //open file
        outputs.open()
        
        //write
        if outputs.hasSpaceAvailable == true {
            let data: NSData = text.dataUsingEncoding(NSUTF8StringEncoding)!
            var result = outputs.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            //println("bytes written:\(result)")
        }
        
        //close file
        outputs.close()
    }
    
}

/* ---------------------------- */
/* play sound */
func playSound(name: String) {
    
    //sounds at: cd /System/Library/Sounds/
    /*  Basso.aiff	Frog.aiff	Hero.aiff	Pop.aiff	Submarine.aiff
        Blow.aiff	Funk.aiff	Morse.aiff	Purr.aiff	Tink.aiff
        Bottle.aiff	Glass.aiff	Ping.aiff	Sosumi.aiff */
    
    var mySound = NSSound(named: name)
    mySound?.volume = 1.0
    mySound?.play()
}

/* ---------------------------- */
/* colorize text */
func colorizeText(ressource: String) -> NSMutableAttributedString {
    var theRessource = ressource
    var attributedString = NSMutableAttributedString(string: theRessource)
    let aColor = NSColor.redColor()
    let aRange = NSMakeRange(0, 2)
    attributedString.addAttribute(NSForegroundColorAttributeName, value:aColor, range:aRange)
    return attributedString
}

/* ---------------------------- */
/* colorize text 2 */
func attributeString(ressource: String) -> NSMutableAttributedString{
    var attributedRessource = NSMutableAttributedString(string: ressource)
    let theCompleteRange = NSMakeRange(0, countElements(ressource))
    let theFont = NSFont(name: "Menlo Bold", size: 5)
    let theColor = NSColor.whiteColor()
    
    // style
    attributedRessource.addAttribute(NSFontAttributeName, value: theFont!, range: theCompleteRange)
    
    // text color
    attributedRessource.addAttribute(NSForegroundColorAttributeName, value: theColor, range: theCompleteRange)
    
    // background color
    attributedRessource.addAttribute(NSBackgroundColorAttributeName, value: NSColor.redColor(), range: NSMakeRange(10,20))
    return attributedRessource
}

/* ---------------------------- */
/* add some fake clients */
func addFakeClients(db: client_list) {
    
    db.add_client("192.168.2.222", _port: 12587, _name: "Hannes", _type: "osx_client")
    db.add_client("192.168.2.221", _port: 12587, _name: "Lisa", _type: "osx_client")
    db.add_client("192.168.2.233", _port: 12587, _name: "Mike", _type: "osx_client")
    db.add_client("192.168.2.232", _port: 12587, _name: "Jan", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "Hannes", _type: "osx_client")
    db.add_client("192.168.2.239", _port: 12587, _name: "Lukas", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "xcbcbb", _type: "osx_client")
    db.add_client("192.168.2.239", _port: 12587, _name: "ccccccc", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "et46gdg", _type: "osx_client")
    db.add_client("192.168.2.239", _port: 12587, _name: "46efxf", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "frgdgb", _type: "osx_client")
    db.add_client("192.168.2.239", _port: 12587, _name: "rzzuuf", _type: "osx_client")
    
}

/* ---------------------------- */
/* append extension */
extension NSTextView {
    func appendString(string:String) {
        self.string! += string
        self.scrollRangeToVisible(NSRange(location:countElements(self.string!), length: 0))
    }
}

/* ---------------------------- */
/* msg */
struct messageii {
    
    var ip:String = ""
    var message:String = ""
    var name:String = ""
    var port:Int = 0
    var type:Int = 0
    
}

/* ---------------------------- */
/* enum msg type */
enum msg_type: Int {
    case CONNECT = 0, DISCONNECT = 1, ECHO = 2, MESSAGE = 3
}

/* ---------------------------- */
/* enum server stat */
enum server_state: Int {
    case OFFLINE = 0, ONLINE = 1, ERROR = -1
}

/* ---------------------------- */
/* add some fake connection */
class connection_debug {
    
    let port = 1234
    var input :NSInputStream?
    var output :NSOutputStream?
    
    init() {
        
    }
    
    func streamSend() {
        
        NSStream.getStreamsToHostWithName("localhost", port:port, inputStream: &input, outputStream: nil)
        let inputStream = input!
        inputStream.open()
        var readByte :UInt8 = 0
        while true{
            inputStream.read(&readByte, maxLength: 1)
            println(String(UnicodeScalar(readByte)))
        }
        
    }
    
    func streamRvc() {
         
        NSStream.getStreamsToHostWithName("localhost", port:port, inputStream:nil , outputStream: &output)
        let outputStream = output!
        outputStream.open()
        
        let str = "Apple Swift!\n"
        var writeByte = [UInt8] (str.utf8)
        outputStream.write(&writeByte, maxLength: 15)
    }
    
    func sendMessage(message) -> (Boolean) {
        return 1
        
    }
    
    //get random fake message
    func receiveMessage() -> (status: Bool,msg: message) {
        
        var tmp:Array<message> = Array<message>()
        tmp.append(message(ip: "192.168.2.222", port: 12587, message: "44rtggf",  name: "Hannes", type: 1))
        
        var diceRoll = Int(arc4random_uniform(7))
        
        //return (0,tmp[0])
        return (true,tmp[diceRoll])
    }
    

}

/* ---------------------------- */
/* fake array for table view */
func getDataArray () -> NSArray{
var dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
["FirstName": "Nishant", "LastName": "Singh"],
["FirstName": "John", "LastName": "Doe"],
["FirstName": "Jane", "LastName": "Doe"],
["FirstName": "Mary", "LastName": "Jane"]];
//println(dataArray);
return dataArray;
}





