import XCTest
import NIO
@testable import CartisimNIOClient

final class CartisimNIOClientTests: XCTestCase {
    
    func testEncryptedCartisimNIOClient() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let cartisimNIOClient = CartisimNIOClient(host: "localhost", port: 8081, isEncryptedObject: true)
        cartisimNIOClient.connect()
        
        cartisimNIOClient.sendEncryptedObject(chat: encryptedObject)
        
        cartisimNIOClient.onEncryptedDataReceived = { data in
            print(data)
        }
        
        cartisimNIOClient.disconnect()
    }
    
    func testCartisimNIOClient() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let cartisimNIOClient = CartisimNIOClient(host: "localhost", port: 8081, isEncryptedObject: false)
        cartisimNIOClient.connect()
        cartisimNIOClient.send(chat: object)

        cartisimNIOClient.onDataReceived = { data in
            print(data)
        }

        cartisimNIOClient.disconnect()
    }
    
    static var allTests = [
        ("testEncryptedCartisimNIOClient", testEncryptedCartisimNIOClient),
        ("testCartisimNIOClient", testCartisimNIOClient)
    ]
    
    let encryptedObject = EncryptedObject(encryptedObjectString: "anEncryptedString")
    
    let object = MessageData(avatar: "avatar", userID: "123456", name: "user", message: "awesome message", accessToken: "121211212", refreshToken: "222", sessionID: "989876", chatSessionID: "49857629")
}
