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
class AppDelegate: NSObject, NSApplicationDelegate {

    //outlet
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var log: NSScrollView!

    //startup
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    //shutdown
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

