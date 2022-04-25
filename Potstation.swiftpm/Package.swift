// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Potstation",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Potstation",
            targets: ["AppModule"],
            bundleIdentifier: "potstation.muelas.com",
            teamIdentifier: "P952S3W7DW",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad
            ],
            supportedInterfaceOrientations: [
                .portrait
            ],
            capabilities: [
                .camera(purposeString: "This app uses the camera to place your pot model in Augmented Reality.")
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/Euclid.git", "0.5.20"..<"1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "Euclid", package: "Euclid")
            ],
            path: "."
        )
    ]
)