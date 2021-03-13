//  cartisim_nio_client.swift
//  Cartisim
//
//  Created by Cole M on 3/9/21.
//  Copyright © 2021 Cole M. All rights reserved.
//

import Foundation
import Network
import NIO
import NIOExtras
import NIOTransportServices

public class CartisimNIOClient {
    
    private var host: String?
    private var port: Int?
    private var channel: Channel? = nil
    private var chatHandler = ChatHandler()
    private let group = NIOTSEventLoopGroup()
    public var onDataReceived: ServerDataReceived?
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    
    func makeNIOHandlers() -> [ChannelHandler] {
        return [
//            ByteToMessageHandler(LineBasedFrameDecoder()),
            self.chatHandler
        ]
    }
    
    func clientBootstrap() -> NIOTSConnectionBootstrap {
        let bootstrap: NIOTSConnectionBootstrap
        #if DEBUG || LOCAL
        bootstrap = NIOTSConnectionBootstrap(group: group)
            .connectTimeout(.hours(1))
            .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandlers(self.makeNIOHandlers())
            }
        #else
        bootstrap = NIOTSConnectionBootstrap(group: group)
            .connectTimeout(.hours(1))
            .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .tlsOptions(NWProtocolTLS.Options())
            .channelInitializer { channel in
                channel.pipeline.addHandlers(self.makeNIOHandlers())
            }
        #endif
        
        return bootstrap
        
    }
    
    //Run the program
    func run() throws {
        guard let host = host else {
            throw TCPError.invalidHost
        }
        guard let port = port else {
            throw TCPError.invalidPort
        }
        
        try? clientBootstrap().connect(host: host, port: port)
            .map { channel -> () in
                self.channel = channel
            }.wait()
        
        
        guard let localAddress = channel?.localAddress else {
            fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
        }
        print("Client started and listening on \(localAddress)")
    }
    
    //Shutdown the program
    func shutdown() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Could not gracefully shutdown, Forcing the exit (\(error)")
            exit(0)
        }
        print("closed server")
    }
    
    //Send data to the Server
    func send(chat: Data) {
        let buffer = ByteBuffer(data: chat)
        channel?.writeAndFlush(chatHandler.wrapOutboundOut(buffer), promise: nil)
        dataReceived()
    }
    
    //Handle Data received from server
    func dataReceived() {
        chatHandler.dataReceived = { [weak self] data in
            guard let strongSelf = self else {return}
            guard let receivedData = strongSelf.onDataReceived else {return}
            receivedData(data)
        }
    }
}
