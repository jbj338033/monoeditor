import ProjectDescription

let project = Project(
    name: "Mono",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "MACOSX_DEPLOYMENT_TARGET": "26.0",
            "SWIFT_STRICT_CONCURRENCY": "complete",
            "OTHER_SWIFT_FLAGS": "$(inherited) -Xfrontend -enable-upcoming-feature -Xfrontend StrictConcurrency",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "Mono",
            destinations: .macOS,
            product: .app,
            bundleId: "dev.tuist.Mono",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleName": "Mono",
                "CFBundleDisplayName": "Mono",
                "NSHighResolutionCapable": true,
                "CFBundleDocumentTypes": [
                    [
                        "CFBundleTypeName": "Source Code",
                        "CFBundleTypeRole": "Editor",
                        "LSHandlerRank": "Default",
                        "LSItemContentTypes": ["public.source-code", "public.plain-text"],
                    ]
                ],
            ]),
            buildableFolders: [
                "Mono/Sources",
                "Mono/Resources",
            ],
            dependencies: [
                .external(name: "Neon"),
                .external(name: "SwiftTerm"),
            ]
        ),
        .target(
            name: "MonoTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "dev.tuist.MonoTests",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .default,
            buildableFolders: [
                "Mono/Tests"
            ],
            dependencies: [.target(name: "Mono")]
        ),
    ]
)
