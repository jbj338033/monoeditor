// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Mono",
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Neon", branch: "main"),
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.2.0"),
    ]
)
