//
//  ChatHandler.swift
//  Cartisim
//
//  Created by Cole M on 3/9/21.
//  Copyright © 2021 Cole M. All rights reserved.
//

import NIO


public typealias ServerDataReceived = (ChatData) -> ()

class ChatHandler: ChannelOutboundHandler, ChannelInboundHandler {
    
    public typealias OutboundIn = ByteBuffer
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    public var dataReceived: ServerDataReceived?

    enum ServerResponse {
        case dataFromServer
        case error(Error)
    }
    
    private var currentlyWaitingFor = ServerResponse.dataFromServer {
        didSet {
            if case .error(let error) = self.currentlyWaitingFor {
                print(error, "Waiting for errror")
            }
        }
    }
    
    public func channelActive(context: ChannelHandlerContext) {
        #if DEBUG
        print("Chat Client connected to \(context.remoteAddress!)")
        #endif
    }
    
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny){
        switch self.currentlyWaitingFor {
        case .dataFromServer:
            var result = self.unwrapInboundIn(data)
            let readableBytes = result.readableBytes
            if let received = result.readData(length: readableBytes) {
                guard let d = dataReceived else {return}
                    d(ChatData(data: received))
            }
        case .error(let error):
            fatalError("We have a fatal receiving data from the server: \(error)")
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
}
