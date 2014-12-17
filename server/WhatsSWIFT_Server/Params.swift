//
//  Params.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 16.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*




*/

/* import */
import Foundation

/* params */

//client refresh time
var client_refresh_time = 5.0 //sec
//msg refresh time
var msg_refresh_time = 0.5 //sec
//max error count befor disconnect (refresh_time*max_error) = time sec
var max_error:Int = 4
//max number of simultanious connected clients
let max_clients = 100
