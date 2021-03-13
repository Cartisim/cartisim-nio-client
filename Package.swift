// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cartisim-nio-client",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
            
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "CartisimNIOClient", targets: ["CartisimNIOClient"]),
    ],

    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.9.2"),
    ],
    targets: [
        .target(
            name: "CartisimNIOClient",
            dependencies: [
                .product(name: "NIOExtras", package: "swift-nio-extras"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services")
            ],
            swiftSettings: [
            // Enable better optimizations when building in Release configuration. Despite the use of
            // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
            // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
            .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "CartisimNIOClientTests", dependencies: ["CartisimNIOClient"]),
    ]
)
