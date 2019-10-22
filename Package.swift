// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "MessagePack",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(
      name: "MessagePack",
      targets: ["MessagePack"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "MessagePack",
      dependencies: []
    )
  ]
)
