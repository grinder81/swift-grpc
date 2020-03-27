// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RouteGuideProvider",
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", .branch("master")),
        .package(path: "../../model/RouteGuide")
    ],
    targets: [
        .target(
            name: "RouteGuideProvider",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                "RouteGuide"]
        ),
        .testTarget(
            name: "RouteGuideProviderTests",
            dependencies: ["RouteGuideProvider"]),
    ]
)
