import PackageDescription

let package = Package(
  name: "MessagePack",
  dependencies: [
    .Package(url: "https://github.com/a2/Data.git", majorVersion: 1),
  ]
)
