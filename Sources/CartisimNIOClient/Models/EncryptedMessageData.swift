import Foundation

public struct EncryptedObject: Codable {
    public var encryptedObjectString: String
    
    internal init(encryptedObjectString: String) {
        self.encryptedObjectString = encryptedObjectString
    }
}
