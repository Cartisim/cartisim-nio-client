import ArgumentParser
import Foundation
import NIO
import NIOTransportServices

public class UniversalBootstrap {
    
    
    private var host: String
    private var port: Int
    private var isEncryptedObject: Bool
    private var tls: Bool
    private var url: String
    
    public init(host: String = "", port: Int = 8081, isEncryptedObject: Bool = false, tls: Bool = false, url: String = "") {
        self.host = host
        self.port = port
        self.isEncryptedObject = isEncryptedObject
        self.tls = tls
        self.url = url
    }
    
    internal struct NoNetworkFrameworkError: Error {}
    
    public static let configuration = CommandConfiguration(
        abstract: """
                    This is our Universal Bootstrap
                  """)
    
    @Flag(help: "Force using NIO on Network.framework.")
    var forceTransportServices: Bool
    
    @Flag(help: "Force using NIO on BSD sockets.")
    var forceBSDSockets: Bool
    
    //    @Argument(default: "https://cartisim.io", help: "The URL.")
    //    var url: String
    
    public func run() throws {
        var group: EventLoopGroup? = nil
        if self.forceTransportServices {
            #if canImport(Network)
            if #available(macOS 10.14, *) {
                group = NIOTSEventLoopGroup()
            } else {
                print("Sorry, your OS is too old for Network.framework.")
                exit(0)
            }
            #else
            print("Sorry, no Network.framework on your OS.")
            exit(0)
            #endif
        }
        if self.forceBSDSockets {
            group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        }
        defer {
            try? group?.syncShutdownGracefully()
        }
        
        let provider: EventLoopGroupManager.Provider = group.map { .shared($0) } ?? .createNew
        
        #if canImport(Network)
        if #available(macOS 10.14, *) {
            let cartisimNIOClient = CartisimNIOClient(host: host, port: port, isEncryptedObject: isEncryptedObject, tls: tls, groupProvider: provider)
            defer {
                cartisimNIOClient.disconnect()
            }
            try cartisimNIOClient.connect()
        }
        #else
        let httpClient = HTTPLibrary(groupProvider: provider)
        defer {
            try! httpClient.shutdown()
        }
        try httpClient.makeRequest(url: url)
        #endif
    }
}

