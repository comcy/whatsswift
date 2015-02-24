//
//  Helpers.swift
//  WhatsSwiftnew
//
//  Created by Janssen, Lukas on 23.12.14.
//  Copyright (c) 2014 Janssen, Lukas. All rights reserved.
//

import Cocoa
import Foundation
import Darwin

let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
var clientNamens: Dictionary <String, NSColor> = Dictionary()


/***********************************************************************************
**** "isValidIp"                                                                ****
**** - Prüft ob die eingehende IP-Adresse der                                   ****
****   regular expression "validIpAddressRegex" entspricht                      ****
***********************************************************************************/
func isValidIp(ip: String) -> Bool {
    if (ip.rangeOfString(validIpAddressRegex, options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
        //println("Richtige IP: \(ip)")
        return true
    } else {
        //println("Falsche IP: \(ip)")
        return false;}
    
}

/***********************************************************************************
**** "getRandomColor"                                                           ****
**** - Erzeugt eine zufällige Farbe die nicht weiss ist                         ****
***********************************************************************************/
func getRandomColor () -> NSColor {

    var a = CGFloat(Int(arc4random_uniform(8)))/10 + 0.1
    var b = CGFloat(Int(arc4random_uniform(8)))/10 + 0.1
    var c = CGFloat(Int(arc4random_uniform(8)))/10 + 0.1

    return NSColor(red: a, green: b, blue: c, alpha: 1.0)
}

/***********************************************************************************
**** "addInList"                                                               ****
**** - Verwaltet das Dictionary <String, NSColor> clientNamens                 ****
**** - Das Dictionary ermöglich das Einfärben der Nutzernamen im Chat          ****
**** - Legt für jeden Member (Nutzername) "einen" Eintrag in clientNamens an   ****
**** - Jeder Eintrag bekommt eine Farbe von getRandomColor() zugewiesen        ****
**********************************************************************************/
func addInList(member: String) ->Bool {
    
    if(clientNamens[member] != nil) {
        return true;
    } else {
        clientNamens[member] = getRandomColor();
        return false;
    }
}