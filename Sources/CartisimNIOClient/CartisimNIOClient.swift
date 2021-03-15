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
    
    private var host: String
    private var port: Int
    internal var isEncryptedObject: Bool
    private var channel: Channel? = nil
    private var jsonDecoderHandler = JSONDecoderHandler<MessageData>(isEncryptedObject: false)
    private var encryptedJsonDecoderHandler = JSONDecoderHandler<EncryptedObject>(isEncryptedObject: true)
    private let group = NIOTSEventLoopGroup()
    public var onDataReceived: ServerDataReceived?
    public var onEncryptedDataReceived: EncryptedServerDataReceived?
    
    public init(host: String, port: Int, isEncryptedObject: Bool) {
        self.host = host
        self.port = port
        self.isEncryptedObject = isEncryptedObject
    }
    
    
    private func makeNIOHandlers() -> [ChannelHandler] {
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
    
    private func clientBootstrap() -> NIOTSConnectionBootstrap {
        let bootstrap: NIOTSConnectionBootstrap
        #if DEBUG || LOCAL
        bootstrap = NIOTSConnectionBootstrap(group: group)
            .connectTimeout(.seconds(3))
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
    public func connect() {
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
    public func disconnect() {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print("Could not gracefully shutdown, Forcing the exit (\(error)")
            exit(0)
        }
        print("closed server")
    }
    
    //Send data to the Server
    public func send(chat: MessageData) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }
    
    
    public func sendEncryptedObject(chat: EncryptedObject) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }
    
    //Handle Data received from server
    private func dataReceived() {
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
