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

/* ---------------------------- */
/* params */

//client refresh time
var client_refresh_time = 5.0 //sec

//msg refresh time
var msg_refresh_time = 1.0 //sec

//max error count befor disconnect (refresh_time*max_error) = time sec
var max_error:Int = 10

//max number of simultanious connected clients
var max_clients = 100

//max count of log entries
var max_log_entries:Int = 500

//logfile location
var logfile_location = "/tmp/"

//websocket server
var ws_sock_server_1 = "echo.websocket.org"
var ws_sock_server_2 = "141.18.49.242:9300"
var ws_sock_server_3 = "141.18.49.242:8080" //bester, mit username

//tcp server ip
var udp_sock_ip = "141.18.44.66"

//tcp server port
var udp_sock_port = 8585
