import PackageDescription

let package = Package(
    name: "StartAppsKit",
    dependencies: [
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitLoadAction.git", versions: Version(1,0,0)..<Version(1, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitExtensions.git", versions: Version(1,0,0)..<Version(1, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitAnimations.git", versions: Version(0,1,0)..<Version(1, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitAlerts.git", versions: Version(1,0,0)..<Version(1, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitLogger.git", versions: Version(1,0,0)..<Version(1, .max, .max))
    ]
)
