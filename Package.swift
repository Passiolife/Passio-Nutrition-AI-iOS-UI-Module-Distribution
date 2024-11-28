// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassioNutritionUIModule",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PassioNutritionUIModule",
            targets: ["PassioNutritionUIModule"]),
    ],
    dependencies: [
         // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution",
                 exact: "3.2.3"),
        .package(url: "https://github.com/SwipeCellKit/SwipeCellKit",
                 .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git",
                 .upToNextMajor(from: "2.8.4")),
        .package(url: "https://github.com/SimonFairbairn/SwiftyMarkdown",
                 .upToNextMajor(from: "1.2.4")),
        .package(url: "https://github.com/airbnb/lottie-spm.git",
                 .upToNextMajor(from: "4.4.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PassioNutritionUIModule",
            dependencies: [
                .product(name: "PassioNutritionAISDK",
                         package: "Passio-Nutrition-AI-iOS-SDK-Distribution"),
                "SwipeCellKit",
                "FSCalendar",
                "SwiftyMarkdown",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            resources: [.process("NutritionUIModule/VoiceLogging.json"), // Lottie Animation
                        .process("NutritionUIModule/TypingIndicator.json"),
                        .copy("NutritionUIModule/PassioFood.xcdatamodeld")]
//                        .copy("CoreSDK/ServicesVolume/VolumeKernels/FindMode.metal"), // VolumeKernels
//                        .copy("CoreSDK/ServicesVolume/VolumeKernels/HeightToVolume.metal"),
//                        .copy("CoreSDK/ServicesVolume/VolumeKernels/KalmanStatic1D.metal"),
//                        .copy("CoreSDK/ServicesVolume/VolumeKernels/MakeHeightMap.metal"),
//                        .copy("CoreSDK/ServicesVolume/VolumeKernels/volume_metal.h")]
        ),
    ]
)
