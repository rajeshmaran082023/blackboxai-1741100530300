// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GermanArticleQuiz",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "GermanArticleQuiz", targets: ["GermanArticleQuiz"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "GermanArticleQuiz",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                "SwiftSoup"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GermanArticleQuizTests",
            dependencies: ["GermanArticleQuiz"],
            path: "Tests"
        )
    ]
)
