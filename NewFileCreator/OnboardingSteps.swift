//
//  OnboardingSteps.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

struct WelcomeStep: View {
    var body: some View {
        StepLayout(
            stepNumber: 1,
            icon: "doc.badge.plus",
            iconColor: .blue,
            title: "Create files from Finder in seconds",
            description: "NewFileCreator adds a quick “New File” action to Finder so you can create text, code, and markup files without opening another app."
        ) {
            VStack(spacing: 14) {
                FeatureRow(
                    icon: "cursorarrow.click.2",
                    title: "Right-click workflow",
                    detail: "Create common file types directly from the Finder context menu."
                )
                FeatureRow(
                    icon: "checkmark.shield",
                    title: "Guided setup",
                    detail: "We’ll walk you through the permissions the extension needs."
                )
                FeatureRow(
                    icon: "sparkles",
                    title: "Takes under a minute",
                    detail: "There are only two system settings to review."
                )
            }
        }
    }
}

struct FullDiskAccessStep: View {
    @Binding var hasReviewedFullDiskAccess: Bool

    var body: some View {
        StepLayout(
            stepNumber: 2,
            icon: hasReviewedFullDiskAccess ? "checkmark.shield.fill" : "shield.lefthalf.filled",
            iconColor: hasReviewedFullDiskAccess ? .green : .orange,
            title: "Open Full Disk Access",
            description: "Because NewFileCreator runs sandboxed, macOS does not offer a reliable way for the app to verify Full Disk Access directly. Enable it in System Settings, then confirm the step here."
        ) {
            VStack(spacing: 18) {
                InstructionPanel(
                    title: "What to do",
                    items: [
                        "Open Privacy & Security settings.",
                        "Scroll to Full Disk Access.",
                        "Turn on NewFileCreator if it appears in the list."
                    ]
                )

                HStack(spacing: 12) {
                    Button {
                        SettingsNavigator.openFullDiskAccess()
                    } label: {
                        Label("Open Full Disk Access", systemImage: "lock.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("Opens the Full Disk Access page in System Settings.")

                    Button {
                        hasReviewedFullDiskAccess.toggle()
                    } label: {
                        Label(
                            hasReviewedFullDiskAccess ? "Confirmed" : "I enabled Full Disk Access",
                            systemImage: hasReviewedFullDiskAccess ? "checkmark.circle.fill" : "checkmark.circle"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(hasReviewedFullDiskAccess ? .green : .secondary)
                }

                if !hasReviewedFullDiskAccess {
                    Button {
                        SettingsNavigator.relaunchApplication()
                    } label: {
                        Label("Restart NewFileCreator", systemImage: "arrow.clockwise.circle")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint("Quits and reopens the app so macOS can apply Full Disk Access changes.")
                }

                StatusNote(
                    text: hasReviewedFullDiskAccess
                        ? "Full Disk Access was acknowledged. You can continue."
                        : "After enabling the toggle in System Settings, return here and confirm the step. A restart can still help macOS apply the change."
                )
            }
        }
    }
}

struct EnableExtensionStep: View {
    @Binding var isExtensionEnabled: Bool
    let canFinishOnboarding: Bool
    let onFinish: () -> Void

    var body: some View {
        StepLayout(
            stepNumber: 3,
            icon: isExtensionEnabled ? "checkmark.circle.fill" : "puzzlepiece.extension.fill",
            iconColor: isExtensionEnabled ? .green : .pink,
            title: "Enable the Finder extension",
            description: "NewFileCreator checks the Finder Sync state directly. Once the extension is enabled and Full Disk Access is confirmed, you can finish onboarding immediately."
        ) {
            VStack(spacing: 18) {
                InstructionPanel(
                    title: "What to do",
                    items: [
                        "Open the Finder extension manager.",
                        "Enable NewFileCreator.",
                        "Return to Finder and right-click to test the menu."
                    ]
                )

                HStack(spacing: 12) {
                    Button {
                        SettingsNavigator.openFinderExtensionManager()
                    } label: {
                        Label("Manage Finder Extension", systemImage: "puzzlepiece.extension")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("Opens the macOS Finder extension management interface.")

                    Button {
                        isExtensionEnabled = ExtensionChecker.isFinderExtensionEnabled()
                    } label: {
                        Label(
                            isExtensionEnabled ? "Extension detected" : "Check again",
                            systemImage: isExtensionEnabled ? "checkmark.circle.fill" : "arrow.clockwise"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(isExtensionEnabled ? .green : .secondary)
                }

                if canFinishOnboarding {
                    Button {
                        onFinish()
                    } label: {
                        Label("Finish onboarding", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                StatusNote(
                    text: isExtensionEnabled
                        ? "The Finder extension is enabled. You can finish setup."
                        : "If it still does not detect the extension, open the manager, enable NewFileCreator, then return to the app."
                )
            }
        }
        .onAppear {
            isExtensionEnabled = ExtensionChecker.isFinderExtensionEnabled()
        }
    }
}
