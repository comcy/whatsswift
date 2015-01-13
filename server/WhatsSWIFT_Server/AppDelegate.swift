//
//  AppDelegate.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 15.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*



*/

/* import */
import Cocoa
import AppKit
import Security
import Foundation
import StarscreamOSX

/* ---------------------------- */
/* main */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    /* ---------------------------- */
    //outlet
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var i_server_name: NSTextField!
    @IBOutlet weak var i_server_pass: NSSecureTextField!
    @IBOutlet weak var o_server_ip: NSTextField!
    @IBOutlet weak var o_curr_clients: NSTextField!
    @IBOutlet weak var o_log_info: NSTextField!
    @IBOutlet weak var o_current_msg: NSTextField!
    @IBOutlet weak var o_curr_status: NSTextField!
    @IBOutlet weak var o_status_indicator: NSProgressIndicator!
    @IBOutlet var o_log: NSTextView!
    
    /* ---------------------------- */
    /* async gcd */
    private let queue_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let queue_concur = dispatch_queue_create ("concur" , DISPATCH_QUEUE_CONCURRENT)
    private let queue_serial = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL)
    
    /* ---------------------------- */
    /* obj */
    var msg_db = message_list()
    var client_db = client_list()
    var connection = connection_debug() // -> replace with original
    var ws_connection = ws_connect()
    var ws_connection2 = ws_connect()
    
    /* ---------------------------- */
    /* vars */
    var server = server_state.OFFLINE
    var client_refresh_timer = NSTimer()
    var msg_refresh_timer = NSTimer()

    /* ---------------------------- */
    /* startup */
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        add_log("initialize server")
        
        //debug
        addFakeClients(client_db)
        
        var msg = ws_connection.connect()
        println("\(msg.message)")
        
        //var msg2 = ws_connection2.connect()
        //println("\(msg2.message)")

        //init values
        o_server_ip.stringValue = ""
        o_curr_clients.stringValue = "\(client_db.get_client_count()) / \(max_clients)"
        o_current_msg.integerValue = msg_db.get_message_count()
        o_curr_status.stringValue = "offline"
        button_start_stopp.title = "start server"
        o_log_info.stringValue = "Log (max. \(max_log_entries) entries on display)"
        tabe.usesAlternatingRowBackgroundColors = true
        
    }
    
    /* ---------------------------- */
    /* shutdowm */
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    /* ---------------------------- */
    /* send echo after timer and inc. error. if error is to high then disconnect */
    func client_refresh_cylce() {
        add_log("send echo to '\(client_db.get_client_count())' clients")
        
        //async
        dispatch_async(queue_serial) {
            
            //parse clients
            for (index, value) in enumerate(self.client_db.get_client_list()) {
                
                //check error count
                if value.error >= max_error {
                    //rem client
                    var rem = self.client_db.rem_client(value.ip,_port: value.port,_name: value.name)
                    self.add_log("\(rem.message) -> reason: not alive")
                }
                
                //inc. error
                var err = self.client_db.set_error_for(value.name)
                
                //check if exists and send echo
                if err.status {
                    //connection send echo to...
                    self.connection.sendMessage(message(ip: value.ip, message: "echo", name: value.name, port: value.port, type: msg_type.ECHO.rawValue))
                    //self.add_log("send echo to \(value.id) \(value.name) at \(value.ip) \(value.type) \(value.error)")
                }
                
            }
            
        }
    }
    
    /* ---------------------------- */
    /* send broadcast */
    func sendBroadcast(text: String, sender_name: String) {
        
        //iterate clients
        for (index, value) in enumerate(self.client_db.get_client_list()) {
            //send message
            self.connection.sendMessage(message(ip: value.ip, message: text, name: sender_name, port: value.port, type: 3))
        }
        
    }
    
    /* ---------------------------- */
    /* msg refresh cycle. check connection afer timer for new messages */
    func msg_refresh_cycle() {

        //async
        dispatch_async(queue_serial) {
        
            //check for msg
            var tmp_msg =  self.connection.receiveMessage()
            
            //if new message check type and send broadcast and add to msg_db
            if tmp_msg.status {
                
                //switch type
                switch tmp_msg.msg.type {
                    
                    case 0: /*connect*/
                        self.add_log("'\(tmp_msg.msg.name)' connecting to server")
                        
                        //add client
                        var check = self.client_db.add_client(tmp_msg.msg.ip, _port: tmp_msg.msg.port, _name: tmp_msg.msg.name, _type: "osx_client")
                        self.add_log(check.message)
                        
                        //send info to clients
                        if check.status { self.sendBroadcast("\(tmp_msg.msg.name) connected", sender_name: self.i_server_name.stringValue) }
                    break
                    case 1: /*disconnect*/
                        self.add_log("'\(tmp_msg.msg.name)' disconnecting from server")
                        
                        //rem client
                        var check = self.client_db.rem_client(tmp_msg.msg.ip, _port: tmp_msg.msg.port, _name: tmp_msg.msg.name)
                        self.add_log(check.message)
                        
                        //send info to clients
                        if check.status { self.sendBroadcast("'\(tmp_msg.msg.name)' disconnected", sender_name: self.i_server_name.stringValue) }
                    break
                    case 2: /*echo*/

                        //set sign of life and check if connected
                        var check = self.client_db.rcv_sign_of_life_from(tmp_msg.msg.name)
                        self.add_log("rcv echo - \(check.message)")
                    break
                    case 3: /*message*/
                        self.add_log("rcv msg from '\(tmp_msg.msg.name)'")
                        
                        //set sign of life and check if connected
                        var check = self.client_db.rcv_sign_of_life_from(tmp_msg.msg.name)
                        var tmp = self.client_db.set_msgs_for(tmp_msg.msg.name)
                        
                        if check.status && tmp.status {
                            //add message to list
                            var list = self.msg_db.add_message(tmp_msg.msg.name, _message: tmp_msg.msg.message)
                            self.add_log("\(list.message)")
                            self.add_log("broadcast message from '\(tmp_msg.msg.name)' to '\(self.client_db.get_client_count())' clients")
                        
                            //send message to clients
                            self.sendBroadcast(tmp_msg.msg.message, sender_name: tmp_msg.msg.name)
                            self.ws_connection.sendMessage(tmp_msg.msg)
                        }
                        else {
                            self.add_log("\(check.message)")
                            self.add_log("\(tmp.message)")
                        }
                    break
                    default: /*default*/
                        self.add_log("msg from '\(tmp_msg.msg.name)' not valid -> reason: incorrect type")
                    break
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                //refresh client count on gui
                self.o_curr_clients.stringValue = "\(self.client_db.get_client_count()) / \(max_clients)"
            
                //refresh msg count on gui
                self.o_current_msg.integerValue = self.msg_db.get_message_count()
            
                //refresh client table
                self.tabe.reloadData()
            }
        }
        
    }
    
    /* ---------------------------- */
    /* use websockets */
    @IBOutlet weak var o_ws_connection: NSButton!
    @IBAction func o_ws_connection_a(sender: AnyObject) {
        //use ws
        if o_ws_connection.integerValue == 1 {
            add_log("enable websocket connection to: '\(ws_sock_server_1)'")
        }
        else {
            add_log("disable websocket connection")
        }
    }
    
    /* ---------------------------- */
    /* use websockets */
    @IBOutlet weak var o_ip_connection: NSButton!
    @IBAction func o_ip_connection_a(sender: AnyObject) {
        //use ip
        if o_ip_connection.integerValue == 1 {
            add_log("enable ip connection at IP: '!!!!!!!!!!!!!!!'")
        }
        else {
            add_log("disbale ip connection")
        }
    }
    
    /* ---------------------------- */
    /* button - start, stop server */
    @IBOutlet weak var button_start_stopp: NSButton!
    @IBAction func start_stopp_server(sender: AnyObject) {
        
        //if offline go online
        if server == server_state.OFFLINE {
            
            //check conditions
            if i_server_name.stringValue == "" || i_server_pass.stringValue == "" {
                add_log("can not start server -> empty data")
                
                //sound
                playSound("Funk.aiff")
                //return
            }
            if o_ip_connection.integerValue == 0 && o_ws_connection.integerValue == 0 {
                add_log("can not start server -> no connection")
                
                //sound
                playSound("Funk.aiff")
                //return
            }
            
            //set vars
            add_log("start server \(i_server_name.stringValue) at IP: '!!!!!!!!!!!!!!!")
            o_curr_status.stringValue = "online"
            o_status_indicator.startAnimation(sender)
            i_server_name.editable = false
            i_server_pass.editable = false
            button_start_stopp.title = "stop server"
            o_ip_connection.enabled = false
            o_ws_connection.enabled = false
            
            //echo timer
            add_log("start echo refresh timer interval: '\(client_refresh_time)' [sec]")
            client_refresh_timer = NSTimer.scheduledTimerWithTimeInterval(client_refresh_time, target: self, selector: Selector("client_refresh_cylce"), userInfo: nil,repeats: true)
            
            //msg timer
            add_log("start msg refresh timer interval: '\(msg_refresh_time)' [sec]")
            msg_refresh_timer = NSTimer.scheduledTimerWithTimeInterval(msg_refresh_time, target: self, selector: Selector("msg_refresh_cycle"), userInfo: nil,repeats: true)
            
            //set state
            server = server_state.ONLINE
        }
        else if server == server_state.ONLINE {
            
            //set vars
            add_log("stop server")
            o_curr_status.stringValue = "offline"
            o_status_indicator.stopAnimation(sender)
            i_server_name.editable = true
            i_server_pass.editable = true
            button_start_stopp.title = "start server"
            o_ip_connection.enabled = true
            o_ws_connection.enabled = true
            
            //echo timer
            add_log("stop echo refresh timer interval: '\(client_refresh_time)' [sec]")
            client_refresh_timer.invalidate()
            
            //echo timer
            add_log("stop msg refresh timer interval: '\(msg_refresh_time)' [sec]")
            msg_refresh_timer.invalidate()
            
            //set state
            server = server_state.OFFLINE
        }
        
        //sound
        playSound("Submarine.aiff")
    }
    
    /* ---------------------------- */
    /* add text to log */
    var entries:Int = 0
    func add_log(text: String) -> (Bool) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //generate string
        var text:String = "\(timestamp) -> \(text) \n"
        
        //system output
        print(colorizeText(text).string)
        
        //write to file
        if o_log_to_file.integerValue == 1 { writeToFile(text) }
        
        //textview out
        dispatch_async(dispatch_get_main_queue()) {
            //add text
            self.o_log.string! += colorizeText(text).string
            
            if self.entries >= max_log_entries {
                self.o_log.string! = ""
                self.entries = 0
            }
            self.o_log.scrollRangeToVisible(NSRange(location: countElements(self.o_log.string!), length: 0))
        }
        entries++
        return true
    }
    
    /* ---------------------------- */
    /* logfile handler */
    @IBOutlet weak var o_log_to_file: NSButton!
    @IBAction func o_log_to_file_a(sender: AnyObject) {
    
        //start log
        if o_log_to_file.integerValue == 1 {
            
            //generate timestamp
            var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            let newtimestamp = timestamp.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let newtimestamp2 = newtimestamp.stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
            //generate log name / path
            logfile_location = "\(logfile_location)whatsswift_log_\(newtimestamp2).txt"
            
            //log
            add_log("generate logfile at '\(logfile_location)'")
            add_log("start logging to file")
            
        }
        else {
            
            //log
            add_log("stop logging to file")
        }
        
    }
    
    /* ---------------------------- */
    /* clients table */
    @IBOutlet weak var tabe: NSTableView!
    
    //update rows
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let numberOfRows:Int = client_db.get_client_count()
        //let numberOfRows:Int = getDataArray().count
        return numberOfRows
    }
    
    /* ---------------------------- */
    //set data
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        //show identifier
        //var string:String = "row " + String(row) + ", Col" + String(tableColumn.identifier)
        //println(string)
        //return string
        
        //clients
        var clients : Array<s_client> = client_db.get_client_list()
        var string = ""
        if client_db.get_client_count() != 0 {
        switch tableColumn.identifier {
            case "Name":
                string = clients[row].name
            case "ID":
                string = "\(clients[row].id)"
            case "IP":
                string = clients[row].ip
            case "Port":
                string = "\(clients[row].port)"
            case "Type":
                string = clients[row].type
            case "Error":
                string = "\(clients[row].error)"
            case "Messages":
                string = "\(clients[row].msgs)"
            case "Connected":
                string = clients[row].time
            default:
                string = ":)"
            
        }
        }
        //var newString = getDataArray().objectAtIndex(row).objectForKey(tableColumn.identifier)
        //println("\(row)  \(tableColumn.identifier)")
        //println(string)
        return string
    }
    
}


