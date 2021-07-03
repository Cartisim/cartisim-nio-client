import ArgumentParser
import Foundation
import NIO
import NIOTransportServices


public class CartisimNIOClient {
    
    private var host: String
    private var port: Int
    private var isEncryptedObject: Bool
    private var tls: Bool
    private var url: String
    #if canImport(Network)
    internal var niotsHandler: NIOTSHandler?
    #endif
    private var httpClient: HTTPLibrary?
    
    
    public init(host: String = "", port: Int = 8081, isEncryptedObject: Bool = false, tls: Bool = false, url: String = "") {
        self.host = host
        self.port = port
        self.isEncryptedObject = isEncryptedObject
        self.tls = tls
        self.url = url
    }
    
    internal struct NoNetworkFrameworkError: Error {}
    
    public func connect() throws {
        var group: EventLoopGroup? = nil
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            group = NIOTSEventLoopGroup()
        } else {
            print("Sorry, your OS is too old for Network.framework.")
            exit(0)
        }
        #else
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        #endif
        
        
        defer {
            try? group?.syncShutdownGracefully()
        }
        
        let provider: EventLoopGroupManager.Provider = group.map { .shared($0) } ?? .createNew
        
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            niotsHandler = NIOTSHandler(host: host, port: port, isEncryptedObject: isEncryptedObject, tls: tls, groupProvider: provider)
            defer {
                niotsHandler?.disconnect()
            }
            try niotsHandler?.connect()
        }
        #else
        httpClient = HTTPLibrary(groupProvider: provider)
        defer {
            try! httpClient.shutdown()
        }
        try httpClient.makeRequest(url: url)
        #endif
    }
    
    
    //Shutdown the program
    public func disconnect() throws {
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            niotsHandler?.disconnect()
        }
        #else
        try! httpClient?.shutdown()
        #endif
        print("closed server")
    }
    
    ///Send MessageDataObject to the Server
    ///- `MessageData(avatar: "", userID: "", name: "", message: "", accessToken: "", refreshToken: "", sessionID: "", chatSessionID: "")`
    public func send(chat: MessageData) {
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            niotsHandler?.send(chat: MessageData.self)
        }
        #else
        #endif
    }
    
    ///Send your object as an encrypted object
    ///- `EncrytedObject(encryptedObjectString: "")`
    public func sendEncryptedObject(chat: EncryptedObject) {
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            niotsHandler?.sendEncryptedObject(chat: EncryptedObject.self)
        }
        #else
        #endif
    }
    
    
    private func dataReceived() {
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            niotsHandler?.dataReceived()
        }
        #else
        #endif
    }
}

