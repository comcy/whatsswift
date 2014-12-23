//
//  main.swift
//  WhatsSWIFT_Connection
//
//  Created by compilerlabor on 21/12/14.
//  Copyright (c) 2014 comcy. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

println("WhatsSWIFT - Connection: Testing and Debugging")

//
// TestCases∞
//

// Tests: sendClientMsg() - delimiter '>|<'

/*let con = Connection()

con.sendClientMsg( message(ip: "127.0.0.1", port: "5555", message: "hallo", name: "Mary", type: "1") )
con.sendServerMsg( message(ip: "127.0.0.1", port: "5555", message: "halli", name: "Moe", type: "1") )

var testString:String = "127.0.0.1>|<5555>|<hallo>|<Mary>|<1"


con.splitString(testString)
*/

let socket = Socket()

socket.snd()

//socket.rcv()

