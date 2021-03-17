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

 class CartisimNIOClient {
    
     var host: String
     var port: Int
    internal var isEncryptedObject: Bool
     var channel: Channel? = nil
     var jsonDecoderHandler = JSONDecoderHandler<MessageData>(isEncryptedObject: false)
     var encryptedJsonDecoderHandler = JSONDecoderHandler<EncryptedObject>(isEncryptedObject: true)
     let group = NIOTSEventLoopGroup()
     var onDataReceived: ServerDataReceived?
     var onEncryptedDataReceived: EncryptedServerDataReceived?
    
     init(host: String, port: Int, isEncryptedObject: Bool) {
        self.host = host
        self.port = port
        self.isEncryptedObject = isEncryptedObject
    }
    
    
     func makeNIOHandlers() -> [ChannelHandler] {
        if isEncryptedObject {
            return [
                ByteToMessageHandler(LineBasedFrameDecoder()),
                self.encryptedJsonDecoderHandler,
                MessageToByteHandler(JSONMessageEncoder<EncryptedObject>())
            ]
        } else {
            return [
                ByteToMessageHandler(LineBasedFrameDecoder()),
                self.jsonDecoderHandler,
                MessageToByteHandler(JSONMessageEncoder<MessageData>())
            ]
        }
    }
    
     func clientBootstrap() -> NIOTSConnectionBootstrap {
        let bootstrap: NIOTSConnectionBootstrap
        #if DEBUG || LOCAL
        bootstrap = NIOTSConnectionBootstrap(group: group)
            .connectTimeout(.seconds(5))
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
     func connect() {
        let messageSentPromise: EventLoopPromise<Void> = group.next().makePromise()
        let connection = clientBootstrap()
            .connect(host: host, port: port)
            .map { channel -> () in
                self.channel = channel
            }
        connection.cascadeFailure(to: messageSentPromise)
        messageSentPromise.futureResult.map {
            connection.whenSuccess {
                guard let address = self.channel?.remoteAddress else {return}
                print("CartisimNIOClient connected to ChatServer: \(address)")
            }
        }.whenFailure { error in
            print("CartisimNIOClient failed to run for the following reason: \(error)")
            self.disconnect()
        }
    }
    
    //Shutdown the program
     func disconnect() {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print("Could not gracefully shutdown, Forcing the exit (\(error)")
            exit(0)
        }
        print("closed server")
    }
    
    //Send data to the Server
     func send(chat: MessageData) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }
    
    
     func sendEncryptedObject(chat: EncryptedObject) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }
    
    //Handle Data received from server
     func dataReceived() {
        if isEncryptedObject {
            encryptedJsonDecoderHandler.encryptedDataReceived = { [weak self] data in
                guard let strongSelf = self else {return}
                guard let receivedData = strongSelf.onEncryptedDataReceived else {return}
                receivedData(data)
            }
        } else {
            jsonDecoderHandler.dataReceived = { [weak self] data in
                guard let strongSelf = self else {return}
                guard let receivedData = strongSelf.onDataReceived else {return}
                receivedData(data)
            }
        }
    }
}
