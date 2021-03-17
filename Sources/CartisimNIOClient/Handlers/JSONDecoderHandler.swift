//
//  ChatHandler.swift
//  Cartisim
//
//  Created by Cole M on 3/9/21.
//  Copyright © 2021 Cole M. All rights reserved.
//

import NIO
import Foundation

 typealias EncryptedServerDataReceived = (EncryptedObject) -> ()
 typealias ServerDataReceived = (MessageData) -> ()

 final class JSONDecoderHandler<Message: Decodable>: ChannelInboundHandler {
     typealias InboundIn = ByteBuffer
     typealias InboundOut = Message
     var isEncryptedObject: Bool
     let jsonDecoder: JSONDecoder
    
     init(isEncryptedObject: Bool, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.isEncryptedObject = isEncryptedObject
        self.jsonDecoder = jsonDecoder
    }
    
    
     var dataReceived: ServerDataReceived?
     var encryptedDataReceived: EncryptedServerDataReceived?
    
     enum ServerResponse {
        case dataFromServer
        case error(Error)
    }
    
     func channelActive(context: ChannelHandlerContext) {
        print("Chat Client connected to \(context.remoteAddress!)")
    }
    
    
     func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
    
     var currentlyWaitingFor = ServerResponse.dataFromServer {
        didSet {
            if case .error(let error) = self.currentlyWaitingFor {
                print(error, "Waiting for errror")
            }
        }
    }
    
     func channelRead(context: ChannelHandlerContext, data: NIOAny){
        switch self.currentlyWaitingFor {
        case .dataFromServer:
            let bytes = self.unwrapInboundIn(data)
            
            if isEncryptedObject == true {
                guard let receivedEncryptedData = encryptedDataReceived else {return}
                guard let decodeEncryptedData = try? self.jsonDecoder.decode(Message.self, from: bytes) as? EncryptedObject else {return}
                receivedEncryptedData(EncryptedObject(encryptedObjectString: decodeEncryptedData.encryptedObjectString))
            } else {
                guard let receivedData = dataReceived else {return}
                guard let decodeData = try? self.jsonDecoder.decode(Message.self, from: bytes) as? MessageData else {return}
                receivedData(MessageData(avatar: decodeData.avatar, userID: decodeData.userID, name: decodeData.name, message: decodeData.message, accessToken: decodeData.accessToken, refreshToken: decodeData.refreshToken, sessionID: decodeData.sessionID, chatSessionID: decodeData.chatSessionID))
            }
            
        case .error(let error):
            fatalError("We have a fatal receiving data from the server: \(error)")
        }
    }
}
