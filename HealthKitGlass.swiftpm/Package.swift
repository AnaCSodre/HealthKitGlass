// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "HealthKitGlass",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "HealthKitGlass",
            targets: ["AppModule"],
            bundleIdentifier: "aninhasodr-icloud.com.HealthKitGlass",
            teamIdentifier: "795X25F7W6",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .healthcareFitness
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
