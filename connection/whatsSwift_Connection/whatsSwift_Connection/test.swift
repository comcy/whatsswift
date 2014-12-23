//
//  test.swift
//  whatsSwift_Connection
//
//  Created by Silfang, Christian on 23.12.14.
//  Copyright (c) 2014 comcy. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class Socket{
    
    init(){
        
    }
    
    func snd(){
        
        // create some data to read
        let data: NSData = "Howdy,  pardner.".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        data.length
        
        // create a stream that reads the data above
        let stream: NSInputStream = NSInputStream(data: data)
        
        // begin reading
        stream.open()
        var readBytes = [UInt8](count: 8, repeatedValue: 0)
        while stream.hasBytesAvailable {
            let result: Int = stream.read(&readBytes, maxLength: readBytes.count)
            result
            //readBytes
        }
        
        let addr = "141.18.44.62"
        let port = 54330
        
        var host :NSHost = NSHost(address: addr)
        var inp :NSInputStream?
        var out :NSOutputStream?
        
        NSStream.getStreamsToHost(host, port: port, inputStream: &inp, outputStream: &out)
        
        let inputStream = inp!
        let outputStream = out!
        inputStream.open()
        outputStream.open()
        
        outputStream.write(&readBytes, maxLength: readBytes.count)
        
    }
    
    //testClient
    func testclient(){
        //new socket connecting to Google on port 80
        var client:TCPClient = TCPClient(addr: "141.18.44.62", port: 8585)
        
        //connection
        var (success,errmsg)=client.connect(timeout: 120)
        if success{
            //send data/request
            var (success,errmsg)=client.send(str:"Hallo -> Ficken!?" )
            if success{
                //read data/answer
                var data=client.read(1024*10)
                if let d=data{
                    //print received data on console
                    if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                        println(str)
                    }
                }
            }else{
                println(errmsg)
            }
        }else{
            println(errmsg)
        }
    }
    
    
    

}