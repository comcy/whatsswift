//
//  Params.swift
//  WhatsSWIFT_Server
//
//  Created by Bauer, Daniel on 16.12.14.
//  Copyright (c) 2014 Bauer, Daniel. All rights reserved.
//
/*
Diese Datei beinhaltet statische Parameter des Servers. Bitte nur anpassen, wenn die Auswirkungen klar bekannt sind! Alle Parameter sind einzeln beschrieben...



*/

/* import */
import Foundation

/* ---------------------------- */
/* static params */

//client refresh time - time between echo requests to clients
var client_refresh_time = 5.0 //sec

//msg refresh time - time between check for new messages
var msg_refresh_time = 0.01 //sec

//max error count before disconnect users (refresh_time*max_error) = time sec
var max_error:Int = 5 //cylces

//max number of simultanious connected clients
var max_clients = 100

//max count of log entries at scroll view. No impact to file size...
var max_log_entries:Int = 500 //lines

//logfile location - name is set automatically e.g. /tmp/whatsswift_log_19.01.2015_1149.txt
var logfile_location = "/tmp/"

//websocket server ip - enter webserver ip here
var ws_sock_server_ip = "141.18.49.242" //only ip, path not needed

//websocket server port
var ws_sock_server_port = 9090 //set port in server.php

//udp server port - enter webserver port here
var udp_sock_port_s = 8585

//udp client port - enter client port here
var udp_sock_port_c = 5252

//udp server ip - do not change, ip is updated automatically
var udp_sock_ip_s = getAddresses()[2]

