# CartisimNIOClient

A simple SwiftNIO TCP Client for Chat Applications. This project is designed to use NIOTS and in the future BSD Sockets for Cross Platform Scalability.

## Getting Started

Copy Github URL and open Xcode. Add URL to Swift Package Manager.

### Prerequisites

Swift 5.0 


### Installing

```
Copy URL
```
```
Open Xcode
```
```
Go To File -> Swift Packages -> Add Package Dependency
```
```
Paste in the URL
```

### How to use

```
//Configure the client and get it up and running

import CartisimNIOClient

func startObserving() {

#if DEBUG || LOCAL

cartisimNIOClient = CartisimNIOClient(host: "localhost", port: 8081, isEncrytedObject: true)

#else

cartisimNIOClient = CartisimNIOClient(host: "tcp.example.io", port: 3000, isEncrytedObject: true)

#endif

cartisimNIOClient?.connect()

}

//Disconnect
cartisimNIOClient.disconnect()

//Prepare to receive data and then do something with it

func didReceivedData() {

cartisimNIOClient?.onDataReceived = { [weak self] dataObject in

print("do stuff with data \(dataObject)")

//Here are some example of what you can do

guard let strongSelf = self else { return }
guard let decryptedObject = strongSelf.networkUtility.networkWrapper.someDecryptableResponse(Chatroom.self, string: dataObject.encryptedObjectString) else {return}

//Or

let decryptedName = strongSelf.someCrypto.decryptText(text: dataObject.name, symmetricKey: "key")
let decryptedMessage = strongSelf.someCrypto.decryptText(text: dataObject.message, symmetricKey: "key")

//If you are encrypting your messages then you can just do whatever you want with your dataObject

}


func sendSomeObject() {

let encryptMessage = try someCrypto.encryptText(text: "A message", symmetricKey: "key")
let encryptName = try someCrypto.encryptText(text: "name", symmetricKey: "key")

guard let data = MessageData(avatar: "", userID: "98u3140u5", name: encryptName, message: encryptMessage, accessToken: "accessToken", refreshToken: "refreshToken", sessionID: "908347967", chatSessionID: "092184")

cartisimNIOClient?.send(chat: data)

//After you send your data you probable want to call did receive data

didReceivedData()

}

//Or if you want to send an encrypted object to your server you can use this code

func sendSomeEncryptedObject() {

let encryptMessage = try someCrypto.encryptText(text: "A message", symmetricKey: "key")
let encryptName = try someCrypto.encryptText(text: "name", symmetricKey: "key")

let data = networkUtility.networkWrapper.someEncryptableBody(body: MessageData(avatar: "", userID: "98u3140u5", name: encryptName, message: encryptMessage, accessToken: "accessToken", refreshToken: "refreshToken", sessionID: "908347967", chatSessionID: "092184"))

cartisimNIOClient?.sendEncryptedObject(chat: data)

//After you send your data you probable want to call did receive data

didReceivedData()

}

```


## Built With

* [SwiftNIO](https://github.com/apple/swift-nio) - Low Level Networking Framework
* [SwiftNIOTS](https://github.com/apple/swift-nio-transport-services) - Wrapper around Network.framework
* [SwiftNIOExtras](https://github.com/apple/swift-nio-extras) - Extra good stuff

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/Cartisim/cartisim-nio-client/tags). 

## Authors

* **Cartisim Development* - *Initial work* - [Cartisim](https://cartisim.io)

See also the list of [contributors](https://github.com/Cartisim/cartisim-nio-client/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Go SwiftNIO Team
