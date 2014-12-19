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

/* add some fake clients */
func addFakeClients(db: client_list) {
    
    db.add_client("192.168.2.222", _port: 12587, _name: "Hannes", _type: "osx_client")
    db.add_client("192.168.2.221", _port: 12587, _name: "Lisa", _type: "osx_client")
    db.add_client("192.168.2.233", _port: 12587, _name: "Mike", _type: "osx_client")
    db.add_client("192.168.2.232", _port: 12587, _name: "Jan", _type: "osx_client")
    db.add_client("192.168.2.235", _port: 12587, _name: "Hannes", _type: "osx_client")
    
    
}

/* msg */
struct message {
    
    var ip:String = ""
    var message:String = ""
    var name:String = ""
    var port:Int = 0
    var type:Int = 0
    
}

/* add some fake connection */
class connection_debug {
    
    func sendMessage(message) -> (Boolean) {
        return 1
    }
    
    func receiveMessage() -> (status: Boolean,msg: message) {
        var tmp:Array<message> = Array<message>()
        tmp.append(message(ip: "192.168.2.222", message: "44rtggf", name: "Hannes", port: 12587, type: 0))
        tmp.append(message(ip: "192.168.2.222", message: "rzzzr", name: "Lisa", port: 12587, type: 0))
        tmp.append(message(ip: "192.168.2.222", message: "fgrgrg", name: "Mike", port: 12587, type: 0))
        tmp.append(message(ip: "192.168.2.222", message: "rzgr", name: "Hannes", port: 12587, type: 0))
        tmp.append(message(ip: "192.168.2.222", message: "dfgfff", name: "Hannes", port: 12587, type: 0))
        
        var diceRoll = Int(arc4random_uniform(5))
        
        return (1,tmp[diceRoll])
    }
    

}





