// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var targets: [PackageDescription.Target] = [
    .target(
        name: "CartisimNIOClient",
        dependencies: [
            .product(name: "NIOExtras", package: "swift-nio-extras"),
            .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "NIOHTTP1", package: "swift-nio")
        ]
    ),
    .testTarget(name: "CartisimNIOClientTests", dependencies: ["CartisimNIOClient"]),

]

let package = Package(
    name: "cartisim-nio",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "CartisimNIOClient", targets: ["CartisimNIOClient"]),
    ],

    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.27.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.9.2"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.7.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.5"))
    ],
    targets: targets
)
