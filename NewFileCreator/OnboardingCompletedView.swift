//
//  OnboardingCompletedView.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

struct CompletedView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("hasReviewedFullDiskAccess") private var hasReviewedFullDiskAccess = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.16),
                    Color.blue.opacity(0.08),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Setup complete", systemImage: "checkmark.seal.fill")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.green)

                        Text("NewFileCreator is ready")
                            .font(.system(size: 34, weight: .bold, design: .rounded))

                        Text("You can now right-click inside Finder and create a new file from the context menu.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("Close") {
                        NSApp.keyWindow?.close()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                HStack(spacing: 14) {
                    QuickActionCard(
                        title: "Privacy & Security",
                        detail: "Reopen Full Disk Access if Finder still cannot create files.",
                        symbol: "lock.shield"
                    ) {
                        SettingsNavigator.openFullDiskAccess()
                    }

                    QuickActionCard(
                        title: "Finder Extension",
                        detail: "Check whether the Finder extension is currently enabled.",
                        symbol: "puzzlepiece.extension"
                    ) {
                        SettingsNavigator.openFinderExtensionManager()
                    }
                }

                InstructionPanel(
                    title: "Good next checks",
                    items: [
                        "Open Finder and right-click inside a folder.",
                        "Confirm that “New File” appears in the context menu.",
                        "If it does not, reopen the extension manager and verify the toggle."
                    ]
                )

                HStack {
                    Button("Show onboarding again") {
                        hasReviewedFullDiskAccess = false
                        onboardingCompleted = false
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                    Spacer()
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2))
                    )
            )
            .padding(20)
        }
        .frame(width: 620, height: 500)
    }
}
