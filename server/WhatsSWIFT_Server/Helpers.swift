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
        var msg = message(ip: "192.168.2.222", message: "du held", name: "Hannes", port: 12587, type: 0)
        
        return (1,msg)
    }
    

}





