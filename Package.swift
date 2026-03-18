// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "larpxodus",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "larpxodus",
            targets: ["larpxodusApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "larpxodusApp",
            path: "Sources/larpxodusApp"
        )
    ]
)
