// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "composable-darwin-notifications",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableDarwinNotifications",
      targets: ["ComposableDarwinNotifications"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.8.0"),
  ],
  targets: [
    .target(
      name: "ComposableDarwinNotifications",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "ComposableDarwinNotificationsTests",
      dependencies: ["ComposableDarwinNotifications"]
    ),
  ]
)
