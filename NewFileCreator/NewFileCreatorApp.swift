//
//  NewFileCreatorApp.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

@main
struct NewFileCreatorApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var isExtensionEnabled = ExtensionChecker.isFinderExtensionEnabled()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingCompleted && isExtensionEnabled {
                    CompletedView()
                } else {
                    OnboardingView()
                }
            }
            .onAppear {
                refreshPermissionState()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshPermissionState()
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private func refreshPermissionState() {
        let extensionEnabled = ExtensionChecker.isFinderExtensionEnabled()

        isExtensionEnabled = extensionEnabled

        if !extensionEnabled {
            onboardingCompleted = false
        }
    }
}
