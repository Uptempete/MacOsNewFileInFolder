//
//  OnboardingSupport.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import AppKit
import FinderSync

enum ExtensionChecker {
    static func isFinderExtensionEnabled() -> Bool {
        FIFinderSyncController.isExtensionEnabled
    }
}

enum SettingsNavigator {
    private static let fullDiskAccessURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    )

    static func openFullDiskAccess() {
        if let fullDiskAccessURL, NSWorkspace.shared.open(fullDiskAccessURL) {
            return
        }

        let fallbackURL = URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane")
        NSWorkspace.shared.open(fallbackURL)
    }

    static func openFinderExtensionManager() {
        FIFinderSyncController.showExtensionManagementInterface()
    }

    static func relaunchApplication() {
        let bundleURL = Bundle.main.bundleURL
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.openApplication(at: bundleURL, configuration: configuration) { _, _ in
            NSApp.terminate(nil)
        }
    }
}
