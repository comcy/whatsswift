//
//  Messages.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 15.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
//
//  Clients.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 15.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*




*/

/* import */
import Foundation

/* message */
struct s_message {
    
    var id:UInt64 = 0
    var name:String = ""
    var message:String = ""
    var time:String = ""
}

/* messagelist */
class message_list {
    
    //vars
    var id:UInt64 = 0
    
    //message db
    var db : Array<s_message> = Array<s_message>()
    
    //init
    init() {
        //clear all
        db.removeAll(keepCapacity: true)
    }
    
    //get message count
    func get_message_count() -> (Int) {
        return db.count
    }
    
    //add message to list
    func add_message( _name: String, _message: String) -> (status: Bool, message: String) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //generate tmp message struct
        id += 1
        var tmp_message = s_message(id: id,name: _name, message: _message, time: timestamp)
        
        //add message to db
        db.append(tmp_message)
        return (true,"message from '\(_name)' with id '\(id)' successfully added to list")
    }
    
    //get last message
    func get_last_message() -> (s_message) {
        
        return db[db.count-1]
    }
    
}
