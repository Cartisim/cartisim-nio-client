import Foundation

 struct EncryptedObject: Codable {
     var encryptedObjectString: String
    
     init(encryptedObjectString: String) {
        self.encryptedObjectString = encryptedObjectString
    }
}
