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

extension NSTextView {
    func appendString(string:String) {
        self.string! += string
        self.scrollRangeToVisible(NSRange(location:countElements(self.string!), length: 0))
    }
}

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
    @IBOutlet weak var o_current_msg: NSTextField!
    @IBOutlet weak var o_curr_status: NSTextField!
    @IBOutlet weak var o_status_indicator: NSProgressIndicator!
    
    //@IBOutlet var texter: NSTextView!
    //@IBOutlet weak var o_log: NSScrollView!
    
    //@IBOutlet weak var table: NSTableView!

    
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
    
    /* ---------------------------- */
    /* vars */
    var server_status:Int = 0 // 0=offline, 1=online, -1=error
    var client_refresh_timer = NSTimer()
    var msg_refresh_timer = NSTimer()

    /* ---------------------------- */
    /* startup */
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        add_log("initialize server")
        
        //debug
        addFakeClients(client_db)

        //init values
        o_server_ip.stringValue = ""
        o_curr_clients.integerValue = client_db.get_client_count()
        o_current_msg.integerValue = msg_db.get_message_count()
        o_curr_status.stringValue = "offline"
        button_start_stopp.title = "start server"

        
        
    }
    
    /* ---------------------------- */
    /* shutdowm */
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    /* ---------------------------- */
    /* send echo after timer and inc. error. if error is to high then disconnect */
    func client_refresh_cylce() {
        add_log("start to refresh \(client_db.get_client_count()) clients")
        
        // async
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
                
                //check if exists
                if err.status == 1 {
                    //connection send echo
                    self.connection.sendMessage(message(ip: value.ip, message: "echo", name: value.name, port: value.port, type: 2))
                    self.add_log("send echo to \(value.id) \(value.name) at \(value.ip) \(value.type) \(value.error)")
                }
                
                //refresh client count on gui
                self.o_curr_clients.integerValue = self.client_db.get_client_count()
            }
            
            //refresh list
            self.tabe.reloadData()
        }
    }
    
    /* ---------------------------- */
    /* msg refresh cycle. check connection for new messages */
    func msg_refresh_cycle() {
        //add_log("start to refresh msg")
        //self.texter.appendString("dfdffff \n")
        //texter.textStorage().mutableString().setString("")
        //texter.textStorage?.mutableString.setString("fdfdf")
        //tabe.reloadData()
        
        // async
        dispatch_async(queue_serial) {
        
            //check for msg
            var tmp_msg =  self.connection.receiveMessage()
            
            //if new message send broadcast and add to msg_db
            if tmp_msg.status == 1 {
                
                //set sign of life and check if connected
                var check = self.client_db.rcv_sign_of_life_from(tmp_msg.msg.name)
                
                //if connected
                if check.status == 1 {
                    
                    //add message to list
                    var list = self.msg_db.add_message(tmp_msg.msg.name, _message: tmp_msg.msg.message)
                    self.add_log("\(list.message)")
                    
                    for (index, value) in enumerate(self.client_db.get_client_list()) {
                        //send message
                        self.connection.sendMessage(message(ip: value.ip, message: tmp_msg.msg.message, name: tmp_msg.msg.name, port: value.port, type: 3))
                        self.add_log("send message from \(tmp_msg.msg.name) with id \(self.msg_db.get_message_count()) to \(value.id) \(value.name) at \(value.ip) \(value.type) \(value.error)")
                        
                        //refresh msg count on gui
                        self.o_current_msg.integerValue = self.msg_db.get_message_count()
                    }
                }
                else {
                    self.add_log("message not delivered -> reason: \(check.message)")
                    return
                }
                
            }
        }

        
    }
    
    

    
    /* ---------------------------- */
    /* button - start, stop server */
    @IBOutlet weak var button_start_stopp: NSButton!
    @IBAction func start_stopp_server(sender: AnyObject) {
        
        //numberOfRowsInTableView(table)
        //tableView(table,"", row: 1)
        
        //if offline go online
        if server_status == 0 {
            
            //check conditions
            if i_server_name.stringValue == "" || i_server_pass.stringValue == "" {
                add_log("can not start server -> empty data")
                //return
            }
            
            add_log("start server \(i_server_name.stringValue) at IP: 192.168.0.100")
            o_curr_status.stringValue = "online"
            o_status_indicator.startAnimation(sender)
            i_server_name.editable = false
            i_server_pass.editable = false
            button_start_stopp.title = "stop server"
            
            //echo timer
            add_log("start echo refresh timer interval: \(client_refresh_time) [sec]")
            client_refresh_timer = NSTimer.scheduledTimerWithTimeInterval(client_refresh_time, target: self, selector: Selector("client_refresh_cylce"), userInfo: nil,repeats: true)
            
            //msg timer
            add_log("start msg refresh timer interval: \(msg_refresh_time) [sec]")
            msg_refresh_timer = NSTimer.scheduledTimerWithTimeInterval(msg_refresh_time, target: self, selector: Selector("msg_refresh_cycle"), userInfo: nil,repeats: true)
            
            server_status = 1
        }
        else if server_status == 1 {
            
            add_log("stopp server")
            o_curr_status.stringValue = "offline"
            o_status_indicator.stopAnimation(sender)
            i_server_name.editable = true
            i_server_pass.editable = true
            button_start_stopp.title = "start server"
            
            //echo timer
            add_log("stopp echo refresh timer interval: \(client_refresh_time) [sec]")
            client_refresh_timer.invalidate()
            
            //echo timer
            add_log("stopp msg refresh timer interval: \(msg_refresh_time) [sec]")
            msg_refresh_timer.invalidate()
            
            server_status = 0
        }
        
    }
    
    /* ---------------------------- */
    /* add text to log */
    func add_log(text: String) -> (Bool) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //generate string
        var text:String = "Log: \(timestamp) -> \(text) \n"
        
        //system output
        print(text)
        
        //scrollview out
        /*var textField : NSTextView {
            get {
            //return o_log.contentView.documentView as NSTextView
            }
        }*/
        //textField.insertText(text)
        //texter.insertText("dfdfdf \n")
        //texter.appendString(text)
        //texter.string! += text
        return true
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
            case "Connected":
                string = clients[row].time
            default:
                string = ":)"
            
        }
        }
        //var newString = getDataArray().objectAtIndex(row).objectForKey(tableColumn.identifier)
        //println("\(row)  \(tableColumn.identifier)")
        return string
    }
    /*func getDataArray () -> NSArray{
        var dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
            ["FirstName": "Nishant", "LastName": "Singh"],
            ["FirstName": "John", "LastName": "Doe"],
            ["FirstName": "Jane", "LastName": "Doe"],
            ["FirstName": "Mary", "LastName": "Jane"]];
        //println(dataArray);
        return dataArray;
    }*/
    
}


