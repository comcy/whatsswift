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

/* main */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    //outlet
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var i_server_name: NSTextField!
    @IBOutlet weak var i_server_pass: NSSecureTextField!
    @IBOutlet weak var o_server_ip: NSTextField!
    @IBOutlet weak var o_curr_clients: NSTextField!
    @IBOutlet weak var o_curr_status: NSTextField!
    @IBOutlet weak var o_log: NSScrollView!
    @IBOutlet weak var o_status_indicator: NSProgressIndicator!
    @IBOutlet weak var o_clients: NSTableView!
    
    /* async gcd */
    private let queue_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let queue_concur = dispatch_queue_create ("concur" , DISPATCH_QUEUE_CONCURRENT)
    private let queue_serial = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL)
    
    /* obj */
    var msg_db = message_list()
    var client_db = client_list()
    
    /* vars */
    var server_status:Int = 0 // 0=offline, 1=online, -1=error
    var refresh_timer = NSTimer()

    /* startup */
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        add_log("initialize server")
        
        //debug
        addFakeClients(client_db)

        //init
        o_server_ip.stringValue = ""
        o_curr_clients.integerValue = client_db.get_client_count()
        o_curr_status.stringValue = "offline"
        
    }

    /* shutdowm */
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    /* send echo after timer and inc. error. if error is to high then disconnect */
    func client_refresh_cylce() {
        add_log("start to refresh \(client_db.get_client_count()) clients")
        
        // async
        dispatch_async(queue_global) {
            
            //parse clients
            for (index, value) in enumerate(self.client_db.get_client_list()) {
                
                //check error count
                if value.error >= max_error {
                    //rem client
                    var rem = self.client_db.rem_client(value.ip,_port: value.port,_name: value.name)
                    //self.add_log("\(rem.message) -> reason: not alive")
                }
                
                //inc. error
                var err = self.client_db.set_error_for(value.name)
                
                //check if exists
                if err.status == 1 {
                    //connection send echo
                    //self.add_log("send echo to \(value.id) \(value.name) at \(value.ip) \(value.type) \(value.error)")
                    // +++++++++ connection send echo
                }
                
                //refresh client count on gui
                self.o_curr_clients.integerValue = self.client_db.get_client_count()
            }
        }
    }
    
    /* button - start, stopp server */
    @IBOutlet weak var button_start_stopp: NSButton!
    @IBAction func start_stopp_server(sender: AnyObject) {
        
        //check conditions
        if i_server_name.stringValue == "" || i_server_pass.stringValue == "" {
            add_log("can not start server -> empty data")
            //return
        }
        
        //if offline go online
        if server_status == 0 {
            
            add_log("start server \(i_server_name.stringValue) at IP: 192.168.0.100")
            o_curr_status.stringValue = "online"
            o_status_indicator.startAnimation(sender)
            i_server_name.editable = false
            i_server_pass.editable = false
            
            //echo timer
            add_log("start refresh timer interval: \(refresh_time) [sec]")
            refresh_timer = NSTimer.scheduledTimerWithTimeInterval(refresh_time, target: self, selector: Selector("client_refresh_cylce"), userInfo: nil,repeats: true)
            
        }
        
        //if online go offline
        if server_status == 1 {
            
            add_log("stopp server")
            o_curr_status.stringValue = "offline"
            o_status_indicator.stopAnimation(sender)
            i_server_name.editable = true
            i_server_pass.editable = true
            
            //echo timer
            add_log("stopp refresh timer interval: \(refresh_time) [sec]")
            refresh_timer.invalidate()
            
        }
        
        if server_status==1 { server_status = 0}
        if server_status==0 { server_status = 1}
        
    }
    
    /* add text to log */
    func add_log(text: String) -> (Bool) {
        
        //generate timestamp
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        //generate string
        var text:String = "Log: \(timestamp) -> \(text) \n"
        
        //system output
        print(text)
        
        //scrollview out
        var textField : NSTextView {
            get {
            return o_log.contentView.documentView as NSTextView
            }
        }
        textField.insertText(text)
        return true
    }
    
    //++++++++++++++++++++++++++++++++++++
    
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int
    {
    let numberOfRows:Int = getDataArray().count
    return numberOfRows
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row rowIndex: Int) -> AnyObject!
    {
        var newString: (AnyObject?) = getDataArray().objectAtIndex(rowIndex).objectForKey(tableColumn.identifier)
        println(newString!)
        return newString!
    }
    
    func getDataArray () -> NSArray{
        var dataArray:[NSDictionary] = [["FirstName": "Debasis", "LastName": "Das"],
            ["FirstName": "Nishant", "LastName": "Singh"],
            ["FirstName": "John", "LastName": "Doe"],
            ["FirstName": "Jane", "LastName": "Doe"],
            ["FirstName": "Mary", "LastName": "Jane"]];
        println(dataArray);
        return dataArray;
    }
}


