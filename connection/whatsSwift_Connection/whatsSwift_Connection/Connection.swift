//
//  main.swift
//  whatsSwift_Connection
//
//  Created by Silfang, Christian on 15.12.14.
//  Copyright (c) 2014 Silfang, Christian. All rights reserved.
//

import Foundation

/* Message */
struct s_message {
    var ip:String = ""
    var port:int = 25252
    var message:String = ""
    var name:String = ""
    var type:Int = 0
}

class Connection{
    
    // messageBuffer-Array zum Buffern von Messages
    var messageBuffer: Array<s_message> = Array<s_message>()
    
    func receiveMessage() -> s_message {
        
        
        
        
        return nil
    }
    
    func sendMessage(s_message.ip, s_message.port, s_message.message, s_message.name, s_message.type) {
        
        var tmpBuffer = s_message(message)
        messageBuffer.append(tmpBuffer)
        
        
    }
    
    /* Hilfsfunktionen */
    
    /* COUNT messageBuffer */
    func getMessageBufferCount() -> int{
        return messageBuffer.count
    }
}