// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPM",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SPM",
            targets: ["SPM"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // MARK: - Rx
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.1.1"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", from: "4.0.1"),
        // MARK: - ReactorKit
        .package(url: "https://github.com/ReactorKit/ReactorKit", from: "2.1.0"),
        // MARK: - SnapKit
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        // MARK: - Alamofire
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.2.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SPM",
            dependencies: [
                "RxSwift",
                "RxDataSources",
                "ReactorKit",
                "SnapKit",
                "Alamofire"
            ]),
        .testTarget(
            name: "SPMTests",
            dependencies: ["SPM"])
    ]
)
