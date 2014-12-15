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
    @IBOutlet weak var o_server_ip: NSTextField!
    @IBOutlet weak var o_curr_clients: NSTextField!
    @IBOutlet weak var o_curr_status: NSTextField!
    @IBOutlet weak var o_log: NSScrollView!
    @IBOutlet weak var o_status_indicator: NSProgressIndicator!
   
    //obj
    var msg_db = message_list()
    var client_db = client_list()
    
    //button - start, stopp server
    @IBAction func start_stopp_server(sender: AnyObject) {
        add_log("initialize server",o_log)
    }

    //startup
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        add_log("initialize server",o_log)
        
        //init
        o_server_ip.stringValue = ""
        o_curr_clients.integerValue = 0
        o_curr_status.stringValue = "offline"
        
    }

    //shutdown
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

