import XCTest
import NIO
@testable import CartisimNIOClient

final class CartisimNIOClientTests: XCTestCase {
    
    func testCartisimNIOClient() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let cartisimNIOClient = CartisimNIOClient(host: "localhost", port: 8081)
        do {
            try cartisimNIOClient.run()
            
            guard let data = chatData else {return}
            cartisimNIOClient.send(chat: data)
            
            cartisimNIOClient.onDataReceived = { data in
                print(data.stringRepresentation!)
            }
            
            cartisimNIOClient.shutdown()
        } catch {
            XCTFail("\(error)")
        }
    }
    
    static var allTests = [
        ("testCartisimNIOClient", testCartisimNIOClient),
    ]
    
    let chatData = """
    This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times. This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times. This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times. This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times. This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times. This is an awesome message and we want it to be really long so we will just repeat this sentence way too many times.
    """.data(using: .utf8)
}
