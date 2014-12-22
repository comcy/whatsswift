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
struct s_client {
    
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
    var db : Array<s_client> = Array<s_client>()
    
    //init
    init() {
        //clear all
        db.removeAll(keepCapacity: true)
    }
    
    //get client count
    func get_client_count() -> (Int) {
        return db.count
    }
    
    //inc. error for client
    func set_error_for(_name: String) -> (status: Bool, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (false,"client '\(_name)' not exists")
        }
        
        //set error
        for (index, value) in enumerate(db) {
            if value.name == _name {
                db[index].error += 1
                return (true,"set error for '\(_name)' to '\(db[index].error)'")
            }
        }
        return (false,"error not set for '\(_name)'")
        
    }
    
    //rcv sign of life from
    func rcv_sign_of_life_from(_name: String) -> (status: Bool, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (false,"client '\(_name)' not exists")
        }
        
        //set error to zero
        for (index, value) in enumerate(db) {
            if value.name == _name {
                db[index].error = 0
                return (true,"set error from '\(_name)' to 0")
            }
        }
        return (false,"sign of life not set for '\(_name)'")
        
    }
    
    //get client list
    func get_client_list() -> (Array<s_client>) {
        return db
    }
    
    //add client to list.
    func add_client(_ip: String, _port: Int, _name: String, _type: String) -> (status: Bool, message: String) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members != 0 {
            return (false,"client '\(_name)' already exists")
        }
        
        //generate tmp client struct
        id += 1
        var tmp_client = s_client(id: id,ip: _ip, port: _port, name: _name, type: _type, time: timestamp, error: 0)
        
        //add client to db
        if db.count < max_clients {
            db.append(tmp_client)
            return (true,"client '\(_name)' with id '\(id)' successfully connected")
        }
        else {
            return (false,"max. number of clients reached")
        }
        
    }
    
    //rem client from list
    func rem_client(_ip: String, _port: Int, _name: String) -> (status: Bool, message: String) {
        
        //check if exists
        var members = db.filter{$0.name == _name}.count
        if  members == 0 {
            return (false,"client '\(_name)' not exists")
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
            return (false,"client '\(_name)' not disconnected")
        }
        else {
            return (true,"client '\(_name)' successfully disconnected")
        }
    }
    
}
