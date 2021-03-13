# CartisimNIOClient

A simple SwiftNIO TCP Client for Chat Applications. This project is designed to use both NIOTS and BSD Sockets for Cross Platform Scalability.

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

#if DEBUG || LOCAL

cartisimNIOClient = CartisimNIOClient(host: "localhost", port: 8081)

#else

cartisimNIOClient = CartisimNIOClient(host: "tcp.example.io", port: 3000)

#endif

do {

try cartisimNIOClient?.run()

print("Running Server")

} catch {

print(error, "Shutting down Server")

cartisimNIOClient?.shutdown()

}

//Prepare to receive data and then do something with it

func didReceivedData() {

cartisimNIOClient?.onDataReceived = { [weak self] dataObject in

print("do stuff with data \(dataObject)")

}


func sendSomeData() {

guard let data = ChatData(ourJsonEncodedData: Data) else {return}

cartisimNIOClient?.send(chat: data)

//After you send your data you probable want to call did receive data

func didReceivedData()

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

See also the list of [contributors](https://github.com/Cartisim/cartisim-nio-clientcontributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Go SwiftNIO Team
