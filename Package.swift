import PackageDescription

let package = Package(
    name: "StartAppsKit",
    dependencies: [
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitLoadAction.git", versions: Version(2,0,0)..<Version(2, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitExtensions.git", versions: Version(2,0,0)..<Version(2, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitAnimations.git", versions: Version(2,0,0)..<Version(2, .max, .max)),
        .Package(url: "https://github.com/StartAppsPe/StartAppsKitLogger.git", versions: Version(2,0,0)..<Version(2, .max, .max))
    ]
)
