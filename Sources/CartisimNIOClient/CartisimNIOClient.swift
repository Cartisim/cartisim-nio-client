//  cartisim_nio_client.swift
//  Cartisim
//
//  Created by Cole M on 3/9/21.
//  Copyright © 2021 Cole M. All rights reserved.
//
import Foundation
import Network
import NIO
import NIOSSL
import NIOExtras
import NIOTransportServices
import ArgumentParser

@available(OSX 10.14, *)
public class CartisimNIOClient {

    let groupManager: EventLoopGroupManager
    private var host: String
    private var port: Int
    private var isEncryptedObject: Bool
    private var tls: Bool
    private var channel: NIO.Channel? = nil
    private var jsonDecoderHandler = JSONDecoderHandler<MessageData>(isEncryptedObject: false)
    private var encryptedJsonDecoderHandler = JSONDecoderHandler<EncryptedObject>(isEncryptedObject: true)
    private let group = NIOTSEventLoopGroup()
    public var onDataReceived: ServerDataReceived?
    public var onEncryptedDataReceived: EncryptedServerDataReceived?


    ///Here in our initializer we need to inject our host, port, and whether or not we will be sending an encrypted obejct from the client.
    ///Client initialitaion will look like this `CartisimNIOClient(host: "localhost", port, 8081, isEncryptedObject: true, tls: Bool)`
    public init(host: String, port: Int, isEncryptedObject: Bool, tls: Bool, groupProvider provider: EventLoopGroupManager.Provider) {
        self.host = host
        self.port = port
        self.isEncryptedObject = isEncryptedObject
        self.tls = tls
        self.groupManager = EventLoopGroupManager(provider: provider)
    }

    ///Check if we are going to decode and encrypted object or a regular object and user the appropiated handler
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

    ///Setup the bootstrap checked  whether or not we are in debug mode and added in the tls options.
//    private func clientBootstrap() -> NIOTSConnectionBootstrap {
//        let bootstrap: NIOTSConnectionBootstrap
//
//        if !tls {
//            bootstrap = NIOTSConnectionBootstrap(group: group)
//                .connectTimeout(.hours(1))
//                .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
//                .channelInitializer { channel in
//                    channel.pipeline.addHandlers(self.makeNIOHandlers())
//                }
//        } else {
//            bootstrap = NIOTSConnectionBootstrap(group: group)
//                .connectTimeout(.hours(1))
//                .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
//                .tlsOptions(NWProtocolTLS.Options())
//                .channelInitializer { channel in
//                    channel.pipeline.addHandlers(self.makeNIOHandlers())
//                }
//        }
//
//        return bootstrap
//
//    }
    
    private func clientBootstrap() throws -> NIOClientTCPBootstrap {
        let bootstrap: NIOClientTCPBootstrap

        if !tls {
            bootstrap = try groupManager.makeBootstrap(hostname: host, useTLS: false)
                .connectTimeout(.hours(1))
                .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandlers(self.makeNIOHandlers())
                }
        } else {
            bootstrap = try groupManager.makeBootstrap(hostname: host, useTLS: true)
                .connectTimeout(.hours(1))
                .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
                .channelInitializer { channel in
                    channel.pipeline.addHandlers(self.makeNIOHandlers())
                }
        }

        return bootstrap

    }


    public func connect() throws {
        let connection = try clientBootstrap()
            .connect(host: host, port: port)
            .map { channel -> () in
                self.channel = channel
            }
        do {
            try connection.wait()
        } catch {
            print("We have an error connecting to the server: \(error)")
        }
    }

    //Shutdown the program
    public func disconnect() {
        do {
            try groupManager.syncShutdown()
        } catch {
            print("Could not gracefully shutdown, Forcing the exit (\(error)")
            exit(0)
        }
        print("closed server")
    }

    ///Send MessageDataObject to the Server
    ///- `MessageData(avatar: "", userID: "", name: "", message: "", accessToken: "", refreshToken: "", sessionID: "", chatSessionID: "")`
    public func send(chat: MessageData) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }

    ///Send your object as an encrypted object
    ///- `EncrytedObject(encryptedObjectString: "")`
    public func sendEncryptedObject(chat: EncryptedObject) {
        channel?.writeAndFlush(chat, promise: nil)
        dataReceived()
    }

    ///Handle Data received from server. We need to specify which decoder handler we are using.
    ///So if from our client we are sending an encryptedObject the well we specify the encypted data
    ///decoder and if it is not then the decoderHandler
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
