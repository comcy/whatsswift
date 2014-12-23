//
//  Helpers.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 15.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*




*/

/* import */
import Foundation
import Cocoa

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

/* colorize text */
func colorizeText(ressource: String) -> NSMutableAttributedString {
    var theRessource = ressource
    var attributedString = NSMutableAttributedString(string: theRessource)
    let aColor = NSColor.redColor()
    let aRange = NSMakeRange(0, 2)
    attributedString.addAttribute(NSForegroundColorAttributeName, value:aColor, range:aRange)
    return attributedString
}

/* colorize text 2 */
func attributeString(ressource: String) -> NSMutableAttributedString{
    var attributedRessource = NSMutableAttributedString(string: ressource)
    let theCompleteRange = NSMakeRange(0, countElements(ressource))
    let theFont = NSFont(name: "Menlo Bold", size: 11)
    let theColor = NSColor.whiteColor()
    
    // style
    attributedRessource.addAttribute(NSFontAttributeName, value: theFont!, range: theCompleteRange)
    
    // text color
    attributedRessource.addAttribute(NSForegroundColorAttributeName, value: theColor, range: theCompleteRange)
    
    // background color
    attributedRessource.addAttribute(NSBackgroundColorAttributeName, value: NSColor.redColor(), range: NSMakeRange(10,20))
    return attributedRessource
}

/* add some fake clients */
func addFakeClients(db: client_list) {
    
    db.add_client("192.168.2.222", _port: 12587, _name: "Hannes", _type: "osx_client")
    db.add_client("192.168.2.221", _port: 12587, _name: "Lisa", _type: "osx_client")
    db.add_client("192.168.2.233", _port: 12587, _name: "Mike", _type: "osx_client")
    db.add_client("192.168.2.232", _port: 12587, _name: "Jan", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "Hannes", _type: "osx_client")
    db.add_client("192.168.2.239", _port: 12587, _name: "Lukas", _type: "osx_client")
    
}

/* append extension */
extension NSTextView {
    func appendString(string:String) {
        self.string! += string
        self.scrollRangeToVisible(NSRange(location:countElements(self.string!), length: 0))
    }
}

/* msg */
struct message {
    
    var ip:String = ""
    var message:String = ""
    var name:String = ""
    var port:Int = 0
    var type:Int = 0
    
}

/* enum msg type */
enum msg_type: Int {
    case CONNECT = 0, DISCONNECT = 1, ECHO = 2, MESSAGE = 3
}

/* enum server stat */
enum server_state: Int {
    case OFFLINE = 0, ONLINE = 1, ERROR = -1
}

/* add some fake connection */
class connection_debug {
    
    func sendMessage(message) -> (Boolean) {
        return 1
    }
    
    //get random fake message
    func receiveMessage() -> (status: Bool,msg: message) {
        
        var tmp:Array<message> = Array<message>()
        tmp.append(message(ip: "192.168.2.222", message: "44rtggf", name: "Hannes", port: 12587, type: 1))
        tmp.append(message(ip: "192.168.2.222", message: "rzzzr", name: "Lisa", port: 12587, type: 3))
        tmp.append(message(ip: "192.168.2.222", message: "fgrgrg", name: "Mike", port: 12587, type: 3))
        tmp.append(message(ip: "192.168.2.222", message: "rzgr", name: "Hannes", port: 12587, type: 0))
        tmp.append(message(ip: "192.168.2.222", message: "dfgfff", name: "Hannes", port: 12587, type: 3))
        tmp.append(message(ip: "192.168.2.222", message: "dfgfff", name: "Lukas", port: 12587, type: 2))
        tmp.append(message(ip: "192.168.2.222", message: "dfgfff", name: "Hannes", port: 12587, type: 2))
        
        var diceRoll = Int(arc4random_uniform(7))
        
        //return (0,tmp[0])
        return (true,tmp[diceRoll])
    }
    

}

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





