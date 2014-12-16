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

/* client */
struct client {
    
    var id:Int = 0
    var ip:String = ""
    var port:Int = 0
    var name:String = ""
    var type:String = ""
    var time:String = ""
    var error:Int = 0
}

/* clientslist */
class client_list {
    
    //vars
    var id:Int = 0
    
    //client db
    var db : Array<client> = Array<client>()
    
    //get client count
    func get_client_count() -> (Int) {
        return db.count
    }
    
    //inc. error for client
    func set_error_for(_name: String) -> (status: Boolean, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (0,"client \(_name) not exists")
        }
        
        //set error to zero
        //remove from list
        for (index, value) in enumerate(db) {
            if value.name == _name {
                db[index].error += 1
                return (1,"set error for \(_name) to \(db[index].error)")
            }
        }
        return (0,"error not set for \(_name)")
        
    }
    
    //rcv sign of life from
    func rcv_sign_of_life_from(_name: String) -> (status: Boolean, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (0,"client \(_name) not exists")
        }
        
        //set error to zero
        //remove from list
        for (index, value) in enumerate(db) {
            if value.name == _name {
                db[index].error = 0
                return (1,"set sign of life from \(_name) to 0")
            }
        }
        return (0,"sign of life not set for \(_name)")
        
    }
    
    //get client list
    func get_client_list() -> (Array<client>) {
        return db
    }
    
    //add client to list.
    func add_client(_ip: String, _port: Int, _name: String, _type: String) -> (status: Boolean, message: String) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members != 0 {
            return (0,"client \(_name) already exists")
        }
        
        //generate tmp client struct
        id += 1
        var tmp_client = client(id: id,ip: _ip, port: _port, name: _name, type: _type, time: timestamp, error: 0)
        
        //add client to db
        if db.count < max_clients {
            db.append(tmp_client)
            return (1,"client \(_name) with id \(id) successfully added")
        }
        else {
            return (0,"max. number of clients reached")
        }
        
    }
    
    //rem client from list
    func rem_client(_ip: String, _port: Int, _name: String) -> (status: Boolean, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (0,"client \(_name) not exists")
        }
        
        //remove from list
        for (index, value) in enumerate(db) {
            if value.name == _name {
                var remove = db.removeAtIndex(index)
            }
        }
        
        
        //check if exists
        members = db.filter{$0.name == _name}.count
        if  members != 0 {
            return (0,"client \(_name) not removed")
        }
        else {
            return (1,"client \(_name) successfully removed")
        }
    }
    
}
