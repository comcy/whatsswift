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

/* add text to log */
func add_log(text: String, o: NSScrollView) -> (Bool) {
    
    //generate timestamp
    var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    
    //generate string
    var text:String = "Log: \(timestamp)\t -> \(text) \n"
    
    //system output
    println(text)
    
    //scrollview out
    var textField : NSTextView {
        get {
            return o.contentView.documentView as NSTextView
        }
    }
    textField.insertText(text)
    
    //file out?
    
    return true
}
